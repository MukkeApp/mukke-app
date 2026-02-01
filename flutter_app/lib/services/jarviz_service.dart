import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

// Exception-Klassen
class JarvizException implements Exception {
  final String message;
  final int? statusCode;
  JarvizException(this.message, {this.statusCode});
}

// Result-Wrapper
class JarvizResult<T> {
  final T? data;
  final String? error;
  final bool success;

  JarvizResult.success(this.data)
      : error = null,
        success = true;

  JarvizResult.failure(this.error)
      : data = null,
        success = false;
}

class JarvizService {
  static const String baseUrl = 'http://localhost:5000';
  static const String wsUrl = 'ws://localhost:5000';

  WebSocketChannel? _channel;
  final http.Client _httpClient = http.Client();

  // Singleton
  static final JarvizService _instance = JarvizService._internal();
  factory JarvizService() => _instance;
  JarvizService._internal();

  // Verbindung testen
  Future<JarvizResult<bool>> testConnection() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/status'))
          .timeout(const Duration(seconds: 5));

      return JarvizResult.success(response.statusCode == 200);
    } catch (e) {
      return JarvizResult.failure('Verbindungsfehler: $e');
    }
  }

  // Command senden
  Future<JarvizResult<String>> sendCommand(
    String command, {
    String? userId,
    String? projectId,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'message': command,
              'user_id': userId ?? 'default',
              'project_id': projectId ?? 'default',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return JarvizResult.success(data['response'] ?? 'Keine Antwort');
      }

      return JarvizResult.failure('Fehler: ${response.statusCode}');
    } catch (e) {
      return JarvizResult.failure('Fehler: $e');
    }
  }

  // Module Status
  Future<JarvizResult<Map<String, dynamic>>> getModules() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/api/modules'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return JarvizResult.success(json.decode(response.body));
      }

      return JarvizResult.failure('Fehler beim Abrufen der Module');
    } catch (e) {
      return JarvizResult.failure('Fehler: $e');
    }
  }

  // WebSocket verbinden
  void connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          print('WebSocket Nachricht: $message');
        },
        onError: (error) {
          print('WebSocket Fehler: $error');
        },
        onDone: () {
          print('WebSocket geschlossen');
          // Automatische Wiederverbindung nach 5 Sekunden
          Future.delayed(const Duration(seconds: 5), connectWebSocket);
        },
      );
    } catch (e) {
      print('WebSocket Verbindungsfehler: $e');
    }
  }

  void dispose() {
    try {
      _channel?.sink.close();
      _channel = null;
      _httpClient.close();
      print('JarvizService sauber beendet.');
    } catch (e) {
      print('Fehler beim Dispose: $e');
    }
  }
}
