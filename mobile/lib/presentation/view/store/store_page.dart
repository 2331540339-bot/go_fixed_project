import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/config/themes/app_color.dart';
import 'package:mobile/data/model/catalog.dart';
import 'package:mobile/data/model/product.dart';
import 'package:mobile/presentation/controller/banner_controller.dart';
import 'package:mobile/presentation/controller/catalog_controller.dart';
import 'package:mobile/presentation/controller/product_controller.dart';
import 'package:mobile/presentation/widgets/banner/banner_carousel.dart';
import 'package:mobile/presentation/widgets/banner/dots_indicator.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  BannerController? _bannerCtrl;
  CatalogController? _catalogCtrl;
  ProductController? _productCtrl;
  int _bannerIndex = 0;
  String? _selectedCatalogId;
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    _bannerCtrl = await BannerController.create();
    _catalogCtrl = await CatalogController.create();
    _productCtrl = await ProductController.create();

    if (!mounted) return;
    _bannerCtrl!.addListener(_onBannerChanged);
    _catalogCtrl!.addListener(_onCatalogChanged);
    _productCtrl!.addListener(_onProductChanged);
    await _bannerCtrl!.load();
    await _catalogCtrl!.load();
    await _productCtrl!.load();
  }

  void _onBannerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onCatalogChanged() {
    if (!mounted) return;
    setState(() {});
  }
  void _onProductChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _bannerCtrl?.removeListener(_onBannerChanged);
    _bannerCtrl?.dispose();
    _catalogCtrl?.removeListener(_onCatalogChanged);
    _catalogCtrl?.dispose();
    _productCtrl?.removeListener(_onProductChanged);
    _productCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingBanners = _bannerCtrl?.loading ?? true;
    final bannerError = _bannerCtrl?.error;
    final bannerItems = _bannerCtrl?.items ?? const [];
    final loadingCatalogs = _catalogCtrl?.loading ?? true;
    final catalogError = _catalogCtrl?.error;
    final catalogItems = _catalogCtrl?.items ?? const <Catalog>[];
    final loadingProducts = _productCtrl?.loading ?? true;
    final productError = _productCtrl?.error;
    final productItems = _productCtrl?.items ?? const <Product>[];
    final filteredProducts = (_selectedCatalogId == null)
        ? productItems
        : productItems
            .where((p) => (p.category ?? p.id) == _selectedCatalogId)
            .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Store Page')),
      body: Column(
        children: [
          SizedBox(height: 30.h),
          if (loadingBanners)
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (bannerError != null)
            Text('Lỗi banner: $bannerError')
          else if (bannerItems.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(child: Text('Chưa có banner nào được đăng tải.')),
            )
          else
            Column(
              children: [
                BannerCarousel(
                  images: bannerItems.map((e) => e.imageUrl).toList(),
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  onIndexChanged: (i) => setState(() => _bannerIndex = i),
                  onTap: (i) {},
                ),
                SizedBox(height: 10.h),
                DotsIndicator(count: bannerItems.length, index: _bannerIndex),
              ],
            ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  'Danh mục',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildCatalogRow(
                loadingCatalogs: loadingCatalogs,
                catalogError: catalogError,
                catalogItems: catalogItems,
                selectedId: _selectedCatalogId,
                onSelect: (id) {
                  setState(() {
                    _selectedCatalogId = id;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text(
                  'Sản phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildProductGrid(
                loading: loadingProducts,
                error: productError,
                products: filteredProducts,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogRow({
    required bool loadingCatalogs,
    required String? catalogError,
    required List<Catalog> catalogItems,
    required String? selectedId,
    required ValueChanged<String?> onSelect,
  }) {
    if (loadingCatalogs) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalogError != null) {
      return Center(child: Text('Lỗi danh mục: $catalogError'));
    }
    if (catalogItems.isEmpty) {
      return const Center(child: Text('Chưa có danh mục nào.'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: catalogItems.length + 1,
      separatorBuilder: (_, __) => SizedBox(width: 10.w),
      itemBuilder: (context, index) {
        // index 0: tất cả
        if (index == 0) {
          final isSelected = selectedId == null;
          return _CatalogChip(
            label: 'Tất cả',
            selected: isSelected,
            onTap: () => onSelect(null),
          );
        }
        final catalog = catalogItems[index - 1];
        final isSelected = selectedId == catalog.id;
        return _CatalogChip(
          label: catalog.catalogName,
          selected: isSelected,
          onTap: () => onSelect(catalog.id),
        );
      },
    );
  }

  Widget _buildProductGrid({
    required bool loading,
    required String? error,
    required List<Product> products,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Lỗi sản phẩm: $error'));
    }
    if (products.isEmpty) {
      return const Center(child: Text('Chưa có sản phẩm.'));
    }

    return GridView.builder(
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final p = products[index];
        final img = (p.images != null && p.images!.isNotEmpty)
            ? p.images!.first
            : null;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: img != null
                    ? Image.network(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Center(child: Icon(Icons.broken_image)),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image)),
                      ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Text(
                  p.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Text(
                  '${p.price.toStringAsFixed(0)} VND',
                  style: TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Text(
                  p.stock > 0 ? 'Còn ${p.stock}' : 'Hết hàng',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CatalogChip extends StatelessWidget {
  const _CatalogChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? AppColor.primaryColor : Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
