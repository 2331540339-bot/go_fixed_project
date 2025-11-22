import 'package:flutter/material.dart';
import 'package:mechanic/config/themes/app_color.dart';

void showModalCancel(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => ShowModalCancel(
      message: 'Bạn có chắc muốn hủy bỏ yêu cầu này?',
      onConfirm: () {
        // Hành động được thực hiện SAU KHI người dùng nhấn 'Xác nhận'
        // Ví dụ: Quay về Trang A và xóa tất cả các trang khác (rất thường gặp)
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DetailPricePage(),
        //   ), // Thay TrangA() bằng Widget đích của bạn
        //   (Route<dynamic> route) => false, // Xóa tất cả route cũ
        // );

        // Hoặc chỉ quay lại trang trước:
        Navigator.pop(context); // Nếu bạn đang ở Trang C và muốn về Trang B
      },
    ),
  );
}

// Hàm gọi Modal Thành công
void showModalSuccess(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ShowModalSuccess(),
    barrierDismissible: true,
  );
}

void showModalConfirm(
  BuildContext context, {
  required String message,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => ShowModalCancel(
      message: message,
      onConfirm: onConfirm,
    ),
  );
}

class ShowModalCancel extends StatelessWidget {
  const ShowModalCancel({
    super.key,
    this.message = 'Bạn có chắc chắn muốn hủy chứ?',
    this.onConfirm,
  });
  final String message;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: 0,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.cancel, // Icon cho Hủy bỏ/Lỗi
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 25, color: Colors.white),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: <Widget>[
        Row(
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size(120, 40),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
            ),
            Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
                minimumSize: const Size(120, 40),
              ),
              onPressed: () {
                // Thực hiện hành động hủy bỏ ở đây
                Navigator.pop(context); // Đóng modal
                onConfirm?.call();
              },
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}

class ShowModalSuccess extends StatelessWidget {
  const ShowModalSuccess({
    super.key,
    this.title = 'Thao tác thành công!',
    this.message = 'Yêu cầu của bạn đã được xử lý xong.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.only(
        top: 20,
        left: 24,
        right: 24,
        bottom: 0,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.check_circle, // Icon cho Thành công
            color: Colors.green,
            size: 60,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Xác nhận'),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
    );
  }
}
