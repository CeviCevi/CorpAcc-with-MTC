import 'package:corp_app/presentation/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

import '../../widget/check_block/check_block.dart';
import '../../widget/main_tile/main_tile.dart';
import '../../widget/start_toggle/start_toggle.dart';

class MainScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool toggleStatus = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Center(child: Text("AppName", textAlign: .end)),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                MainTile(
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      Padding(
                        padding: .symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            StartToggle(
                              recordingStatus: toggleStatus,
                              onTap: () =>
                                  setState(() => toggleStatus = !toggleStatus),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      Padding(
                        padding: const .symmetric(horizontal: 30),
                        child: Column(
                          spacing: 10,
                          crossAxisAlignment: .start,
                          children: [
                            Text("Условия запуска"),
                            CheckBlock(
                              text: "Введите текст",
                              isActive: toggleStatus,
                            ),
                            CheckBlock(text: "Введите текст", isActive: true),
                            CheckBlock(text: "Введите текст", isActive: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                MainTile(
                  padding: .symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    spacing: 15,
                    children: [
                      CustomTextField(
                        label: "Название",
                        labelStyle: TextStyle(),
                      ),

                      CustomTextField(
                        label: "Количество людей",
                        labelStyle: TextStyle(),
                      ),

                      CustomTextField(
                        label: "Описание",
                        labelStyle: TextStyle(),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                MainTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
