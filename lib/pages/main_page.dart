import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/pages/destination_page.dart';

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

  Timer? _timer;

  @override
  void initState() {
    super.initState();
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

    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Dispose the timer when the widget is disposed
    super.dispose();
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

      print("=========> $position");

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
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
      child: const Icon(
            Icons.location_on_rounded,
            size: 50.0,
            color: Colors.blue,
      ),
    );
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
          // Updated Positioned widget for a more visually appealing design
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _openDestinationSelectionPage();
              },
              child: const Text('Choose Destination'),
            ),
          ),

        ],
      ),
    );
  }
}