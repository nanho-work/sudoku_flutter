// lib/models/user_model.dart
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  String uid;
  String nickname;
  String loginType;
  String? email;
  int gold;

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

  // ✅ 닉네임 변경 시 UI 즉시 갱신
  void updateNickname(String newNickname) {
    nickname = newNickname;
    notifyListeners();
  }

  // ✅ 전체 갱신용
  void updateFrom(UserModel updated) {
    uid = updated.uid;
    nickname = updated.nickname;
    loginType = updated.loginType;
    email = updated.email;
    gold = updated.gold;
    notifyListeners();
  }
}