class Profile {
  final String nickname;
  final String gender;
  final String birthdate;
  final String location;
  final String hobbies;
  final String skills;
  final String others;
  String? imageUrl; // 写真URLのフィールドを追加

  Profile({
    required this.nickname,
    required this.gender,
    required this.birthdate,
    required this.location,
    required this.hobbies,
    required this.skills,
    required this.others,
    this.imageUrl, // コンストラクタに追加
  });

  // プロファイルをMapに変換（保存用）
  Map<String, String> toMap() {
    return {
      'nickname': nickname,
      'gender': gender,
      'birthdate': birthdate,
      'location': location,
      'hobbies': hobbies,
      'skills': skills,
      'others': others,
    };
  }

  // Mapをプロファイルに変換（読み込み用）
  factory Profile.fromMap(Map<String, String> map) {
    return Profile(
      nickname: map['nickname'] ?? '',
      gender: map['gender'] ?? '',
      birthdate: map['birthdate'] ?? '',
      location: map['location'] ?? '',
      hobbies: map['hobbies'] ?? '',
      skills: map['skills'] ?? '',
      others: map['others'] ?? '',
    );
  }
}




