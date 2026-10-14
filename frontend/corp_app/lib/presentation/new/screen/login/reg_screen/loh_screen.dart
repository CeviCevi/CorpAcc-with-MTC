import 'package:flutter/material.dart';

class LohScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        children: [
          Center(
            child: Text("Вы не добавлены на корпоративный учет, подождите"),
          ),
        ],
      ),
    );
  }
}
