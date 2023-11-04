import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:taxi_fleet_frontend_app/config/websocket_manager.dart';

class WebSocketService {
  static final _webSocketManager = WebSocketManager();
  

  static void sendUserLocation(LatLng userLocation) {
    final channel = _webSocketManager.locationChannel;
    final message = jsonEncode({'latitude': userLocation.latitude, 'longitude': userLocation.longitude});
    channel.sink.add(message);
    /*channel.stream.listen((message) {
      print('Location service response: $message');
      channel.sink.close();
    });*/
  }
}
