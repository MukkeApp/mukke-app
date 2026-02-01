import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  // .env overrides (kein Secret, aber konfigurierbar)
  // Beispiele in .env:
  // JARVIZ_BASE_URL=http://localhost:5000
  // JARVIZ_WS_URL=ws://localhost:5000
  late final String _baseUrl = (dotenv.env['JARVIZ_BASE_URL']?.trim().isNotEmpty ?? false)
      ? dotenv.env['JARVIZ_BASE_URL']!.trim()
      : 'http://localhost:5000';

  late final String _wsBaseUrl = (dotenv.env['JARVIZ_WS_URL']?.trim().isNotEmpty ?? false)
      ? dotenv.env['JARVIZ_WS_URL']!.trim()
      : 'ws://localhost:5000';

  WebSocketChannel? _channel;
  final http.Client _httpClient = http.Client();

  Timer? _reconnectTimer;
  bool _disposed = false;

  // Singleton
  static final JarvizService _instance = JarvizService._internal();
  factory JarvizService() => _instance;
  JarvizService._internal();

  Uri _statusUri() => Uri.parse('$_baseUrl/api/status');
  Uri _chatUri() => Uri.parse('$_baseUrl/api/chat');
  Uri _modulesUri() => Uri.parse('$_baseUrl/api/modules');

  // Spec: bevorzugt /ws; Root kann serverseitig als Alias bestehen
  Uri _wsUriPreferWsPath() {
    final base = Uri.parse(_wsBaseUrl);
    // falls schon ein path gesetzt ist, behalten; sonst /ws anhängen
    final path = (base.path.isEmpty || base.path == '/') ? '/ws' : base.path;
    return base.replace(path: path);
  }

  // Verbindung testen
  Future<JarvizResult<bool>> testConnection() async {
    try {
      final response =
      await _httpClient.get(_statusUri()).timeout(const Duration(seconds: 5));
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
        _chatUri(),
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
      final response =
      await _httpClient.get(_modulesUri()).timeout(const Duration(seconds: 10));

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
    if (_disposed) return;

    try {
      _reconnectTimer?.cancel();

      final uri = _wsUriPreferWsPath();
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
            (message) {
          debugPrint('Jarviz WS: $message');
        },
        onError: (error) {
          debugPrint('Jarviz WS Fehler: $error');
        },
        onDone: () {
          debugPrint('Jarviz WS geschlossen');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('Jarviz WS Verbindungsfehler: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_disposed) return;
      connectWebSocket();
    });
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      _channel?.sink.close();
      _channel = null;
      _httpClient.close();
      debugPrint('JarvizService sauber beendet.');
    } catch (e) {
      debugPrint('Fehler beim Dispose: $e');
    }
  }
}
