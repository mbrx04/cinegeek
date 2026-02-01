import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:light/light.dart';
import 'notification_service.dart';

class AtCinemaService
{
  final _notifications = NotificationService();
  final _lightPlugin = Light();

  static const double _maxDist = 150.0;
  static const int _darkLimit = 20;

  Future<bool> shouldShowCinemaPage() async
  {
    try
    {
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      bool near = await _isNearCinema(p);
      if (!near) return false;

      if (Platform.isAndroid)
      {
        return await _isDarkRoom();
      }

      return true;
    }
    catch (e)
    {
      return false;
    }
  }

  Future<void> checkArrival() async
  {
    try
    {
      final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (await _isNearCinema(p))
      {
        if (Platform.isAndroid)
        {
          bool dark = await _isDarkRoom();
          if (!dark) return;
        }

        await _notifications.showNotification
          (
            id: 777,
            title: "Sei in sala? 🍿",
            body: "Segna subito cosa stai guardando!",
            payload: "at_cinema_auth"
        );
      }
    }
    catch (e)
    {
      print("Errore check cinema: $e");
    }
  }

  Future<bool> _isNearCinema(Position pos) async
  {
    try
    {
      final raw = await rootBundle.loadString('assets/file_json/cinema.json');
      final List list = json.decode(raw);

      for (var c in list)
      {
        double d = Geolocator.distanceBetween(pos.latitude, pos.longitude, c['lat'], c['lng']);
        if (d < _maxDist) return true;
      }
    }
    catch (_) {}
    return false;
  }

  Future<bool> _isDarkRoom() async
  {
    try
    {
      final lux = await _lightPlugin.lightSensorStream.first.timeout
        (
          const Duration(milliseconds: 1500),
          onTimeout: () => 100
      );

      return lux >= 0 && lux < _darkLimit;
    }
    catch (e)
    {
      return false;
    }
  }
}