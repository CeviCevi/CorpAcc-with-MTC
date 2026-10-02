import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/presentation/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

                      Column(
                        crossAxisAlignment: .start,
                        spacing: 5,
                        children: [
                          Text("Количество участников"),
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Flexible(
                                child: CustomTextField(
                                  labelStyle: TextStyle(),
                                  align: .center,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              ShortButton(text: "2"),
                              SizedBox(width: 5),
                              ShortButton(text: "3"),
                              SizedBox(width: 5),
                              ShortButton(text: "5"),
                            ],
                          ),
                        ],
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

class ShortButton extends StatelessWidget {
  const new({super.key, this.onTap, this.text = "NoN"});
  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: .zero,
      child: Container(
        width: 60,
        height: 45,
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: .circular(15),
          boxShadow: [BoxShadow(color: AppColor.greenBlue, blurRadius: 3)],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: AppColor.white, fontSize: 16),
            textAlign: .center,
          ),
        ),
      ),
    );
  }
}
