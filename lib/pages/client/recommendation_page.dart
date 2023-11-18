import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geobase/geobase.dart';
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
  late List<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _stompClientConfig = StompClientConfig(
      port: 8083, // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();
    // Listen to changes in the user location
    Provider.of<LocationProvider>(context, listen: false).addListener(() {
      _updateUserLocation();
    });

    // Initial update
    _updateUserLocation();
    _mapController = MapController();
    _polylineCoordinates = <LatLng>[];
    _polylines = <Polyline>[];
  }

  void _updateUserLocation() {
    setState(() {
      _userLocation = Provider.of<LocationProvider>(context, listen: false).userLocation;
      _marker = _buildMarker(_userLocation);
    });
  }

  void decodeWkt(String multiLineString) {
      final List<Polyline> polylines = <Polyline>[];
      final geometry = MultiLineString.parse(multiLineString, format: WKT.geometry);
      final Iterable<LineString> lines = geometry.lineStrings;
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

  //send destination to the trip service when _stompClient is connected
  void onConnect(StompFrame frame) {
    print('Connected to the trip service');
    _stompClient.subscribe(
      destination: '/topic/route',
      callback: (StompFrame frame) {
        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final String coordinates = data['coordinates'];
        decodeWkt(coordinates);
      },
    );
    _stompClient.send(
      destination: '/route',
      body: jsonEncode(
        {
          'startLongitude' : _userLocation.longitude,
          'startLatitude' : _userLocation.latitude,
          'endLongitude': widget.destination.longitude,
          'endLatitude': widget.destination.latitude,
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
            polylines: _polylines,
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
