import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/router_service.dart';
import 'package:corp_app/data/model/user_model.dart';
import 'package:corp_app/domain/service/user_service.dart';
import 'package:corp_app/presentation/new/screen/login/reg_screen/reg_screen.dart';
import 'package:corp_app/presentation/new/screen/navigation/navigation_screen/navigation_screen.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => RegScreenState();
}

class RegScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscureText = true;
  bool isLoading = false;

  void _changeIcon() {
    setState(() => obscureText = !obscureText);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Введите имя';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Введите почту';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Введите корректный адрес почты';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Введите пароль';
    }

    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await UserService.login(
        user: UserModel.empty.copyWith(
          login: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (success) {
        RouterService.pushpop(context, NavigationScreen());
      } else {
        _showMessage('Не удалось войти. Проверьте данные.');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('Ошибка входа. Попробуйте ещё раз.');
      debugPrint('Registration error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 10,
              children: [
                const SizedBox(height: 10),

                const Text(
                  'Вход',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                CustomTextField(
                  label: 'Имя',
                  controller: _nameController,
                  validator: _validateName,
                  focusedBorderColor: AppColor.green,
                ),

                CustomTextField(
                  label: 'Почта',
                  controller: _emailController,
                  validator: _validateEmail,
                  focusedBorderColor: AppColor.green,
                  keyboardType: TextInputType.emailAddress,
                ),

                CustomTextField(
                  label: 'Пароль',
                  controller: _passwordController,
                  validator: _validatePassword,
                  focusedBorderColor: AppColor.green,
                  obscureText: obscureText,
                  suffixIcon: IconButton(
                    onPressed: _changeIcon,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.remove_red_eye_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: Material(
                    color: AppColor.green,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: isLoading ? null : _login,
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
                            : const Text('Продолжить'),
                      ),
                    ),
                  ),
                ),

                Center(
                  child: CupertinoButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            RouterService.pushpop(context, RegScreen());
                          },
                    padding: EdgeInsets.zero,
                    child: Text(
                      'Зарегистрироваться',
                      style: TextStyle(color: AppColor.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
