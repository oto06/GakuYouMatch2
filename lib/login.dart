import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gakuyoumatch2/FirstScene.dart'as FirstScene;
import 'package:gakuyoumatch2/acountregister.dart';
import 'package:gakuyoumatch2/basicinfo.dart';
import 'package:gakuyoumatch2/main.dart';
import 'package:gakuyoumatch2/map%20search.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ログイン成功時
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  MyApp()), // ホーム画面へ遷移
      );
    } catch (e) {
      // エラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ログインに失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown, Colors.orangeAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'メールアドレス',
                          prefixIcon: Icon(Icons.email, color: Colors.brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'パスワード',
                          prefixIcon: Icon(Icons.lock, color: Colors.brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ログイン',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AccountRegister()),
                    );
                  },
                  child: const Text(
                    '新規登録はこちら',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.brown[200],
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           TextField(
  //             controller: _emailController,
  //             decoration: const InputDecoration(labelText: 'メールアドレス'),
  //           ),
  //           TextField(
  //             controller: _passwordController,
  //             decoration: const InputDecoration(labelText: 'パスワード'),
  //             obscureText: true,
  //           ),
  //           const SizedBox(height: 20),
  //           _isLoading
  //               ? const CircularProgressIndicator()
  //               : ElevatedButton(
  //             onPressed: _login,
  //             child: const Text('ログイン'),
  //           ),
  //           const SizedBox(height: 20),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (context) =>  AccountRegister()),
  //               );
  //             },
  //             child: const Text('新規登録はこちら'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  //}

