import 'package:corp_app/app/app_color/app_color.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          height: 230,
          padding: .symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.black),
            borderRadius: .circular(20),
          ),
          child: Column(
            children: [
              TextField(),
              TextField(),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                child: Text("Prodolgit", textAlign: .center),
              ),
              SizedBox(height: 20),
              InkWell(onTap: () {}, child: Text("to reg")),
            ],
          ),
        ),
      ),
    );
  }
}
