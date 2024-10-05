import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Example',
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
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
        title: Text('プロフィール'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('写真を選択:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            _image == null
                ? Text('画像が選択されていません。')
                : Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('写真を選択'),
            ),
            SizedBox(height: 16),
            Text('特技:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _skillsController,
              decoration: InputDecoration(hintText: '特技を入力'),
            ),
            SizedBox(height: 16),
            Text('趣味:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _hobbiesController,
              decoration: InputDecoration(hintText: '趣味を入力'),
            ),
            SizedBox(height: 16),
            Text('その他:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _othersController,
              decoration: InputDecoration(hintText: 'その他の情報を入力'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 入力されたデータの処理をここに追加
                print('特技: ${_skillsController.text}');
                print('趣味: ${_hobbiesController.text}');
                print('その他: ${_othersController.text}');
              },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}