import 'package:corp_app/app/app_color/app_color.dart';
import 'package:corp_app/app/app_const.dart';
import 'package:corp_app/presentation/new/widget/record_button.dart';
import 'package:corp_app/presentation/old/widget/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isRecording = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = "название_${DateTime.now().hashCode}";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _discriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: .center,

        children: [
          SizedBox(width: AppConst.width, height: 5),
          RecordButton(
            isRecording: _isRecording,
            onTap: () => setState(() => _isRecording = !_isRecording),
          ),

          SizedBox(height: 20),
          Padding(
            padding: const .symmetric(horizontal: 18),
            child: CustomTextField(
              controller: _nameController,
              hint: "Кошачьи бои",
              label: "Название",
              focusedBorderColor: AppColor.green,
            ),
          ),

          SizedBox(height: 20),
          Padding(
            padding: const .symmetric(horizontal: 18),
            child: CustomTextField(
              maxLines: 3,
              controller: _discriptionController,
              hint: "Встреча для обсуждения закупок новых деталей",
              label: "Описание",
              focusedBorderColor: AppColor.green,
            ),
          ),
        ],
      ),
    );
  }
}
