import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/config/stomp_client.dart';
import 'main_page.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';

class RecommendationPage extends StatefulWidget {

  final LatLng destination;

   const RecommendationPage({super.key, required this.destination});

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  late final MapController _mapController;
  late StompClientConfig _stompClientConfig;
  late StompClient _stompClient;
  late List<LatLng> _polylineCoordinates;
  late LatLng _userLocation;
  late Marker _marker;

  @override
  void initState() {
    super.initState();
    /*_stompClientConfig = StompClientConfig(
      port: 8083, // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();*/
    // Listen to changes in the user location
    Provider.of<LocationProvider>(context, listen: false).addListener(() {
      _updateUserLocation();
    });

    // Initial update
    _updateUserLocation();
    _mapController = MapController();
    _polylineCoordinates = <LatLng>[];
  }

  void _updateUserLocation() {
    setState(() {
      _userLocation = Provider.of<LocationProvider>(context, listen: false).userLocation;
      _marker = _buildMarker(_userLocation);
    });
  }

  //send destination to the trip service when _stompClient is connected
  void onConnect(StompFrame frame) {
    print('Connected to the trip service');
    _stompClient.subscribe(
      destination: '/topic/route',
      callback: (StompFrame frame) {
        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final List<dynamic> coordinates = data['coordinates'];
        final List<LatLng> points = coordinates.map((coord) => LatLng(coord['latitude'], coord['longitude'])).toList();
        setState(() {
          _polylineCoordinates = points;
        });
      },
    );
    _stompClient.send(
      destination: '/route',
      body: jsonEncode(
        {
          'latitude': widget.destination.latitude,
          'longitude': widget.destination.longitude,
        },
      ),
    );
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

  @override
  void dispose() {
    _stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userLocation,
          initialZoom: 15.0,
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
            polylines: [
              Polyline(
                points: _polylineCoordinates,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
      //cancel trip button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(),
            ),
          );
        },
        child: const Icon(Icons.cancel),
      ),
    );
  }
}
