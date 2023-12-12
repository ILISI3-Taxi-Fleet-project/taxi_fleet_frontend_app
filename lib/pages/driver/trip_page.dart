import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geobase/geobase.dart' as gb;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:taxi_fleet_frontend_app/components/client_marker.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/config/stomp_client.dart';
import 'package:taxi_fleet_frontend_app/pages/driver/main_page.dart' as driverHomePage;
import 'package:taxi_fleet_frontend_app/providers/shared_prefs.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';

class TripPage extends StatefulWidget {

  final String path;

  const TripPage({super.key, required this.path});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with TickerProviderStateMixin {
  late final MapController _mapController;
  late LatLng _userLocation;
  late Marker _marker;
  late List<Polyline> _polylines;
  late bool _firstLocationUpdate;
  late StompClientConfig _stompClientConfig;
  late StompClient _locationStompClient;
  late StompClient _tripStompClient;
  late bool _isMenuExpanded;
  final pageController = PageController(viewportFraction: 0.8);
  int selectedIndex = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /*_stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-LOCATION', // Replace with your microservice's port
      onConnect: onConnect,
      userId: Provider.of<SharedPrefs>(context, listen: false).userId,
    );
    _locationStompClient = _stompClientConfig.connect();

    _stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-TRIP', // Replace with your microservice's port
      onConnect: onConnect,
      userId: Provider.of<SharedPrefs>(context, listen: false).userId,
    );
    _tripStompClient = _stompClientConfig.connect();*/

    _polylines = [];
    _isMenuExpanded = false;
    _firstLocationUpdate = true;
    _mapController = MapController();
    _userLocation = const LatLng(0, 0);
    _marker = _buildMarker(_userLocation);

    decodeWkt(widget.path);

    _updateUserLocation();

    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) => _updateUserLocation());

  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose the timer when the widget is disposed
    _locationStompClient.deactivate();
    _tripStompClient.deactivate();
    super.dispose();
  }

  void _updateUserLocation() {
    print('getting user location');
    setState(() {
      _userLocation = Provider.of<LocationProvider>(context, listen: false).userLocation;
      _marker = _buildMarker(_userLocation);
    });
  }

  void decodeWkt(String multiLineString) {
      final List<Polyline> polylines = <Polyline>[];
      final geometry = gb.MultiLineString.parse(multiLineString, format: gb.WKT.geometry);
      final Iterable<gb.LineString> lines = geometry.lineStrings;
      for (final line in lines) {
        // iterate over the points in the line by 2 points
        final List<LatLng> points = [];
        for (var i = 0; i < line.chain.values.length; i += 2) {
          points.add(LatLng(line.chain.values.elementAt(i + 1), line.chain.values.elementAt(i)));
        }
        polylines.add(Polyline(
            points: points,
            strokeWidth: 4.0,
            color: Colors.blue,
        ));
      }
      setState(() {
        _polylines = polylines;
      });
  }

  /*void onConnect(StompFrame frame) {
    print('Connected to the trip service');

    _tripStompClient.subscribe(
      destination: '/topic/trip.path/${Provider.of<SharedPrefs>(context, listen: false).userId}',
      callback: (StompFrame frame) {
        //update isLoading to false
        /*setState(() {
          _isLoading = false;
        });*/

        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final String coordinates = data['path'];
        print('Received a message from the trip service: $coordinates');
        decodeWkt(coordinates);
      },
    );

    /*_tripStompClient.send(
      destination: '/app/trip.nearbyUsers',
    );*/

  }*/

  // accept a trip request
  void acceptTripRequest(String passengerId) {
    // Send location to the microservice
    _tripStompClient.send(
      destination: '/app/trip.accept',
      body: jsonEncode(
        {
          'passengerId': passengerId,
        }
        ),
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

  /*final mapMarkers = [
  MapMarker(
      userId: "Client 1",
      location: const LatLng(33.707173, -7.362968),
      ),
  MapMarker(
      userId: "Client 2",
      location: const LatLng(33.705118, -7.357584),
      ),
];*/

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
              PolylineLayer(
                polylines: _polylines,
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: "cancelTrip",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const driverHomePage.MainPage(),
                  ),
                );
                //dispose();
              },
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.cancel),
            ),
          ),
          Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
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
                                  child: const Icon(Icons.add),
                                ),
                                const SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "zoomOut",
                                  onPressed: () {
                                    _mapController.move(
                                      _mapController.center,
                                      _mapController.zoom - 0.5,
                                    );
                                  },
                                  backgroundColor: AppColors.primaryColor,
                                  child: const Icon(Icons.remove),
                                ),
                                const SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "gps",
                                  onPressed: () {
                                    _animatedMapMove(
                                      _userLocation,
                                      _mapController.zoom,
                                    );
                                  },
                                  backgroundColor: AppColors.primaryColor,
                                  child: const Icon(Icons.gps_fixed),
                                ),
                                const SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "settings",
                                  onPressed: () {},
                                  backgroundColor: AppColors.primaryColor,
                                  child: const Icon(Icons.settings),
                                ),
                                const SizedBox(height: 16.0),
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
                    
        ],
      ),
    );
  }


  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }


}