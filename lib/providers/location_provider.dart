import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  LatLng _userLocation = const LatLng(33.70639, -7.3533433); // Default initial location

  LatLng get userLocation => _userLocation;

  void updateUserLocation(LatLng newLocation) {
    _userLocation = newLocation;
    notifyListeners(); // Notify listeners of the change
  }
}
