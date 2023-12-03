import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/config/stomp_client.dart';
import 'package:taxi_fleet_frontend_app/providers/shared_prefs.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';
import 'destination_page.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late final MapController _mapController;
  late LatLng _userLocation;
  late Marker _marker;
  late bool _firstLocationUpdate;
  late StompClientConfig _stompClientConfig;
  late StompClient _stompClient;
  late bool _isMenuExpanded;

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
    _firstLocationUpdate = true;
    _mapController = MapController();
    _userLocation = const LatLng(0, 0);
    _marker = _buildMarker(_userLocation);
    _getCurrentLocation();
    _isMenuExpanded = false;

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
          'userType': Provider.of<SharedPrefs>(context, listen: false).role,
        }
        ),
    );
  }

  void onConnect(StompFrame frame) {
    print('Connected to the location service');
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

  Marker _buildMarker(LatLng position) {
    // Example of a different marker icon (you can replace this with your custom icon)
    return Marker(
      width: 35.0,
      height: 35.0,
      point: position,
      child: const Icon(
            Icons.circle_rounded,
            size: 35.0,
            color: Colors.blue,
      ),
    );
  }

  void _toggleMenu() {
            setState(() {
              _isMenuExpanded = !_isMenuExpanded;
            });
          }

  void _openDestinationSelectionPage() async {
    final selectedAddress = await Navigator.of(context).push(
      MaterialPageRoute<String>(
        builder: (BuildContext context) => DestinationSelectionPage(
          userLocation: _userLocation,
        ),
      ),
    );

    if (selectedAddress != null) {
      print("Selected address: $selectedAddress");
      // Handle the selected destination address and update the map.
      // You can use geocoding to get the coordinates of the selected address.
      // Update the _destinationLocation and set the destination marker on the map.
    }
  }

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
            ],
          ),
          // Updated Positioned widget for a more visually appealing design
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: "search",
              onPressed: () {
                _openDestinationSelectionPage();
              },
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
                                SizedBox(height: 16.0),
                                FloatingActionButton(
                                  heroTag: "gps",
                                  onPressed: () {
                                    _animatedMapMove(
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