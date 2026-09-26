import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

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
                  widget: Column(
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

                      Radio(value: toggleStatus),
                    ],
                  ),
                ),
                MainTile(),
                MainTile(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StartToggle extends StatelessWidget {
  const new({super.key, this.recordingStatus = false, this.onTap});

  final VoidCallback? onTap;
  final bool recordingStatus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 250,
        height: 50,
        child: Stack(
          children: [
            Container(
              height: 50,
              width: .infinity,
              color: AppColor.primaryDark,
              child: Center(child: Text("Остановлено", textAlign: .center)),
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInCubic,
              left: recordingStatus ? 0 : -200,
              child: SizedBox(
                height: 50,
                width: 250,
                child: Row(
                  children: [
                    AnimatedOpacity(
                      opacity: recordingStatus ? 1 : 0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInCirc,
                      child: Container(
                        height: 50,
                        width: 200,
                        color: AppColor.primaryLight,
                        child: Center(child: Text("Запущено")),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      color: AppColor.primary,
                      child: recordingStatus
                          ? AnimatedOpacity(
                              duration: Duration(milliseconds: 3000),
                              opacity: recordingStatus ? 1 : 0,
                              child: Icon(Icons.stop),
                            )
                          : AnimatedOpacity(
                              duration: Duration(milliseconds: 3000),
                              opacity: !recordingStatus ? 1 : 0,
                              child: Icon(Icons.play_arrow),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTile extends StatelessWidget {
  final Widget widget;
  const new({super.key, this.widget = const Center()});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 300,
      decoration: BoxDecoration(border: Border.all()),
      child: widget,
    );
  }
}
