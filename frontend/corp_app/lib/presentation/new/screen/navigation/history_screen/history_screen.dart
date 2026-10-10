import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                CustomTextField(),
                // Material(
                //   color: AppColor.transparent,
                //   child: InkWell(
                //     onTap: () {},
                //     borderRadius: BorderRadius.circular(10),
                //     child: Container(
                //       height: 30,
                //       width: 30,
                //       decoration: BoxDecoration(
                //         color: AppColor.surface.withAlpha(100),
                //         borderRadius: .circular(10),
                //       ),
                //       child: Center(
                //         child: Icon(
                //           Icons.arrow_forward_ios_rounded,
                //           size: 15,
                //           color: AppColor.textMuted,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
