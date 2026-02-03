import 'package:cinegeek/UI/pages/review.dart';
import 'package:cinegeek/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({bool isBackground = false}) async
  {

    //Inizializza i fusi orari -> è obbligatorio per notifiche schedulate
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Il comando initialize deve contenere la logica del click
    await _notificationsPlugin.initialize
      (
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == "daily_review_prompt"){
          navigatorKey.currentState?.push(
            MaterialPageRoute(
                builder: (_) => const ReviewsPage(),
            ),
          );
        }
      }
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

  //Notifica immediata
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

  // Programma una notifica ad un giorno specificato
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int weekday,
    String? payload,
}) async {
    final now = tz.TZDateTime.now(tz.local);

    //Imposta l'orario fisso alle 09:00
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9,
    );

    //Trova il prossimo giorno corretto
    while (scheduleDate.weekday != weekday || scheduleDate.isBefore(now)){
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'cinegeek_channel_id',
      'CineGeek Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleDate,
      const NotificationDetails(android: androidDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,

      //Ripete ogni settimana allo stesso giorno e ora
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  //Martedi/Mercoledi/Giovedi -> film visto la sera prima
  //lunedi -> film nel weekend

  Future<void> scheduleCineGeekReminders() async {
    //Rimuove eventuali notifiche duplicate
    await _notificationsPlugin.cancelAll();

    // Martedì, Mercoledì, Giovedì
    for (final day in [
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
    ]) {
      await scheduleWeeklyNotification(
        id: day,
        weekday: day,
        title: 'Hai visto un film ieri sera?',
        body: 'Scrivi una recensione su CineGeek 🎬',
        payload: 'daily_review_prompt',
      );
    }

    // Lunedì
    await scheduleWeeklyNotification(
      id: 10,
      weekday: DateTime.monday,
      title: 'Weekend cinematografico?',
      body: 'Hai visto qualche film nel weekend?',
      payload: 'daily_review_prompt',
    );
  }
}