import 'package:flutter/material.dart';
import 'package:mobile/config/router/app_router.dart';
import 'package:mobile/presentation/view/start/main_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  final String serverUrl = AppRouter.main_domain;
  BuildContext? _navContext;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void Function(Map<String, dynamic> data)? onAcceptedStatusRescue;

  void initializeSocket(
    String userId, {
    bool isMechanic = false,
    BuildContext? context,
  }) {
    try {
      _navContext = context;
      socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      socket.onConnect((_) {
        print('Socket.IO: Connected');
        _isConnected = true;
        notifyListeners();

        _sendSubscriptionEvent(userId, isMechanic);
      });

      socket.onDisconnect((_) {
        print('Socket.IO: Disconnected');
        _isConnected = false;
        notifyListeners();
      });

      socket.onError((err) => print('Socket.IO Error: $err'));

      socket.on('accepted-status-rescue', (data) {
        if (kDebugMode) {
          print('EVENT accepted-status-rescue: $data');
        }
        if (data is Map && onAcceptedStatusRescue != null) {
          onAcceptedStatusRescue!(Map<String, dynamic>.from(data));
          if (_navContext != null) {
            Navigator.of(_navContext!).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Mainscreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            debugPrint('SocketService: thiếu context, không thể điều hướng.');
          }
        }
      });

      socket.connect();
    } catch (e) {
      print('Socket connection failed: $e');
    }
  }

  void _sendSubscriptionEvent(String userId, bool isMechanic) {
    if (isMechanic) {
      socket.emit('subcribe_mechanic', {'mechanicID': userId});
    } else {
      socket.emit('subscribe_user', userId);
    }
  }

  void disconnect() {
    socket.disconnect();
  }
}
