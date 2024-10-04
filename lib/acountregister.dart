import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AccountRegister extends StatefulWidget {
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
      print('User registered: ${userCredential.user?.uid}');
      // 登録成功後の画面遷移などをここで行うことができます
    } catch (e) {
      // エラー処理
      print('Failed to register: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Register'), // アプリバーのタイトル
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'), // メールフィールド
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'), // パスワードフィールド
              obscureText: true, // パスワードを隠す
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register, // 登録ボタンを押すと_registerメソッドを呼ぶ
              child: Text('Register'),

            ),
          ],
        ),
      ),
    );
  }
}