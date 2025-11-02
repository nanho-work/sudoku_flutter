import 'package:flutter/foundation.dart';
import '../models/stage_progress_model.dart';
import '../services/stage_service.dart';

/// 🔹 스테이지 진행상태 관리 프로바이더
class StageProgressProvider extends ChangeNotifier {
  final StageService _stageService = StageService();
  final String uid;

  /// 스테이지별 진행상태 캐시
  final Map<String, StageProgressModel> _progressMap = {};
  Map<String, StageProgressModel> get progressMap => _progressMap;

  StageProgressProvider(this.uid);

  /// 🔹 여러 스테이지의 진행상태를 병렬로 로드
  Future<void> loadProgress(List<String> stageIds) async {
    try {
      final results = await Future.wait(stageIds.map((id) async {
        // 1. 로컬에서 먼저 불러오기
        final local = await _stageService.loadLocalProgress(id);
        if (local != null) return MapEntry(id, local);

        // 2. 로컬에 없으면 Firestore에서 로드
        final remote = await _stageService.getStageProgress(uid, id);
        return remote != null ? MapEntry(id, remote) : null;
      }));

      // 3. Map으로 병합
      for (final entry in results.whereType<MapEntry<String, StageProgressModel>>()) {
        _progressMap[entry.key] = entry.value;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ loadProgress error: $e');
    }
  }

  /// 🔹 진행상태 업데이트 (로컬 + 원격)
  Future<void> updateProgress(StageProgressModel model) async {
    try {
      _progressMap[model.stageId] = model;
      notifyListeners();
      await _stageService.saveProgress(uid, model);
    } catch (e) {
      if (kDebugMode) print('⚠️ updateProgress error: $e');
    }
  }

  /// 🔹 보상 수령 처리
  Future<void> claimReward(String stageId, String starKey) async {
    try {
      final model = _progressMap[stageId];
      if (model == null) return;

      model.rewardsClaimed[starKey] = true;
      notifyListeners();

      await _stageService.saveProgress(uid, model);
    } catch (e) {
      if (kDebugMode) print('⚠️ claimReward error: $e');
    }
  }

  /// 🔹 특정 스테이지 클리어 여부
  bool isCleared(String stageId) {
    final model = _progressMap[stageId];
    return model?.cleared ?? false;
  }

  /// 🔹 진행률 (예: 별 개수 / 전체)
  double getProgressRatio(String stageId) {
    final model = _progressMap[stageId];
    if (model == null || model.totalStars == 0) return 0.0;
    final earned = model.rewardsClaimed.values.where((v) => v).length;
    return earned / model.totalStars;
  }
}