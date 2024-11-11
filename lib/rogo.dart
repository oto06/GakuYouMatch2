import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 100), // ロゴ画像を追加
            const SizedBox(height: 20),
            const Text("App Name", style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

