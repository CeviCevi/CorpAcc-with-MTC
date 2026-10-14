import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/router_service.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/data/short_db/short_db.dart';
import 'package:corp_app/domain/service/user_service.dart';
import 'package:corp_app/presentation/new/screen/login/reg_screen/loh_screen.dart';
import 'package:corp_app/presentation/new/screen/navigation/navigation_screen/navigation_screen.dart';
import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  static const String def = 'DEFAULT';
  static const String corp = 'CORP';

  String selectedRole = def;
  bool isLoading = false;

  Future<void> _next() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newUser = await UserService.updateMyAcc(
        user: widget.user.copyWith(role: selectedRole),
      );

      if (!newUser) return;

      if (!mounted) return;

      if (ShortDb.instance.userInSystem.role == def) {
        RouterService.pushpop(context, LohScreen());
      } else {
        RouterService.pushpop(context, NavigationScreen());
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось обновить аккаунт: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _roleOption({
    required String title,
    required String description,
    required String role,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: isLoading
            ? null
            : () {
                setState(() {
                  selectedRole = role;
                });
              },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.green.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColor.green : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? AppColor.green : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColor.green : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColor.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Тип аккаунта'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Выберите тип аккаунта',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Вы сможете продолжить после выбора типа аккаунта.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _roleOption(
                    title: 'Обычный',
                    description: 'Аккаунт работника',
                    role: def,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(width: 12),
                  _roleOption(
                    title: 'Корпоративный',
                    description: 'Аккаунт для компании',
                    role: corp,
                    icon: Icons.business_outlined,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Material(
                  color: isLoading
                      ? AppColor.green.withValues(alpha: 0.6)
                      : AppColor.green,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: isLoading ? null : _next,
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Продолжить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
