import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/main.dart';
import 'package:image_picker/image_picker.dart';
import 'map_home.dart'; // map_home.dart をインポート

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Profile Example',
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // 選択された画像を保持
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // 内容が長くなってもスクロール可能にする
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('写真を選択:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              _image == null
                  ? const Text('画像が選択されていません。')
                  : Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('写真を選択'),
              ),
              const SizedBox(height: 16),
              const Text('特技:', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _skillsController,
                decoration: const InputDecoration(hintText: '特技を入力'),
              ),
              const SizedBox(height: 16),
              const Text('趣味:', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _hobbiesController,
                decoration: const InputDecoration(hintText: '趣味を入力'),
              ),
              const SizedBox(height: 16),
              const Text('その他:', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _othersController,
                decoration: const InputDecoration(hintText: 'その他の情報を入力'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 入力されたデータの処理をここに追加
                  print('特技: ${_skillsController.text}');
                  print('趣味: ${_hobbiesController.text}');
                  print('その他: ${_othersController.text}');
                },
                child: const Text('保存'),
              ),
              const SizedBox(height: 16),
              // MapHomeへの遷移ボタンを追加
              ElevatedButton(
                onPressed: () {
                  // MapHome画面への遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('次へ'), // ボタンに「次へ」と表示
              ),
            ],
          ),
        ),
      ),
    );
  }
}
