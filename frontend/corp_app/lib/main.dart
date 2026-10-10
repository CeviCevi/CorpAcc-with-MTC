import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/presentation/new/screen/navigation/navigation_screen/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageRepository.instance.init();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(AppConst.width, AppConst.height),
    backgroundColor: Colors.transparent,
    maximumSize: Size(AppConst.width, AppConst.height),
    minimumSize: Size(AppConst.width, AppConst.height),
    titleBarStyle: TitleBarStyle.normal,
    title: "Speech Brief x64",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.darkGrey,
          brightness: .dark,
        ),
      )..copyWith(scaffoldBackgroundColor: AppColor.darkGrey),
      home: NavigationScreen(),
    );
  }
}
