import 'package:mechanic/config/route/app_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  final String serverUrl = AppRouter.main_domain;


  bool _isConnected = false;
  bool get isConnected => _isConnected;
  void Function(dynamic data)? onIncomingRescueRequest;
  void initializeSocket(String userId, {bool isMechanic = false}) {
    try {
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

      _setupListeners();

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

  void _setupListeners() {
    socket.on('result_subcribe', (data) {
      print('Subscription Result: ${data['message']}');
    });

    socket.on('incoming_rescue_request', (data) {
      print('Incoming Rescue Request: $data');
      onIncomingRescueRequest?.call(data);
     
    });
  }

  void acceptRescueRequest(String mechanicId, String requestId) {
    if (_isConnected) {
      socket.emit('accept_rescue_request', {
        'mechanicId': mechanicId,
        'requestId': requestId,
      });
    } else {
      print('Không thể gửi: Socket chưa kết nối.');
    }
  }
}
