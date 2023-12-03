import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'package:taxi_fleet_frontend_app/styles/colors.dart';
import 'recommendation_page.dart';

class DestinationSelectionPage extends StatefulWidget {
  final LatLng userLocation;

  const DestinationSelectionPage({Key? key, required this.userLocation}) : super(key: key);

  @override
  _DestinationSelectionPageState createState() => _DestinationSelectionPageState();
}

class _DestinationSelectionPageState extends State<DestinationSelectionPage> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late bool _isMenuExpanded;

  @override
  void initState() {
    super.initState();
    _isMenuExpanded = false;
    _mapController = MapController();
  }

  void _confirmLocation() {
    final center = _mapController.center;
    print("Selected location: $center");
    //navigate to recommendation page
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecommendationPage(destination: center)));
  }

  void _toggleMenu() {
            setState(() {
              _isMenuExpanded = !_isMenuExpanded;
            });
          }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose destination'),
      ),
      body: Stack(
      children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.userLocation,
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
          const Center(
            child: Icon(
              Icons.location_on,
              size: 50,
              color: Colors.red,
            ),
          )
        ],
      ),
       Positioned(
            bottom: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              heroTag: "confirmLocation",
              onPressed: _confirmLocation,
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.check, size: 32),
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
                                    _animatedMapMove(
                                      widget.userLocation,
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
      ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _confirmLocation,
        child: const Icon(Icons.check),
        backgroundColor: AppColors.primaryColor,
        
      ),*/
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
