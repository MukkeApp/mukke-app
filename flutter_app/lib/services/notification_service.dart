// services/notification_service.dart

class NotificationService {
  /// Initialisiert den Notification Service
  /// Aktuell nur Log-Ausgabe, bis flutter_local_notifications eingebunden wird
  static Future<void> initialize() async {
    print('[NotificationService] Initialized (temporarily disabled)');
  }

  /// Zeigt eine lokale Benachrichtigung an
  /// Aktuell nur Log-Ausgabe
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('[NotificationService] Notification would appear → $title: $body');
    if (payload != null) {
      print('[NotificationService] Payload: $payload');
    }
  }
}
