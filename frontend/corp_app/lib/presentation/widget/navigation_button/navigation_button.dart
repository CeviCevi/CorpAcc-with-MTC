import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback? onTap;
  final bool isActive;

  const new({
    super.key,
    required this.buttonName,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: .infinity,
        decoration: BoxDecoration(
          color: isActive ? AppColor.darkGrey : null,
          border: Border(bottom: BorderSide(color: AppColor.black)),
        ),
        child: Center(child: Text(buttonName)),
      ),
    );
  }
}
