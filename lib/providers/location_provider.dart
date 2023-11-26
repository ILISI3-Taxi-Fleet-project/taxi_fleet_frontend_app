import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationProvider with ChangeNotifier {
  late LatLng _userLocation; // Default initial location

  LatLng get userLocation => _userLocation;

  void updateUserLocation(LatLng newLocation) {
    _userLocation = newLocation;
    notifyListeners(); // Notify listeners of the change
  }
}
