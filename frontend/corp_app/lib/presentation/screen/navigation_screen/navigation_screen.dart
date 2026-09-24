import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/presentation/screen/dev_screen/dev_screen.dart';
import 'package:flutter/material.dart';

import '../../widget/navigation_button/navigation_button.dart';

class NavigationScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  Size screenSize = Size(0, 0);
  int pageNum = 0;
  final List<Widget> screenList = [
    Scaffold(),
    Scaffold(),
    Scaffold(),
    DevScreen(),
  ];

  void setScreen(int screenNum) {
    setState(() => pageNum = screenNum);
  }

  bool isThisScreen(int pageNum) {
    return pageNum == this.pageNum;
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          Container(
            height: screenSize.height,
            width: 200,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColor.black)),
            ),
            child: Column(
              children: [
                NavigationButton(
                  buttonName: "Glavnaya",
                  onTap: () => setScreen(0),
                  isActive: isThisScreen(0),
                ),
                NavigationButton(
                  buttonName: "Istoria",
                  onTap: () => setScreen(1),
                  isActive: isThisScreen(1),
                ),
                NavigationButton(
                  buttonName: "Profil",
                  onTap: () => setScreen(2),
                  isActive: isThisScreen(2),
                ),
                NavigationButton(
                  buttonName: "dev",
                  onTap: () => setScreen(3),
                  isActive: isThisScreen(3),
                ),
              ],
            ),
          ),

          Expanded(child: screenList[pageNum]),
        ],
      ),
    );
  }
}
