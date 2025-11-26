import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/remote/order_api.dart';
import 'package:mobile/data/remote/payment_api.dart';
import 'package:mobile/presentation/controller/cart_controller.dart';
import 'package:mobile/presentation/controller/user_controller.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StorePaymentPage extends StatefulWidget {
  const StorePaymentPage({super.key});

  @override
  State<StorePaymentPage> createState() => _StorePaymentPageState();
}

class _StorePaymentPageState extends State<StorePaymentPage> {
  UserController? _userCtrl;
  bool _loadingUser = false;
  String? _userError;
  final TextEditingController _nameCtrl =
      TextEditingController(text: 'Nguyễn Văn A');
  final TextEditingController _phoneCtrl =
      TextEditingController(text: '0909 000 000');
  final TextEditingController _addressCtrl =
      TextEditingController(text: 'Địa chỉ nhận hàng');
  final TextEditingController _noteCtrl = TextEditingController();

  String _paymentMethod = 'cod';
  bool _submitting = false;

  double get _shippingFee => 30000;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _loadingUser = true;
      _userError = null;
    });
    try {
      _userCtrl ??= await UserController.create();
      final user = await _userCtrl!.getProfile();
      if (user != null) {
        _nameCtrl.text = user.fullname;
        if (user.phone.isNotEmpty) _phoneCtrl.text = user.phone;
        
      }
    } catch (e) {
      _userError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loadingUser = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final items = cart.items;
    final isEmpty = items.isEmpty;
    final subtotal = cart.totalPrice;
    final total = subtotal + (isEmpty ? 0 : _shippingFee);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: const Text('Thanh toán')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingUser)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              if (_userError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Không thể tải thông tin người dùng: $_userError',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _SectionCard(
                title: 'Thông tin giao hàng',
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Họ và tên',
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Số điện thoại',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    _LabeledField(
                      label: 'Địa chỉ',
                      controller: _addressCtrl,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Ghi chú',
                child: _LabeledField(
                  label: 'Lời nhắn cho người bán',
                  controller: _noteCtrl,
                  maxLines: 3,
                  hint: 'Ví dụ: Giao giờ hành chính, gọi trước 15 phút...',
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Sản phẩm',
                child: isEmpty
                    ? const Text('Giỏ hàng trống.')
                    : Column(
                        children: [
                          for (final item in items) ...[
                            _ProductRow(item: item),
                            if (item != items.last)
                              const Divider(height: 16, thickness: 1),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Phương thức thanh toán',
                child: Column(
                  children: [
                    _PaymentTile(
                      value: 'cod',
                      groupValue: _paymentMethod,
                      title: 'Thanh toán khi nhận hàng (COD)',
                      subtitle: 'Phí thu hộ đã bao gồm trong phí vận chuyển',
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v ?? 'cod'),
                    ),
                    const Divider(),
                    _PaymentTile(
                      value: 'bank',
                      groupValue: _paymentMethod,
                      title: 'Chuyển khoản ngân hàng',
                      subtitle: 'Ngân hàng nội địa/QR',
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v ?? 'cod'),
                    ),
                    const Divider(),
                    _PaymentTile(
                      value: 'wallet',
                      groupValue: _paymentMethod,
                      title: 'Ví điện tử',
                      subtitle: 'MoMo / ZaloPay',
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v ?? 'cod'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Tóm tắt đơn hàng',
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Tạm tính',
                      value: '${subtotal.toStringAsFixed(0)} VND',
                    ),
                    const SizedBox(height: 8),
                    _SummaryRow(
                      label: 'Phí vận chuyển',
                      value: isEmpty
                          ? '0 VND'
                          : '${_shippingFee.toStringAsFixed(0)} VND',
                    ),
                    const Divider(height: 24, thickness: 1),
                    _SummaryRow(
                      label: 'Tổng thanh toán',
                      value: '${total.toStringAsFixed(0)} VND',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    '${total.toStringAsFixed(0)} VND',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isEmpty || _submitting
                    ? null
                    : () => _handlePlaceOrder(context, cart, total),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Đặt hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    BuildContext context,
    CartController cart,
    double total,
  ) async {
    final items = cart.items;
    if (items.isEmpty) return;

    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    // Đảm bảo đã có UserController & token
    _userCtrl ??= await UserController.create();
    final token = _userCtrl!.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập trước khi đặt hàng.'),
        ),
      );
      return;
    }

    // Map phương thức thanh toán theo backend
    String methodForServer;
    switch (_paymentMethod) {
      case 'bank':
        methodForServer = 'banking';
        break;
      case 'wallet':
        methodForServer = 'momo';
        break;
      case 'cod':
      default:
        methodForServer = 'cod';
    }

    // Map cart items -> payload backend
    final payloadItems = items
        .map((e) => {
              'product_id': e.productId,
              'quantity': e.quantity,
              'price': e.price,
            })
        .toList();

    setState(() {
      _submitting = true;
    });

    try {
      final orderApi = OrderApi(HttpClientSingleton.client);
      final orderRes = await orderApi.createOrder(
        items: payloadItems,
        paymentMethod: methodForServer,
        shippingAddress: address,
        authToken: token,
      );

      final order = orderRes['order'] ?? orderRes;
      final orderId =
          (order['_id'] ?? order['id'] ?? order['order_id'])?.toString();

      if (orderId == null || orderId.isEmpty) {
        throw Exception('Không nhận được mã đơn hàng từ server');
      }

      // Nếu COD: không cần thanh toán online
      if (methodForServer == 'cod') {
        cart.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!')),
        );
        Navigator.of(context).pop(); // quay lại giỏ hàng
        return;
      }

      // Online payment: gọi VNPay
      final paymentApi = PaymentApi(HttpClientSingleton.client);
      final paymentUrl = await paymentApi.createVnPayPaymentUrl(
        amount: total,
        orderId: orderId,
      );

      if (!mounted) return;
      // Ở đây, để đơn giản, hiển thị URL thanh toán.
      // Bạn có thể tích hợp url_launcher để mở trình duyệt ngoài.
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thanh toán online'),
          content: SelectableText(
            'Vui lòng mở link sau để thanh toán:\n\n$paymentUrl',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

/// Dùng chung một http.Client cho OrderApi / PaymentApi để tránh tạo nhiều instance.
class HttpClientSingleton {
  static final client = http.Client();
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    required this.onChanged,
  });

  final String value;
  final String groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: Colors.black54),) : null,
      activeColor: AppColor.primaryColor,
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: item.image != null
              ? Image.network(
                  item.image!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                )
              : Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'x${item.quantity}',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(item.price * item.quantity).toStringAsFixed(0)} VND',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 15,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style.copyWith(color: AppColor.primaryColor)),
      ],
    );
  }
}
