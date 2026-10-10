// lib/presentation/screens/profile_screen.dart
import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const new({super.key, required this.user});

  final UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: .center,
        children: [
          SizedBox(width: .infinity),
          Container(
            height: 120,
            width: AppConst.width - 48,
            padding: const .symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: AppColor.surface,
              borderRadius: .circular(15),
            ),
            child: Row(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: .circular(100),
                    color: AppColor.darkGrey,
                  ),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      widget.user.login,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: .w500,
                        color: AppColor.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "id: ${widget.user.id}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: .w500,
                        color: AppColor.textMuted.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
