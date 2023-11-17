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
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';

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

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    /*_stompClientConfig = StompClientConfig(
      port: 8081, // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();*/
    _firstLocationUpdate = true;
    _mapController = MapController();
    _userLocation = const LatLng(0, 0);
    _marker = _buildMarker(_userLocation);
    _getCurrentLocation();
    _polylineCoordinates = <LatLng>[
      /*LatLng(33.70639, -7.3533433),
      LatLng(33.707124, -7.353999),
      LatLng(33.705118, -7.357584),
      LatLng(33.705664, -7.360265),
      LatLng(33.707173, -7.362968),
      LatLng(33.703613, -7.37202),
      LatLng(33.701802, -7.376807),
      LatLng(33.701523, -7.378711)*/
    ];

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
      body: jsonEncode({'latitude': userLocation.latitude, 'longitude': userLocation.longitude}),
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

  final mapMarkers = [
  MapMarker(
      image: null,
      title: null,
      address: null,
      location: const LatLng(33.707173, -7.362968),
      rating: null),
  MapMarker(
      image: null,
      title: null,
      address: null,
      location: const LatLng(33.705118, -7.357584),
      rating: null),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              //minZoom: 5,
              //maxZoom: 18,
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
                  for (final marker in mapMarkers)
                    Marker(
                      point: marker.location,
                      width: 40.0,
                      height: 40.0,
                      child: Image.asset(
                              AppIcons.icClient,
                              fit: BoxFit.cover,
                            ), 
                    ),
                ],
              ),
              PolylineLayer(polylines: [
                Polyline(
                  points: _polylineCoordinates,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ]
              ),
            ],
          ),

        ],
      ),
    );
  }
}