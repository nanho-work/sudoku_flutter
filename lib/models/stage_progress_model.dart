import 'dart:convert';

/// 👤 유저별 스테이지 진행 상태
/// users/{uid}/stage_progress/{stage_id}
class StageProgressModel {
  final String stageId;
  bool cleared;                         // 클리어 여부
  Map<String, bool> stars;              // {"1":true,"2":false,"3":true}
  Map<String, bool> rewardsClaimed;     // {"1":true,"2":false,"3":false}
  int hintsUsed;                        // 사용한 힌트 수
  int wrongAttempts;                    // 틀린 입력 횟수
  int clearTime;                        // 클리어까지 걸린 초
  DateTime lastPlayed;                  // 최근 플레이 시각

  StageProgressModel({
    required this.stageId,
    this.cleared = false,
    Map<String, bool>? stars,
    Map<String, bool>? rewardsClaimed,
    this.hintsUsed = 0,
    this.wrongAttempts = 0,
    this.clearTime = 0,
    DateTime? lastPlayed,
  })  : stars = stars ?? {"1": false, "2": false, "3": false},
        rewardsClaimed = rewardsClaimed ?? {"1": false, "2": false, "3": false},
        lastPlayed = lastPlayed ?? DateTime.now();

  factory StageProgressModel.fromJson(Map<String, dynamic> json) =>
      StageProgressModel(
        stageId: json['stage_id'] ?? json['stageId'] ?? '',
        cleared: json['cleared'] ?? false,
        stars: Map<String, bool>.from(json['stars'] ?? {}),
        rewardsClaimed: Map<String, bool>.from(json['rewards_claimed'] ?? {}),
        hintsUsed: json['hints_used'] ?? 0,
        wrongAttempts: json['wrong_attempts'] ?? 0,
        clearTime: json['clear_time'] ?? 0,
        lastPlayed:
            DateTime.tryParse(json['last_played'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'stage_id': stageId,
        'cleared': cleared,
        'stars': stars,
        'rewards_claimed': rewardsClaimed,
        'hints_used': hintsUsed,
        'wrong_attempts': wrongAttempts,
        'clear_time': clearTime,
        'last_played': lastPlayed.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());
  
  /// Computed properties for provider compatibility
  int get totalStars => stars.length;
  int get earnedStars => stars.values.where((v) => v).length;
  double get starProgress => totalStars == 0 ? 0.0 : earnedStars / totalStars;
}