// lib/presentation/screens/edit_profile_screen.dart
import 'dart:developer';

import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/presentation/new/screen/navigation/profile_screen/profile_screen.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _login;
  late UserModel _updated;

  @override
  void initState() {
    super.initState();
    _login = TextEditingController(text: widget.user.login);
    _updated = widget.user;
  }

  @override
  void dispose() {
    _login.dispose();
    super.dispose();
  }

  void _save() {
    _updated = widget.user.copyWith(login: _login.text.trim());
    Navigator.pop(context, _updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity, height: 50),
          Row(
            mainAxisAlignment: .center,
            children: [
              GestureDetector(
                onTap: () {
                  log("message");
                },
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColor.darkGrey,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      opacity: .5,
                      image: NetworkImage(widget.user.image),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit_rounded,
                      color: AppColor.accent,
                      size: 30,
                      shadows: [Shadow(blurRadius: 5)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ─── Поля ───
          Padding(
            padding: const .symmetric(horizontal: 16),
            child: CustomTextField(
              label: "логин",
              controller: _login,
              focusedBorderColor: AppColor.green,
            ),
          ),
          const Spacer(),

          // ─── Кнопки ───
          Row(
            spacing: 10,
            children: [
              const SizedBox(width: 6),
              Expanded(
                child: ProfileButton(
                  label: 'Отмена',
                  color: AppColor.darkGrey,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: ProfileButton(
                  label: 'Сохранить',
                  color: AppColor.greenBlue,
                  onTap: _save,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
