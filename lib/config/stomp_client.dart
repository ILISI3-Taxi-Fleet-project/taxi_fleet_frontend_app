import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class StompClientConfig {
  StompClientConfig({
    required this.port,
    required this.serviceName,
    required this.onConnect,
    this.userId,
  });

  final int port;
  final String? userId;
  final String serviceName;
  final void Function(StompFrame frame) onConnect;

  late StompClient client;

  StompClient connect() {
    final config = StompConfig(
      url: 'ws://10.235.1.29:$port/$serviceName/ws', // Replace with your microservice's WebSocket endpoint
      onConnect: onConnect, // Callback function for connection established
      onWebSocketError: (dynamic error) => print('$port ==> Error: $error'),
      stompConnectHeaders: userId != null ? {'userId': userId as String} : {},
    );
    client = StompClient(config: config);
    client.activate();
    return client;
  }
}
