import 'package:flutter/material.dart';

class DevScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: Text("To Login")),
          ElevatedButton(onPressed: () {}, child: Text("To Reg")),
          ElevatedButton(onPressed: () {}, child: Text("To Nav")),
        ],
      ),
    );
  }
}
