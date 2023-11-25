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
import 'package:taxi_fleet_frontend_app/styles/colors.dart';
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
  late bool _isMenuExpanded;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    /*_stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-TRIP', // Replace with your microservice's port
      onConnect: onConnect,
    );
    _stompClient = _stompClientConfig.connect();*/
    // Listen to changes in the user location
    _isMenuExpanded = false;
    _isLoading = false;

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
        //update isLoading to false
        setState(() {
          _isLoading = false;
        });

        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final String coordinates = data['path'];
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
      body: SafeArea(
            child: IgnorePointer(
              ignoring: _isLoading,
              child: Stack(
        children: [
      FlutterMap(
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
      Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: "cancelTrip",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainPage(),
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
                          duration: Duration(milliseconds: 300),
                          height: _isMenuExpanded ? 220.0 : 0.0,
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
                  _isLoading ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.grey.withOpacity(0.5),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Calculating direction...',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ) : Container(),
      //cancel trip button
      ],
      ),
            ),
      ),
    );
  }
}
