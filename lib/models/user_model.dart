// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String nickname;
  final String loginType;
  final String? email;

  UserModel({
    required this.uid,
    required this.nickname,
    required this.loginType,
    this.email,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nickname': nickname,
        'login_type': loginType,
        'email': email,
      };

  factory UserModel.fromMap(Map<String, dynamic> data) => UserModel(
        uid: data['uid'],
        nickname: data['nickname'],
        loginType: data['login_type'],
        email: data['email'],
      );
}