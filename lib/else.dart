import 'package:flutter/material.dart';
import 'profile.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:provider/provider.dart';
import 'package:gakuyoumatch2/main.dart';
import 'package:flutter/material.dart';
import 'package:gakuyoumatch2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gakuyoumatch2/profile2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




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

  final ProfileService _profileService = ProfileService();

  String? selectedGender; // 選択された性別
  DateTime? selectedDate; // 選択された生年月日

  @override
  void initState() {
    super.initState();
    // Firebase 初期化
    Firebase.initializeApp();

    // コントローラーの初期化
    nicknameController = TextEditingController();
    locationController = TextEditingController();
    hobbiesController = TextEditingController();
    skillsController = TextEditingController();
    othersController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    // コントローラーを解放
    nicknameController.dispose();
    locationController.dispose();
    hobbiesController.dispose();
    skillsController.dispose();
    othersController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    Profile? profile = await _profileService.loadProfile();

    if (profile != null) {
      setState(() {
        nicknameController.text = profile.nickname;
        selectedGender = profile.gender.isNotEmpty ? profile.gender : null;
        selectedDate = DateTime.tryParse(profile.birthdate);
        locationController.text = profile.location;
        hobbiesController.text = profile.hobbies;
        skillsController.text = profile.skills;
        othersController.text = profile.others;
      });
    }
  }

  Future<void> _saveProfile() async {
    Profile profile = Profile(
      nickname: nicknameController.text,
      gender: selectedGender ?? '',
      birthdate: selectedDate?.toIso8601String() ?? '',
      location: locationController.text,
      hobbies: hobbiesController.text,
      skills: skillsController.text,
      others: othersController.text,
    );

    await _profileService.saveProfile(profile);

    // Firestore にニックネームを保存
    const uid = "82091008-a484-4a89-ae75-a22bf8d6f3ac"; // 仮のユーザーIDを使用
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .set({'nickname': profile.nickname}, SetOptions(merge: true));
  }

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
      appBar: AppBar(title: const Text('登録情報')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                  await _saveProfile();
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



