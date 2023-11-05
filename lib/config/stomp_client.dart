import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompClientConfig {
  StompClientConfig({
    required this.port,
    required this.onConnect,
  });

  final int port;
  final void Function(StompFrame frame) onConnect;

  late StompClient client;

  StompClient connect() {
    final config = StompConfig(
      url: 'ws://192.168.56.1:$port/ws', // Replace with your microservice's WebSocket endpoint
      onConnect: onConnect, // Callback function for connection established
      onWebSocketError: (dynamic error) => print('$port ==> Error: $error'),
    );
    client = StompClient(config: config);
    client.activate();
    return client;
  }
}
