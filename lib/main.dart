import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'acountregister.dart';
import 'basicinfo.dart';
import 'profile.dart';
import 'map search.dart';



Future<void> main()async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebaseの初期化
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,

      ),
      home: FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text ('First Screen'),
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
        SizedBox(height: 30), // ボタンとテキストの間にスペースを追加
        ElevatedButton(
          onPressed: () {
            // ボタンを押すと次の画面に遷移
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BasicInfoForm()),
            );
          },
          child: Text('Googleアカウントで登録'),
       ),
          SizedBox(height: 20), // ボタンの間にスペースを追加
          ElevatedButton(
            onPressed: () {
              // 2つ目のボタンを押すと次の画面に遷移
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapSearch()), // 遷移先を変更することも可能
              );
            },
            child: Text('Appleアカウントで登録'), // ボタンのテキストを変更
           ),
          ],
        ),
      ),
    );
  }
}
