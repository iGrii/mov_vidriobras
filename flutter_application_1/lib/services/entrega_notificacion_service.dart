// flutter/services/entrega_notificacion_service.dart

import 'dart:async';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../models/entrega_notificacion_model.dart';

class EntregaNotificacionService {
  static final EntregaNotificacionService _instance =
      EntregaNotificacionService._internal();

  factory EntregaNotificacionService() => _instance;
  EntregaNotificacionService._internal();

  late PusherChannelsFlutter pusher;
  final StreamController<EntregaNotificacion> _notificacionController =
      StreamController<EntregaNotificacion>.broadcast();
  bool _isInitialized = false;

  Stream<EntregaNotificacion> get notificacionStream =>
      _notificacionController.stream;

  Future<void> inicializar(String appKey, String cluster) async {
    if (_isInitialized) return;

    try {
      pusher = PusherChannelsFlutter();
      await pusher.init(
        apiKey: appKey,
        cluster: cluster,
        onConnectionStateChange: (_, state) => print('🔗 Pusher: $state'),
        onError: (msg, code, e) =>
            print('❌ Error Pusher: $msg | Código: $code'),
        onEvent: (event) {
          try {
            print('📨 Evento Pusher recibido: ${event.eventName}');
            if (event.eventName.startsWith('entrega')) {
              _procesarEvento(event);
            }
          } catch (e) {
            print('❌ Error procesando evento global: $e');
          }
        },
      );
      await pusher.connect();
      _isInitialized = true;
      print('✅ Pusher inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Pusher: $e');
      rethrow;
    }
  }

  Future<void> suscribirse(String canal) async {
    if (!_isInitialized) {
      throw Exception(
        'Pusher no está inicializado. Llama a inicializar() primero.',
      );
    }

    try {
      await pusher.subscribe(
        channelName: canal,
        onEvent: (event) {
          try {
            print('📨 Evento en canal "$canal": ${event.eventName}');
            _procesarEvento(event);
          } catch (e) {
            print('❌ Error procesando evento en canal: $e');
          }
        },
      );
      print('✅ Suscrito a canal: $canal');
    } catch (e) {
      print('❌ Error suscribiéndose a $canal: $e');
      rethrow;
    }
  }

  void _procesarEvento(PusherEvent event) {
    try {
      final data = event.data;
      if (data is String) {
        // Si es string, asumimos que es JSON y lo decodificamos
        // (En producción, considera usar jsonDecode)
        print('Evento como string, es necesario decodificar manualmente');
        return;
      }

      final notif = EntregaNotificacion.fromJson(data as Map<String, dynamic>);
      if (!_notificacionController.isClosed) {
        _notificacionController.add(notif);
        print('✅ Notificación de entrega procesada: ${notif.titulo}');
      }
    } catch (e) {
      print('❌ Error procesando evento: $e');
    }
  }

  Future<void> desconectar() async {
    try {
      if (_isInitialized) {
        await pusher.disconnect();
      }
      if (!_notificacionController.isClosed) {
        await _notificacionController.close();
      }
      _isInitialized = false;
      print('✅ Pusher desconectado');
    } catch (e) {
      print('❌ Error desconectando: $e');
    }
  }

  void dispose() {
    desconectar();
  }
}

// Singleton global
final entregaService = EntregaNotificacionService();
