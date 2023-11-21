import 'package:latlong2/latlong.dart';

class MapMarker {
  final String? fullName;
  final LatLng location;
  final int? rating;
  final double? distance;

  MapMarker({
    this.fullName,
    required this.location,
    required this.rating,
    required this.distance,
  });
}
