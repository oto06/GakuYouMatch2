import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'acountregister.dart';
import 'basicinfo.dart';
import'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstScreen(),
    );
  }
}




class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

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
              MaterialPageRoute(builder: (context) => const AccountRegister()),
            );
          },
          child: const Text('Googleアカウントで登録'),
       ),
          const SizedBox(height: 20), // ボタンの間にスペースを追加
          ElevatedButton(
            onPressed: () {
              // 2つ目のボタンを押すと次の画面に遷移
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BasicInfoForm()), // 遷移先を変更することも可能
              );
            },
            child: const Text('Appleアカウントで登録'), // ボタンのテキストを変更
           ),
          ],
        ),
      ),
    );
  }
}
