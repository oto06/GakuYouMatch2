import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreインポート
import 'package:firebase_storage/firebase_storage.dart'; // FirebaseStorageインポート
import 'package:image_picker/image_picker.dart'; // 画像選択インポート
import 'dart:io'; // File型インポート

class ElsePage extends StatefulWidget {
  const ElsePage({Key? key}) : super(key: key);

  @override
  State<ElsePage> createState() => _ElsePageState();
}

class _ElsePageState extends State<ElsePage> {
  late TextEditingController nicknameController;
  late TextEditingController locationController;
  late TextEditingController hobbiesController;
  late TextEditingController skillsController;
  late TextEditingController othersController;

  String? selectedGender; // 選択された性別
  DateTime? selectedDate; // 選択された生年月日
  File? _selectedImage; // 選択された写真を保持
  final ImagePicker _picker = ImagePicker(); // 画像選択のインスタンス
  String? imageUrl; // Firestoreから取得する画像URL

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController();
    locationController = TextEditingController();
    hobbiesController = TextEditingController();
    skillsController = TextEditingController();
    othersController = TextEditingController();
    // プロフィール情報をFirestoreから読み込む
    _loadProfile();
  }

  @override
  void dispose() {
    nicknameController.dispose();
    locationController.dispose();
    hobbiesController.dispose();
    skillsController.dispose();
    othersController.dispose();
    super.dispose();
  }

  // Firestoreからプロフィールを読み込む処理
  Future<void> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Firestoreから現在のユーザーのプロフィール情報を取得
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid) // ユーザーIDを使ってドキュメントを取得
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;

        setState(() {
          nicknameController.text = data['nickname'] ?? '';
          selectedGender = data['gender'] ?? '';
          selectedDate = data['birthdate'] != null
              ? DateTime.tryParse(data['birthdate'])
              : null;
          locationController.text = data['location'] ?? '';
          hobbiesController.text = data['hobbies'] ?? '';
          skillsController.text = data['skills'] ?? '';
          othersController.text = data['others'] ?? '';
          imageUrl = data['imageUrl']; // Firestoreから画像URLを取得
        });
      }
    }
  }

  // プロフィールの保存処理
  Future<void> _saveProfile() async {
    String? uploadedImageUrl;
    if (_selectedImage != null) {
      uploadedImageUrl = await _uploadImage(_selectedImage!);
    }

    // プロフィールデータをまとめる
    Map<String, dynamic> userData = {
      'nickname': nicknameController.text,
      'gender': selectedGender ?? '',
      'birthdate': selectedDate?.toIso8601String() ?? '',
      'location': locationController.text,
      'hobbies': hobbiesController.text,
      'skills': skillsController.text,
      'others': othersController.text,
      'imageUrl': uploadedImageUrl, // 画像URLを保存
    };

    // Firebase Authenticationで現在のユーザーUIDを取得
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Firestoreにユーザー情報を保存
      await FirebaseFirestore.instance
          .collection('Users') // 'Users'コレクションに保存
          .doc(user.uid) // 現在のユーザーIDをドキュメントIDとして使用
          .set(userData, SetOptions(merge: true)); // データをマージして保存
    } else {
      // ユーザーがログインしていない場合の処理
      print("ユーザーがログインしていません");
    }
  }

  // 画像選択処理
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 画像アップロード処理
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      print('Firebase Storage エラー: $e');
      return null;
    } catch (e) {
      print('予期しないエラー: $e');
      return null;
    }
  }

  // 生年月日を選択する処理
  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プロフィール')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Firestoreから取得した画像URLを使用して画像を表示
              if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              else
                const Icon(Icons.account_circle, size: 100),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('写真を選択'),
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'ニックネーム'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(labelText: '性別'),
                items: ['男性', '女性', 'その他']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? '生年月日: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                          : '生年月日を選択してください',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(context),
                    child: const Text('カレンダーを開く'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: '居住地'),
              ),
              TextField(
                controller: hobbiesController,
                decoration: const InputDecoration(labelText: '趣味'),
              ),
              TextField(
                controller: skillsController,
                decoration: const InputDecoration(labelText: '特技'),
              ),
              TextField(
                controller: othersController,
                decoration: const InputDecoration(labelText: 'その他'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _saveProfile();  // プロフィール保存処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('保存しました')),
                  );
                },
                child: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
