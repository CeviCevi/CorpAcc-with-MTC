import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class StartToggle extends StatelessWidget {
  const new({super.key, this.recordingStatus = false, this.onTap});

  final VoidCallback? onTap;
  final bool recordingStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 70,
      child: Stack(
        children: [
          AnimatedPositioned(
            bottom: recordingStatus ? 1.0 : 20,
            left: 10,
            duration: Duration(milliseconds: 300),
            child: Center(
              child: Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  borderRadius: .vertical(bottom: .circular(5)),
                  boxShadow: [BoxShadow(blurRadius: 3, color: AppColor.grey)],
                ),
                child: Center(
                  child: Text("00:21", style: TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              width: 250,
              height: 50,
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: .circular(15),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: AppColor.black.withAlpha(recordingStatus ? 255 : 50),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,

              child: Stack(
                children: [
                  Container(
                    width: 250,
                    height: 50,
                    color: AppColor.primaryDark,
                    child: Row(
                      children: [
                        SizedBox(width: 50),
                        Expanded(child: Text("Запустить", textAlign: .center)),
                      ],
                    ),
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
                              child: Center(child: Text("Остановить")),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 5,
                                  blurStyle: .outer,
                                  color: AppColor.darkGrey,
                                ),
                              ],
                              color: AppColor.primary,
                            ),
                            child: recordingStatus
                                ? AnimatedOpacity(
                                    duration: Duration(milliseconds: 300),
                                    opacity: recordingStatus ? 1.0 : .0,
                                    child: Icon(Icons.stop),
                                  )
                                : AnimatedOpacity(
                                    duration: Duration(milliseconds: 300),
                                    opacity: recordingStatus ? .0 : 1.0,
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
          ),
        ],
      ),
    );
  }
}
