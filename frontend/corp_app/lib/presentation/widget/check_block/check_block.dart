import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class CheckBlock extends StatelessWidget {
  const new({super.key, required this.text, this.isActive = false});
  final String text;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            borderRadius: .circular(5),
            border: .all(
              color: isActive ? AppColor.primary : AppColor.primaryDark,
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 15,
              weight: 2,
              color: AppColor.white.withAlpha(isActive ? 255 : 0),
            ),
          ),
        ),
        SizedBox(width: 15),
        Text(text),
      ],
    );
  }
}
