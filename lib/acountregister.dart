import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gakuyoumatch2/else.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:gakuyoumatch2/main.dart';

class AccountRegister extends StatefulWidget {
  AccountRegister({super.key});

  @override
  _AccountRegisterState createState() => _AccountRegisterState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}


class  _AccountRegisterState extends State<AccountRegister> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 登録処理のメソッド
  void _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // ユーザー登録成功の処理
      print('User registered: ${userCredential.user?.uid}');//登録成功したら次の画面に移行
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  MyApp()),
      );
      // 登録成功後の画面遷移などをここで行うことができます
    } catch (e) {
      // エラー処理
      print('Failed to register: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'), // メールフィールド
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'), // パスワードフィールド
              obscureText: true, // パスワードを隠す
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register, // 登録ボタンを押すと_registerメソッドを呼ぶ
              child: const Text('登録'),


            ),
          ],
        ),
      ),
    );
  }
}