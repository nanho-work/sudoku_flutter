import '../models/user_model.dart';
import '../models/stage_model.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardService {
  final UserService _userService = UserService();

  // 🔹 로컬 계산
  Map<String, int> calculateReward(StageModel stage, Map<String, bool> stars) {
    int gold = stage.rewards['gold'] ?? 0;
    int gems = stage.rewards['gems'] ?? 0;
    int exp = stage.rewards['exp'] ?? 0;

    int achieved = stars.values.where((v) => v).length;
    double multiplier = achieved / 3;

    return {
      'gold': (gold * multiplier).round(),
      'gems': (gems * multiplier).round(),
      'exp': (exp * multiplier).round(),
    };
  }

  // 🔹 유저 객체에 즉시 반영 + Firestore 안전 업데이트
  Future<UserModel> applyReward(UserModel user, Map<String, int> reward) async {
    user.gold += reward['gold'] ?? 0;
    user.gems += reward['gems'] ?? 0;
    user.exp += reward['exp'] ?? 0;
    user.notifyListeners();

    await _userService.updateUserData(user.uid, {
      'gold': FieldValue.increment(reward['gold'] ?? 0),
      'gems': FieldValue.increment(reward['gems'] ?? 0),
      'exp': FieldValue.increment(reward['exp'] ?? 0),
    });

    return user;
  }
}