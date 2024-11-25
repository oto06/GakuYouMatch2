import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile.dart';
import 'package:gakuyoumatch2/profile.dart';
import 'package:gakuyoumatch2/main.dart';
import 'package:provider/provider.dart';



import 'package:flutter/material.dart';

class Profile {
  String nickname = '';
  String gender = '';
  String birthdate = '';
  String location = '';
  String hobbies = '';
  String skills = '';
  String others = '';

  Profile({
    this.nickname = '',
    this.gender = '',
    this.birthdate = '',
    this.location = '',
    this.hobbies = '',
    this.skills = '',
    this.others = '',
  });
}

class BasicInfoForm extends StatefulWidget {
  final Profile profile;

  const BasicInfoForm({Key? key, required this.profile}) : super(key: key);

  @override
  _BasicInfoScreenState createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoForm> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController othersController = TextEditingController();
  String? selectedGender = '男性'; // 性別の選択肢

  // 生年月日のピッカー
  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        birthdateController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 既存のプロフィール情報をコントローラーにセット
    nicknameController.text = widget.profile.nickname;
    genderController.text = widget.profile.gender;
    birthdateController.text = widget.profile.birthdate;
    locationController.text = widget.profile.location;
    hobbiesController.text = widget.profile.hobbies;
    skillsController.text = widget.profile.skills;
    othersController.text = widget.profile.others;
  }

  void saveProfile() {
    setState(() {
      widget.profile.nickname = nicknameController.text;
      widget.profile.gender = genderController.text;
      widget.profile.birthdate = birthdateController.text;
      widget.profile.location = locationController.text;
      widget.profile.hobbies = hobbiesController.text;
      widget.profile.skills = skillsController.text;
      widget.profile.others = othersController.text;
    });
    Navigator.pop(context); // ホーム画面に戻る
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Info')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(controller: nicknameController, decoration: const InputDecoration(labelText: 'ニックネーム')),

            // 性別の選択 (ドロップダウン)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '性別',
              ),
              child: DropdownButton<String>(
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: <String>['男性', '女性', 'その他']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true,
                underline: Container(), // ドロップダウンの下線を消す
              ),
            ),

            // 生年月日の入力（カレンダーから選択）
            TextField(
              controller: birthdateController,
              decoration: const InputDecoration(
                labelText: '生年月日',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // 編集不可にしてカレンダーから選択する
              onTap: () => _selectDate(context), // 日付選択時にカレンダー表示
            ),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: '居住地')),
            TextField(controller: hobbiesController, decoration: const InputDecoration(labelText: '趣味')),
            TextField(controller: skillsController, decoration: const InputDecoration(labelText: '特技')),
            TextField(controller: othersController, decoration: const InputDecoration(labelText: 'その他')),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // 保存処理（必要ならここでデータを保存する処理を追加）
                saveProfile();

                // MyApp に戻る
                Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: const Text('登録'),
            ),
          ],
        ),
      ),
    );
  }
}



