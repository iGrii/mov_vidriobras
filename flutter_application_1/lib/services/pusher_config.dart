import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer';

class PusherConfig {
  // Instancia única (Singleton) según la documentación oficial
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(PusherEvent) onEventTriggered,
  }) async {
    try {
      await pusher.init(
        apiKey: "7a1b11d5566b38ad05e6",
        cluster: "mt1",
        onConnectionStateChange: (currentState, previousState) {
          log("Conexión: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          log("Error Pusher: $message (Código: $code)");
        },
        onEvent: (PusherEvent event) {
          log("Evento recibido en canal general: ${event.eventName}");
          // Permite escuchar todos los eventos con '*' o un evento puntual.
          if (eventName == '*' || event.eventName == eventName) {
            onEventTriggered(event);
          }
        },
        onSubscriptionSucceeded: (channel, data) {
          log("Suscrito con éxito a: $channel");
        },
      );

      // Suscribirse al canal específico después de inicializar
      await pusher.subscribe(channelName: channelName);
      await pusher.connect();
    } catch (e) {
      log("Error al inicializar Pusher: $e");
    }
  }

  void disconnect() {
    pusher.disconnect();
  }
}
