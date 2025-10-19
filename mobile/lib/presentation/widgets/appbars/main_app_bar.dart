// lib/presentation/widgets/appbars/main_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/config/themes/app_color.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({
    super.key,
    required this.logo,
    required this.name,
    this.loadingName = false,
    this.location,
    this.onAvatarTap,
    this.avatarWidget,
    this.toolbarHeight,
    this.leadingWidth,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.trailingSpacing = 10.0,
  });

  /// Logo asset (Image.asset hoặc bất kỳ widget)
  final Widget logo;

  /// Tên hiển thị ở góc phải
  final String name;

  /// Đang tải tên?
  final bool loadingName;

  /// Dòng location nhỏ bên dưới (tuỳ chọn)
  final String? location;

  /// Bấm vào avatar (tuỳ chọn)
  final VoidCallback? onAvatarTap;

  /// Tuỳ biến avatar (nếu không truyền, dùng CircleAvatar rỗng)
  final Widget? avatarWidget;

  /// Chiều cao toolbar (mặc định 80.h)
  final double? toolbarHeight;

  /// Rộng leading (mặc định 80.h)
  final double? leadingWidth;

  /// Màu nền & elevation
  final Color backgroundColor;
  final double elevation;

  /// Khoảng cách giữa username và avatar
  final double trailingSpacing;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? 80.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight ?? 80.h,
      leadingWidth: leadingWidth ?? 80.h,
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.r),
        child: Align(alignment: Alignment.centerLeft, child: logo),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UserHead(
                name: name,
                loading: loadingName,
                location: location,
              ),
              SizedBox(width: trailingSpacing.w),
              _UserAvatar(
                onTap: onAvatarTap,
                child: avatarWidget,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserHead extends StatelessWidget {
  const _UserHead({
    required this.name,
    required this.loading,
    this.location,
  });

  final String name;
  final bool loading;
  final String? location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hello, ',
              style: theme.bodyMedium?.copyWith(
                color: AppColor.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            if (loading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColor.textColor,
                  fontSize: 14.sp,
                ),
              ),
          ],
        ),
        if (location != null) SizedBox(height: 4.h),
        if (location != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 16.h, color: AppColor.primaryColor,),
              SizedBox(width: 4.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 160.w),
                child: Text(
                  location!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall?.copyWith(fontSize: 12.sp, color: AppColor.textColor),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({this.onTap, this.child});
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final avatar = child ??
        const CircleAvatar(
          radius: 16,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.person, size: 18),
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 2.5, color: AppColor.primaryColor),
        ),
        child: avatar,
      ),
    );
  }
}
