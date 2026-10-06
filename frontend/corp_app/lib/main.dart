import 'package:corp_app/domain/repository/storage_repository.dart';
import 'package:corp_app/presentation/screen/navigation_screen/navigation_Screen.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageRepository.instance.init();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(400, 500),
    backgroundColor: Colors.transparent,
    maximumSize: Size(400, 500),
    minimumSize: Size(400, 500),
    titleBarStyle: TitleBarStyle.normal,
    title: "Матвей Письконюх",
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
          seedColor: Colors.purple,
          brightness: .dark,
        ),
      ),
      home: NavigationScreen(),
    );
  }
}
