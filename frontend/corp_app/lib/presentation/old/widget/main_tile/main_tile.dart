import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class MainTile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const new({super.key, this.child = const Center(), this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 300,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.grey),
        borderRadius: .circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            blurStyle: .outer,
            color: AppColor.black.withAlpha(100),
          ),
        ],
      ),
      child: child,
    );
  }
}
