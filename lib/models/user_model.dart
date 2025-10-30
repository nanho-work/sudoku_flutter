// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String nickname;
  final String loginType;
  final String? email;
  final int gold;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.loginType,
    this.email,
    this.gold = 0,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nickname': nickname,
        'login_type': loginType,
        'email': email,
        'gold': gold,
      };

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        uid: data['uid'],
        nickname: data['nickname'],
        loginType: data['login_type'],
        email: data['email'],
        gold: data['gold'] ?? 0,
      );
}