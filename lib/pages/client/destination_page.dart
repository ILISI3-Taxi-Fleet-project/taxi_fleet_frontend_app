import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:taxi_fleet_frontend_app/config/app_constants.dart';
import 'recommendation_page.dart';

class DestinationSelectionPage extends StatefulWidget {
  final LatLng userLocation;

  const DestinationSelectionPage({Key? key, required this.userLocation}) : super(key: key);

  @override
  _DestinationSelectionPageState createState() => _DestinationSelectionPageState();
}

class _DestinationSelectionPageState extends State<DestinationSelectionPage> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _confirmLocation() {
    final center = _mapController.center;
    print("Selected location: $center");
    //navigate to recommendation page
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => RecommendationPage(destination: center)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose destination'),
      ),
      body: FlutterMap(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmLocation,
        child: const Icon(Icons.check),
      ),
    );
  }
}
