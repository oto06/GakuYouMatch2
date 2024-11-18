import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gakuyoumatch2/Chat.dart';
import 'package:gakuyoumatch2/ChatSelect.dart';
import 'package:gakuyoumatch2/acountregister.dart';
import 'package:gakuyoumatch2/calender.dart';
import 'package:gakuyoumatch2/login.dart';
import 'package:gakuyoumatch2/map%20search.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'basicinfo.dart';
import 'firebase_options.dart';
import 'calender.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebaseの初期化
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      debugShowCheckedModeBanner: false,
      home: FirstScene(),
      // 初期画面を指定
      routes: {
        '/initial': (context) => const FirstScene(),
        '/other': (context) => ChatListScreen(),
      },

    );
  }
}


class FirstScene extends StatelessWidget {
  const FirstScene({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text ('First Screen'),
      ),
      body: Center(
        child: Column( // Column で複数のウィジェットをまとめる
          mainAxisAlignment: MainAxisAlignment.start, // ウィジェットを上に配置
          crossAxisAlignment: CrossAxisAlignment.center, // 横方向に中央に配置
          children: [
            const Text(
              '新規登録',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30), // ボタンとテキストの間にスペースを追加
            ElevatedButton(
              onPressed: () {
                // ボタンを押すと次の画面に遷移
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ProfilePage()),
                );
              },
              child: const Text('Googleアカウントで登録'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text("ログイン"),
            )
          ],
        ),
      ),
    );
  }
}