// lib/presentation/screens/profile_screen.dart
import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/app/data_service.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/presentation/new/screen/navigation/profile_screen/edit_profile_screen.dart';
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
          SizedBox(width: AppConst.width, height: 5),

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
                    image: DecorationImage(
                      fit: .cover,
                      image: NetworkImage(widget.user.image),
                    ),
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
                        color: AppColor.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 15),
          ProfileBox(label: widget.user.email, boxName: "почта"),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ProfileBox(
                  label: DateService.dateParser(widget.user.createAt),
                  boxName: "дата создания",
                  margin: const .only(left: 16, right: 5),
                ),
              ),
              Expanded(
                child: ProfileBox(
                  label: widget.user.role,
                  boxName: "роль",
                  margin: const .only(right: 16, left: 5),
                ),
              ),
            ],
          ),

          SizedBox(height: 70),
          Row(
            spacing: 10,
            children: [
              SizedBox(width: 6),
              Expanded(
                child: ProfileButton(
                  label: "Редактировать",
                  color: AppColor.greenBlue,
                  onTap: () async {
                    final updated = await Navigator.push<UserModel>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(user: widget.user),
                      ),
                    );
                    if (updated != null) {
                      setState(() {
                        //widget.user = updated;
                      });
                      // TODO: DatabaseService.instance.upsertUser(updated)
                      // TODO: UserService.updateMyAcc(user: updated)
                    }
                  },
                ),
              ),
              Expanded(child: ProfileButton(label: "Выйти")),
              SizedBox(width: 6),
            ],
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const new({
    super.key,
    this.label = "text",
    this.color = AppColor.red,
    this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(150),
      borderRadius: .circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(15),
        child: Container(
          height: 40,
          width: .infinity,
          padding: const .symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(borderRadius: .circular(15)),
          child: Center(child: Text(label)),
        ),
      ),
    );
  }
}

class ProfileBox extends StatelessWidget {
  const new({
    super.key,
    required this.label,
    this.boxName,
    this.margin = const .symmetric(horizontal: 16),
  });
  final String label;
  final String? boxName;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: .infinity,
      margin: margin,
      padding: const .symmetric(horizontal: 15, vertical: 7),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: .circular(15),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: boxName != null ? .start : .center,
        children: [
          if (boxName != null)
            Text(
              boxName!,
              style: TextStyle(fontSize: 10, color: AppColor.textMuted),
            ),
          Text(label),
        ],
      ),
    );
  }
}
