// lib/models/profile.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSONを扱うために必要
import 'package:gakuyoumatch2/profile.dart';

class ProfileService {
  static const String _profileKey = 'profileData';

  // プロファイルを保存
  Future<void> saveProfile(Profile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileJson = jsonEncode(profile.toMap());
    prefs.setString(_profileKey, profileJson);
  }

  // プロファイルを読み込み
  Future<Profile?> loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileJson = prefs.getString(_profileKey);

    if (profileJson == null) {
      return null; // データがない場合
    }

    Map<String, String> profileMap = Map<String, String>.from(jsonDecode(profileJson));
    return Profile.fromMap(profileMap);
  }
}

