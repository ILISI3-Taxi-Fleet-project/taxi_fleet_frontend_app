
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static final WebSocketManager _singleton = WebSocketManager._internal();
  late IOWebSocketChannel _locationChannel;

  factory WebSocketManager() {
    return _singleton;
  }

  WebSocketManager._internal();

  void connectToLocationService() {
    _locationChannel = IOWebSocketChannel.connect('ws://localhost:8081/ws/location');
  }

  IOWebSocketChannel get locationChannel => _locationChannel;

}
