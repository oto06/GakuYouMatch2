import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:intl/intl.dart';  // 日付フォーマット用

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Info Form',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BasicInfoForm(),
    );
  }
}

class BasicInfoForm extends StatefulWidget {
  const BasicInfoForm({super.key});

  @override
  _BasicInfoFormState createState() => _BasicInfoFormState();
}

class _BasicInfoFormState extends State<BasicInfoForm> {
  // コントローラや選択状態を管理
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? _gender;
  DateTime? _selectedDate;

  // 日付選択の関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        birthdateController.text = DateFormat('yyyy/MM/dd').format(picked);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本情報フォーム'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '基本情報',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ニックネーム入力フィールド
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: 'ニックネーム',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 性別選択
            const Text(
              '性別',
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton<String>(
              value: _gender,
              items: <String>['男性', '女性', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text('性別を選択'),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // 生年月日入力フィールド
            TextField(
              controller: birthdateController,
              decoration: InputDecoration(
                labelText: '生年月日',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ),
              readOnly: true, // ユーザーはテキストを直接編集できない
            ),
            const SizedBox(height: 20),

            // 居住地入力フィールド
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: '居住地',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // 確認用ボタン（送信など）
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // ここでフォームの内容を処理
                  print('ニックネーム: ${nicknameController.text}');
                  print('性別: $_gender');
                  print('生年月日: ${birthdateController.text}');
                  print('居住地: ${locationController.text}');
                },
                child: const Text('送信'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // 次の画面に遷移するロジック
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // ボタンの幅を画面いっぱいに
          ),
          child: const Text('次へ'),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('次のページ'),
      ),
      body: const Center(
        child: Text('これは次のページです！'),
      ),
    );
  }
}