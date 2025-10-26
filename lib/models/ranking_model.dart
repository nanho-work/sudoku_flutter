import 'package:cloud_firestore/cloud_firestore.dart';

class RankingRecord {
  final String userId;
  final String nickname;
  final String difficulty;
  final double clearTime;
  final String gameMode;
  final String device;
  final DateTime recordedAt;
  final String weekKey;

  RankingRecord({
    required this.userId,
    required this.nickname,
    required this.difficulty,
    required this.clearTime,
    required this.gameMode,
    required this.device,
    required this.recordedAt,
    required this.weekKey,
  });

  factory RankingRecord.fromMap(Map<String, dynamic> data) {
    return RankingRecord(
      userId: data['userId'] ?? '',
      nickname: data['nickname'] ?? '',
      difficulty: data['difficulty'] ?? 'normal',
      clearTime: (data['clearTime'] ?? 0).toDouble(),
      gameMode: data['gameMode'] ?? 'classic',
      device: data['device'] ?? 'android',
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekKey: data['weekKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'nickname': nickname,
      'difficulty': difficulty,
      'clearTime': clearTime,
      'gameMode': gameMode,
      'device': device,
      'recordedAt': Timestamp.fromDate(recordedAt),
      'weekKey': weekKey,
    };
  }
}