import 'package:latlong2/latlong.dart';

class MapMarker {
  final String userId;
  final LatLng location;
  final int? rating;

  MapMarker({
    required this.userId,
    required this.location,
    this.rating,
  });
}
