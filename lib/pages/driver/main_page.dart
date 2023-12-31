import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:taxi_fleet_frontend_app/components/client_marker.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/config/stomp_client.dart';
import 'package:taxi_fleet_frontend_app/providers/shared_prefs.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<LatLng> _polylineCoordinates;
  late final MapController _mapController;
  late LatLng _userLocation;
  late Marker _marker;
  late bool _firstLocationUpdate;
  late StompClientConfig _stompClientConfig;
  late StompClient _stompClient;
  late bool _isMenuExpanded;
  late List<MapMarker> _mapMarkers;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    /*_stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-LOCATION', // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();*/
    _stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-TRIP', // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();
    _mapMarkers = [];
    _isMenuExpanded = false;
    _firstLocationUpdate = true;
    _mapController = MapController();
    _userLocation = const LatLng(0, 0);
    _marker = _buildMarker(_userLocation);
    _getCurrentLocation();

    //stomp client

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getCurrentLocation();
      print("**********> $_userLocation");
      //sendLocation(_userLocation);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose the timer when the widget is disposed
    //_stompClient.deactivate();
    super.dispose();
  }

  void sendLocation(userLocation) {
    // Send location to the microservice
    _stompClient.send(
      destination: '/location', // Replace with your microservice's location endpoint
      body: jsonEncode(
        {
          'location': "POINT(${userLocation.longitude} ${userLocation.latitude})", // Replace with your microservice's location endpoint
          'userId': Provider.of<SharedPrefs>(context, listen: false).userId,
          'uderType': Provider.of<SharedPrefs>(context, listen: false).role,
        }
        ),
    );
  }

  void onConnect(StompFrame frame) {
    print('Connected to the trip service');
    _stompClient.subscribe(
      destination: '/topic/nearbyUsers',
      callback: (StompFrame frame) {
        //update isLoading to false
        /*setState(() {
          _isLoading = false;
        });*/

        //get a list of LatLng coordinates from the message body
        //print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        List<dynamic> nearbyUsers = json.decode(json.decode(data['nearbyUsers'])) as List<dynamic>;
       // print(nearbyUsers);
        /*final List<dynamic> nearbyUsers = jsonDecode(data['nearbyUsers']);*/
        // format the data is a List of object {userId,location is a string "POINT(lat lng)"}
        List<MapMarker> mapMarkers = [];
        for (final user in nearbyUsers) {
          final String userId = user['userId'];
          final String location = user['location'];
          final List<String> latLng = location.substring(6, location.length - 1).split(' ');
          final double latitude = double.parse(latLng[1]);
          final double longitude = double.parse(latLng[0]);
          final LatLng userLocation = LatLng(latitude, longitude);
          //print("userId: $userId , location: $userLocation");

          final MapMarker mapMarker = MapMarker(
            userId: userId,
            location: userLocation,
          );
          mapMarkers.add(mapMarker);
        }

        setState(() {
          _mapMarkers = mapMarkers;
        });

        //print('Received a message from the trip service: $nearbyUsers');
      },
    );
    _stompClient.send(
      destination: '/nearbyUsers',
      body: "1"
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          return;
        }
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      //print("=========> $position");

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        Provider.of<LocationProvider>(context, listen: false).updateUserLocation(_userLocation);
        _marker = _buildMarker(_userLocation);
        if (_firstLocationUpdate) {
          // Move the map to the user's location only for the first time
          _mapController.move(_userLocation, _mapController.zoom);
          _firstLocationUpdate = false;
        }
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _toggleMenu() {
            setState(() {
              _isMenuExpanded = !_isMenuExpanded;
            });
          }

  Marker _buildMarker(LatLng position) {
    // Example of a different marker icon (you can replace this with your custom icon)
    return Marker(
      width: 80.0,
      height: 80.0,
      point: position,
      child: //taxi icon
      Image.asset(
        AppIcons.icTaxi,
        //reduces the image size
        scale: 0.8,
      ),
    );
  }

  //final mapMarkers = [];
  /*MapMarker(
      userId: "Client 1",
      location: const LatLng(33.707173, -7.362968),
      rating: 3,
      ),
  MapMarker(
      userId: "Client 2",
      location: const LatLng(33.705118, -7.357584),
      rating: 4,
      ),
];*/

  @override
  Widget build(BuildContext context) {
    print("size of mapMarkers: ${_mapMarkers.length}");
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialZoom: 15,
              initialCenter: _userLocation,
            ),
            children: [
              TileLayer(
                urlTemplate:
                  "https://api.mapbox.com/styles/v1/${AppConstants.mapBoxUsername}/${AppConstants.mapBoxStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token=${AppConstants.mapBoxAccessToken}",
                additionalOptions: const {
                  'mapStyleId': AppConstants.mapBoxStyleId,
                  'accessToken': AppConstants.mapBoxAccessToken,
                },
              ),
              MarkerLayer(
                markers: [
                  _marker,
                  //iterate through the mapMarkers list and add them to the map
                  for (final marker in _mapMarkers)
                    Marker(
                      point: marker.location,
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(
                              AppIcons.icClient,
                              fit: BoxFit.cover,
                            ), 
                    )
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: "search",
              onPressed: () {},
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.search, size: 32),
            ),
          ),
          Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          height: _isMenuExpanded ? 290.0 : 0.0,
                          child: SingleChildScrollView(
                              child: Column(
                              children: [
                                FloatingActionButton(
                                  heroTag: "zoomIn",
                                  onPressed: () {
                                    _mapController.move(
                                      _mapController.center,
                                      _mapController.zoom + 0.5,
                                    );
                                  },
                                  backgroundColor: AppColors.primaryColor,
                                  child: Icon(Icons.add),
                                ),
                                SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "zoomOut",
                                  onPressed: () {
                                    _mapController.move(
                                      _mapController.center,
                                      _mapController.zoom - 0.5,
                                    );
                                  },
                                  backgroundColor: AppColors.primaryColor,
                                  child: Icon(Icons.remove),
                                ),
                                SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "gps",
                                  onPressed: () {
                                    _mapController.move(
                                      _userLocation,
                                      _mapController.zoom,
                                    );
                                  },
                                  backgroundColor: AppColors.primaryColor,
                                  child: Icon(Icons.gps_fixed),
                                ),
                                SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "settings",
                                  onPressed: () {},
                                  backgroundColor: AppColors.primaryColor,
                                  child: Icon(Icons.settings),
                                ),
                                SizedBox(height: 16.0),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          //onTap: _toggleMenu,
                          child: FloatingActionButton(
                            heroTag: "menu",
                            onPressed: _toggleMenu,
                            backgroundColor: AppColors.primaryColor,
                            child: Icon(
                              _isMenuExpanded ? Icons.close : Icons.menu,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // positioned card for client info at the top of the screen with an action button
                  Positioned(
                    top: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 290.0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.0,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: const Icon(Icons.person),
                                      ),
                                      const SizedBox(width: 16.0),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Client 1",
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.0),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 12.0,
                                                  color: Colors.amber,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 12.0,
                                                  color: Colors.amber,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 12.0,
                                                  color: Colors.amber,
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 12.0,
                                                  color: Colors.grey, // Empty star color
                                                ),
                                                Icon(
                                                  Icons.star,
                                                  size: 12.0,
                                                  color: Colors.grey, // Empty star color
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text(
                                        "0.5 km",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            primary: AppColors.primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text(
                                            "Suggest",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
                                            ),
                                            ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                      ),
                    ),
                  ),
                ),
                                      
        ],
      ),
    );
  }
}