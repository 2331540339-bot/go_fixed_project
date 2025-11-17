import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.images,                 // List<String> asset hoặc url
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.onTap,
    this.onIndexChanged,
    this.height = 180,                    // cho custom chiều cao
    this.viewportFraction = 0.9,          // lộ viền hai bên
    this.borderRadius = 16,
  });

  final List<String> images;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final void Function(int index)? onTap;
  final ValueChanged<int>? onIndexChanged;
  final double height;
  final double viewportFraction;
  final double borderRadius;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pc;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: widget.viewportFraction, keepPage: true);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.images.length != widget.images.length) {
      _stopTimer();
      _startTimer();
    }
  }

  void _startTimer() {
    if (!widget.autoPlay || widget.images.isEmpty) return;
    _timer ??= Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || widget.images.isEmpty) return;
      final next = (_index + 1) % widget.images.length;
      if (_pc.hasClients) {
        _pc.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images;
    if (imgs.isEmpty) return const SizedBox.shrink();

    return Listener(
      onPointerDown: (_) => _stopTimer(),  // dừng khi user kéo
      onPointerUp: (_) => _startTimer(),   // chạy lại sau khi thả
      child: SizedBox(
        height: widget.height.h,
        child: PageView.builder(
          controller: _pc,
          itemCount: imgs.length,
          onPageChanged: (i) {
            _index = i;
            widget.onIndexChanged?.call(i);
            setState(() {});
          },
          itemBuilder: (_, i) {
            final src = imgs[i];
            final isNetwork = src.startsWith('http');
            final image = isNetwork
                ? Image.network(src, fit: BoxFit.cover, width: double.infinity)
                : Image.asset(src, fit: BoxFit.cover, width: double.infinity);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: () => widget.onTap?.call(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius.r),
                  child: image,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
