import 'package:flutter/material.dart';

import 'acountregister.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstScreen(), // 最初の画面

    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
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
              MaterialPageRoute(builder: (context) => SecondScreen()),
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
                MaterialPageRoute(builder: (context) => SecondScreen()), // 遷移先を変更することも可能
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
