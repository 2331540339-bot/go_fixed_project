import 'package:flutter/material.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/product.dart';
import 'package:mobile/presentation/controller/cart_controller.dart';
import 'package:mobile/presentation/controller/product_controller.dart';
import 'package:mobile/presentation/view/store/store_cart_page.dart';
import 'package:mobile/presentation/view/store/store_payment_page.dart';
import 'package:provider/provider.dart';

class StoreDetailPage extends StatefulWidget {
  const StoreDetailPage({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final String productId;
  final Product? initialProduct;

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  ProductController? _productCtrl;
  Product? _product;
  bool _loading = false;
  String? _error;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.initialProduct;
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _productCtrl ??= await ProductController.create();
      final detail = await _productCtrl!.loadDetail(widget.productId);
      if (!mounted) return;
      if (detail != null) {
        setState(() {
          _product = detail;
          _imageIndex = 0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _productCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return Scaffold(
      appBar: AppBar(title: Text(product?.name ?? 'Chi tiết sản phẩm')),
      body: SafeArea(child: _buildBody(product)),
      bottomNavigationBar: _buildBottomBar(product),
    );
  }

  Widget _buildBody(Product? product) {
    if (_loading && product == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Không thể tải sản phẩm.\n${_error!}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProduct,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImages(product),
          const SizedBox(height: 16),
          Text(
            product?.name ?? 'Đang tải...',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                product != null
                    ? '${product.price.toStringAsFixed(0)} VND'
                    : '...',
                style: const TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              if (product != null)
                Text(
                  product.stock > 0 ? 'Còn ${product.stock}' : 'Hết hàng',
                  style: TextStyle(
                    color: product.stock > 0
                        ? Colors.black54
                        : Colors.red.shade400,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product?.description?.trim().isNotEmpty == true
                ? product!.description!
                : 'Chưa có mô tả cho sản phẩm này.',
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(Product? product) {
    final images = product?.images ?? const <String>[];
    if (images.isEmpty) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            onPageChanged: (i) => setState(() => _imageIndex = i),
            itemCount: images.length,
            itemBuilder: (_, index) {
              final url = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _imageIndex ? AppColor.primaryColor : Colors.grey,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(Product? product) {
    final soldOut = (product?.stock ?? 0) <= 0;
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
            decoration: BoxDecoration(
              color: const Color.fromARGB(164, 63, 142, 76),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.chat, color: Colors.white),
                const VerticalDivider(color: Colors.black, thickness: 1),
                IconButton(
                  onPressed: product == null
                      ? null
                      : () {
                          if ((product.stock) <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sản phẩm đã hết hàng'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          final cart = context.read<CartController>();
                          cart.addProduct(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Đã thêm vào giỏ hàng'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Xem giỏ',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const StoreCartPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.card_travel, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: double.infinity,
              child: TextButton(
                onPressed: soldOut
                    ? null
                    : () {
                        if (product == null) return;
                        final cart = context.read<CartController>();
                        cart.addProduct(product);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const StorePaymentPage(),
                          ),
                        );
                      },
                style: TextButton.styleFrom(
                  backgroundColor: soldOut
                      ? Colors.grey.shade400
                      : AppColor.primaryColor,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  // nếu muốn nút fill full không chừa padding:
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  soldOut ? 'Hết hàng' : 'Mua ngay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
