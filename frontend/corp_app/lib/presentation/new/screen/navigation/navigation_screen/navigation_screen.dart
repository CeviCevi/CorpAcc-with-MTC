import 'dart:ui';

import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/presentation/new/screen/navigation/main_screen/main_screen.dart';
import 'package:corp_app/presentation/new/screen/navigation/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => NavigationScreenState();
}

class NavigationScreenState extends State<NavigationScreen> {
  final List<Widget> screens = [
    MainScreen(),
    Scaffold(),
    ProfileScreen(user: UserModel.empty),
  ];

  bool isActive = false;
  int screenNum = 0;

  bool _checkScreen(int thisScreen) {
    return thisScreen == screenNum;
  }

  void _rewriteScreen(int newScreen) {
    if (!_checkScreen(newScreen)) {
      setState(() => screenNum = newScreen);
    }
  }

  void _close() {
    setState(() => isActive = false);
  }

  Future<void> _rewriteAndClose(int newScreen) async {
    _rewriteScreen(newScreen);
    await Future.delayed(const Duration(milliseconds: 100));
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 2. Кнопка (сверху), уезжает при открытии
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: isActive ? -60 : 8,
            top: 8,
            child: AnimatedOpacity(
              opacity: isActive ? 0 : 1,
              duration: Duration(milliseconds: 100),
              child: IconButton(
                onPressed: () => setState(() => isActive = true),
                icon: const Icon(Icons.menu),
              ),
            ),
          ),
          Positioned.fill(
            top: 8,
            right: 8,
            left: 50,
            child: Row(
              mainAxisAlignment: .end,
              crossAxisAlignment: .start,
              children: [
                IconButton(
                  onPressed: () => _rewriteAndClose(2),
                  icon: const Icon(Icons.account_circle_rounded),
                ),
              ],
            ),
          ),

          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              child: SizedBox(
                height: AppConst.height,
                width: AppConst.width,
                child: Stack(
                  children: [
                    screens[0],
                    if (screenNum != 0) screens[screenNum],
                  ],
                ),
              ),
            ),
          ),

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
                  width: AppConst.width * .7,
                  decoration: const BoxDecoration(
                    color: AppColor.darkGrey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Хедер: назад + логотип ───
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 18, 8),
                          child: Row(
                            crossAxisAlignment: .center,
                            children: [
                              const SizedBox(width: 10),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(text: 'SpBr'),
                                    TextSpan(
                                      text: '.',
                                      style: TextStyle(color: AppColor.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Material(
                                color: AppColor.transparent,
                                child: InkWell(
                                  onTap: () => _close(),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: AppColor.surface.withAlpha(100),
                                      borderRadius: .circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 15,
                                        color: AppColor.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Column(
                          spacing: 0,
                          children: [
                            // ─── Пункты ───
                            NavItem(
                              label: 'Главная',
                              onTap: () => _rewriteAndClose(0),
                              isActive: _checkScreen(0),
                            ),
                            NavItem(
                              label: 'История',
                              onTap: () => _rewriteAndClose(1),
                              isActive: _checkScreen(1),
                            ),
                            NavItem(
                              label: 'Профиль',
                              onTap: () => _rewriteAndClose(2),
                              isActive: _checkScreen(2),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isActive ? 1 : 0,
                  duration: Duration(milliseconds: isActive ? 250 : 10),
                  curve: Curves.easeInBack,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: GestureDetector(
                        onTap: _close,

                        child: Container(
                          height: AppConst.height,
                          width: AppConst.width * .3,
                          color: AppColor.black.withAlpha(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColor.surface.withAlpha(100),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // полоска-индикатор слева
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    width: 3,
                    height: isActive ? 20 : 0,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColor.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColor.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
