import 'package:mechanic/config/route/app_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  // **THAY ĐỔI ĐỊA CHỈ SERVER CỦA BẠN**
  final String serverUrl = AppRouter.main_domain;

  // Trạng thái kết nối
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

      // Lắng nghe các sự kiện cơ bản
      socket.onConnect((_) {
        print('Socket.IO: Connected');
        _isConnected = true;
        notifyListeners(); // Thông báo cho UI nếu dùng Provider/ChangeNotifier

        // Gửi sự kiện đăng ký ngay sau khi kết nối thành công
        _sendSubscriptionEvent(userId, isMechanic);
      });

      socket.onDisconnect((_) {
        print('Socket.IO: Disconnected');
        _isConnected = false;
        notifyListeners();
      });

      socket.onError((err) => print('Socket.IO Error: $err'));

      // Bắt đầu lắng nghe các sự kiện của server
      _setupListeners();

      socket.connect();
    } catch (e) {
      print('Socket connection failed: $e');
    }
  }

  void _sendSubscriptionEvent(String userId, bool isMechanic) {
    if (isMechanic) {
      // Sự kiện: subcribe_mechanic
      socket.emit('subcribe_mechanic', {'mechanicID': userId});
    } else {
      // Sự kiện: subscribe_user
      socket.emit('subscribe_user', userId);
    }
  }

  void disconnect() {
    socket.disconnect();
  }

  void _setupListeners() {
    // Lắng nghe kết quả đăng ký (chủ yếu cho thợ sửa)
    socket.on('result_subcribe', (data) {
      print('Subscription Result: ${data['message']}');
      // TODO: Xử lý UI
    });

    // Lắng nghe yêu cầu cứu hộ đến (Chỉ áp dụng cho ứng dụng Thợ)
    socket.on('incoming_rescue_request', (data) {
      print('Incoming Rescue Request: $data');
      onIncomingRescueRequest?.call(data);
     
    });
  }

  // Tùy chọn: Thêm hàm chấp nhận đơn ở đây (để gọi từ UI)
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
