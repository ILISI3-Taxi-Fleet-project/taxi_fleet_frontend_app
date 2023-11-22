import 'package:latlong2/latlong.dart';

class MapMarker {
  final String userId;
  final LatLng location;

  MapMarker({
    required this.userId,
    required this.location,
  });
}
