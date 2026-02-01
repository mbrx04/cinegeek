import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({bool isBackground = false}) async
  {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Il comando initialize deve contenere la logica del click
    await _notificationsPlugin.initialize
      (
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response)
      {
        if (response.payload == "at_cinema_auth")
        {
          print("Notifica Cinema cliccata! Autorizzo accesso...");
          // Qui andrebbe la logica Navigator.push se hai una chiave globale
        }
      },
    );

    print("[NotificationService] Inizializzato (Background: $isBackground)");

    if (!isBackground)
    {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null)
      {
        await androidImplementation.requestNotificationsPermission();
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'cinegeek_channel_id',
      'CineGeek Alerts',
      channelDescription: 'Notifiche di prossimità ai cinema',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload
    );
  }
}