//logica per la gestione del weekend
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';

class WeekendContextManager {
  final NotificationService _notificationService = NotificationService();
  
  List<dynamic> cinemas = [];

  static DateTime? _lastNotificationTime;

  Future<void> init({bool isBackground = false}) async {
    await _notificationService.init(isBackground: isBackground);
    await _loadCinemasFromFile();
    await _checkWeekendProximity(isBackground: isBackground);
  }

  Future<void> _loadCinemasFromFile() async {
    try {
      final String response = await rootBundle.loadString('assets/file_json/cinema.json');
      cinemas = json.decode(response);
      print("[WeekendManager] Caricati ${cinemas.length} cinema dal json.");
    } catch (e) {
      print("[WeekendManager] Errore nel caricamento del json: $e");
      cinemas = [
        {"name": "Unical Fallback", "lat": 39.362240, "lng": 16.225433}
      ];
    }
  }

  Future<void> _checkWeekendProximity({bool isBackground = false}) async {
    print("--- [WeekendManager] inizio controllo per le notifiche (Background: $isBackground) ---");

    if (_lastNotificationTime != null) {
      final difference = DateTime.now().difference(_lastNotificationTime!);
      if (difference.inMinutes < 30) {
        print("[WeekendManager] no spam, ultima notifica mandata${difference.inMinutes} minuti fa.");
        return;
      }
    }
    
    final DateTime now = DateTime.now();
    bool isWeekend = now.weekday >= 5;

    if (!isWeekend) { //se non è weekend nemmeno prova ad inviare la notifica o chiedere la posizione
      print("[WeekendManager] non è weekend.");
      return; 
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      if (isBackground) {
        print("[WeekendManager] niente permessi per gps. Quitto");
        return;
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    print("[WeekendManager] posizione attuale: ${userPosition.latitude}, ${userPosition.longitude}");

    String? nearestCinemaName;
    double minDistance = double.infinity; 
    double threshold = 1500; //1.5km

    for (var cinema in cinemas) {
      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        cinema['lat'],
        cinema['lng'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        if (distance < threshold) {
          nearestCinemaName = cinema['name'];
        }
      }
    }

    if (nearestCinemaName != null) {
      print("📍 TROVATO: $nearestCinemaName");  //stampa nel terminale
      await _notificationService.showNotification(  //notifica vera sul dispsositivo
        id: 100,
        title: "È tempo di Cinema! 🍿",
        body: "Sei vicino al $nearestCinemaName. Che ne dici di un bel film?",
      );
      _lastNotificationTime = DateTime.now();
    } else {
      print("[WeekendManager] Nessun cinema vicino.");
    }
  }
}