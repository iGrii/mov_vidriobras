import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:dio/dio.dart';

class OneSignalService {
  static const String oneSignalAppId = '7b9b3e64-e5f0-4bde-a32d-0582185b0b33';
  static const String backendUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://31.220.56.109:5000',
  );

  /// Initialize OneSignal and register device for push notifications
  Future<void> initialize() async {
    try {
      debugPrint('[OneSignalService] Iniciando OneSignal...');

      // Initialize OneSignal
      OneSignal.initialize(oneSignalAppId);
      debugPrint('[OneSignalService] backendUrl=$backendUrl');

      // Request user permission for notifications (iOS)
      OneSignal.Notifications.requestPermission(true);

      // Listen for notifications
      OneSignal.Notifications.addForegroundWillDisplayListener((notification) {
        debugPrint(
          '[OneSignal] Notificación recibida en foreground: ${notification.notification.title}',
        );
        // Supabase realtime ya maneja los updates, esto es solo para notificaciones visuales
      });

      // El Player ID puede tardar algunos segundos en estar disponible.
      await _registerPlayerIdConReintentos();

      debugPrint('[OneSignalService] OneSignal inicializado exitosamente');
    } catch (e) {
      debugPrint('[OneSignalService] Error inicializando OneSignal: $e');
    }
  }

  Future<void> _registerPlayerIdConReintentos() async {
    for (var intento = 1; intento <= 8; intento++) {
      final playerId = OneSignal.User.pushSubscription.id;
      if (playerId != null && playerId.isNotEmpty) {
        debugPrint(
          '[OneSignalService] Player ID listo en intento $intento: $playerId',
        );
        await _savePlayerIdToBackend(playerId);
        return;
      }
      debugPrint(
        '[OneSignalService] Player ID no disponible (intento $intento), reintentando...',
      );
      await Future.delayed(const Duration(seconds: 2));
    }
    debugPrint(
      '[OneSignalService] No se pudo obtener Player ID tras varios intentos',
    );
  }

  /// POST player ID to backend
  Future<void> _savePlayerIdToBackend(String playerId) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '$backendUrl/api/uno-signal/registrar-player-id',
        data: {'player_id': playerId, 'dispositivo': 'flutter'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          '[OneSignalService] Player ID registrado en backend: $playerId',
        );
      } else {
        debugPrint(
          '[OneSignalService] Error al registrar Player ID: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[OneSignalService] Error guardando Player ID en backend: $e');
    }
  }

  /// Debug: Get all registered Player IDs from backend
  static Future<List<String>> debugGetAllPlayerIds() async {
    try {
      final dio = Dio();
      final response = await dio.get('$backendUrl/api/uno-signal/player-ids');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final playerIds = List<String>.from(data['player_ids'] ?? []);
        return playerIds;
      }
    } catch (e) {
      debugPrint('[OneSignalService] Error obteniendo Player IDs: $e');
    }
    return [];
  }
}
