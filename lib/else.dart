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
    } else {
      uploadedImageUrl = imageUrl; // 画像が選ばれていない場合は、以前のURLを使う
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

      // 新しい画像URLを設定してUIを更新
      setState(() {
        imageUrl = uploadedImageUrl;
      });
    } else {
      // ユーザーがログインしていない場合の処理
      print("ユーザーがログインしていません");
    }
  }

  // 画像選択処理
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 画像アップロード処理
  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = 'profile_images/${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(
          image);
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
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: const Text(
            'プロフィール', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ClipOval(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, width: 120,
                            height: 120,
                            fit: BoxFit.cover)
                            : imageUrl != null
                            ? Image.network(
                            imageUrl!, width: 120, height: 120, fit: BoxFit
                            .cover)
                            : const Icon(
                            Icons.account_circle, size: 120, color: Colors
                            .grey),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('写真を変更', style: TextStyle(
                            fontSize: 16, color: Colors.brown)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildProfileCard('ニックネーム', nicknameController),
              _buildDropdownCard(
                  '性別', selectedGender, ['男性', '女性', 'その他']),
              _buildDatePickerCard(context),
              _buildProfileCard('居住地', locationController),
              _buildProfileCard('趣味', hobbiesController),
              _buildProfileCard('特技', skillsController),
              _buildProfileCard('その他', othersController),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await _saveProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('保存しました')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text('保存', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(String label, TextEditingController controller) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownCard(String label, String? value, List<String> items) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: InputBorder.none),
          items: items.map((item) =>
              DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (newValue) => setState(() => selectedGender = newValue),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null
                    ? '生年月日: ${selectedDate!.toLocal().toString().split(
                    ' ')[0]}'
                    : '生年月日を選択してください',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () => _pickDate(context),
              icon: const Icon(Icons.calendar_today, color: Colors.brown),
            ),
          ],
        ),
      ),
    );
  }
}
