import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/FirstScene.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // アニメーションを開始
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[200], // 背景色を濃い青に設定 (Dark Blue)
      body:GestureDetector(
        onTap: () {
      // タップ時に次の画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirstScene()),
      );
    },
        child:Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 4), // フェードインにかかる時間
          child: Image.asset(
            'assets/53.png', // ロゴ画像を指定
            width: 500,
            height: 500,
          ),
        ),
        )
      )
    );
  }
}

