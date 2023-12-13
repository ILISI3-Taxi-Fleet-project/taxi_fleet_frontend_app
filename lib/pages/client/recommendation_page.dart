import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geobase/geobase.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/config/app_icons.dart';
import 'package:taxi_fleet_frontend_app/config/stomp_client.dart';
import 'package:taxi_fleet_frontend_app/providers/shared_prefs.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';
import 'main_page.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';

class RecommendationPage extends StatefulWidget {

  final LatLng destination;

   const RecommendationPage({super.key, required this.destination});

  @override
  _RecommendationPageState createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late StompClientConfig _stompClientConfig;
  late StompClient _stompClient;
  late LatLng _userLocation;
  late LatLng _driverLocation;
  late Marker _userMarker;
  late Marker _driverMarker;
  late List<Polyline> _polylines;
  late List<Polyline> _polylinesDriver;
  late bool _isMenuExpanded;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _stompClientConfig = StompClientConfig(
      port: 8888,
      serviceName: 'MSTXFLEET-TRIP', // Replace with your microservice's port
      onConnect: onConnect,
      userId: Provider.of<SharedPrefs>(context, listen: false).userId,
    );
    _stompClient = _stompClientConfig.connect();
    // Listen to changes in the user location
    _isMenuExpanded = false;
    _isLoading = true;
    

    Provider.of<LocationProvider>(context, listen: false).addListener(() {
      _updateUserLocation();
    });

    _driverLocation = const LatLng(0, 0);
    _driverMarker = _buildDriverMarker(_driverLocation);

    // Initial update
    _updateUserLocation();
    _mapController = MapController();
    _polylines = <Polyline>[];
    _polylinesDriver = <Polyline>[];

  }

  void _updateUserLocation() {
    setState(() {
      _userLocation = Provider.of<LocationProvider>(context, listen: false).userLocation;
      _userMarker = _buildUserMarker(_userLocation);
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

  void decodeWktDriver(String multiLineString) {
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
            color: Colors.green,
        ));
      }
      setState(() {
        _polylinesDriver = polylines;
      });
  }

  //send destination to the trip service when _stompClient is connected
  void onConnect(StompFrame frame) {
    print('Connected to the trip service');

    _stompClient.subscribe(
      destination: '/topic/trip.path/${Provider.of<SharedPrefs>(context, listen: false).userId}',
      callback: (StompFrame frame) {
        //update isLoading to false
        setState(() {
          _isLoading = false;
        });

        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final String coordinates = data['path'];
        decodeWktDriver(coordinates);

        // get deiver location every 10 seconds with timer
        Timer.periodic(const Duration(seconds: 10), (timer) {
          print('---------Sending a message to the trip service');
          _stompClient.send(
            destination: '/app/location.getDriverLocation',
          );
        });
      },
    );

    _stompClient.subscribe(
      destination: '/topic/trip.pathDestination/${Provider.of<SharedPrefs>(context, listen: false).userId}',
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

    _stompClient.subscribe(
      destination: '/topic/location.getDriverLocation/${Provider.of<SharedPrefs>(context, listen: false).userId}',
      callback: (StompFrame frame) {

        //get a list of LatLng coordinates from the message body
        print('Received a message from the trip service: ${frame.body}');
        
        final Map<String, dynamic> data = jsonDecode(frame.body!);
        final String location = data['driverLocation']['location'];
        final List<String> latLng = location.substring(6, location.length - 1).split(' ');
        final double latitude = double.parse(latLng[1]);
        final double longitude = double.parse(latLng[0]);
        final LatLng driverLocation = LatLng(latitude, longitude);

        setState(() {
          _driverLocation = driverLocation;
          _driverMarker = _buildDriverMarker(_driverLocation);
        });
      },
    );

    _stompClient.send(
      destination: '/app/trip.initialize',
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

  Marker _buildUserMarker(LatLng position) {
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

  Marker _buildDriverMarker(LatLng position) {
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
              _userMarker,
              _driverMarker,
            ],
          ),
          PolylineLayer(
            polylines: _polylines + _polylinesDriver,
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
                          duration: const Duration(milliseconds: 300),
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
