import 'dart:ui';

import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Панель (снизу)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: isActive ? 0 : -AppConst.width,
            height: AppConst.height,
            width: AppConst.width,
            child: Row(
              children: [
                Container(
                  height: AppConst.height,
                  width: AppConst.width * .5,
                  decoration: BoxDecoration(color: AppColor.black),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isActive ? 10 : 0,
                      sigmaY: isActive ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => isActive = false),
                      child: SizedBox(
                        height: AppConst.height,
                        width: AppConst.width * .5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Кнопка (сверху), уезжает при открытии
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: isActive ? -60 : 8,
            top: 8,
            child: IconButton(
              onPressed: () => setState(() => isActive = true),
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
    );
  }
}
