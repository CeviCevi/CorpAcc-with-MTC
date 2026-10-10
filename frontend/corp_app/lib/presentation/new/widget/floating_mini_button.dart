import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class FloatingMiniButton extends StatelessWidget {
  const new({super.key, required this.icon, this.onTap});
  final IconData icon;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: AppColor.surface.withAlpha(100),
            borderRadius: .circular(10),
          ),
          child: Center(
            child: Icon(icon, grade: 180, size: 20, color: AppColor.textMuted),
          ),
        ),
      ),
    );
  }
}
