import 'package:flutter/foundation.dart';
import '../models/stage_progress_model.dart';
import '../services/stage_service.dart';
import '../models/stage_model.dart';
import '../models/user_model.dart';
import '../services/reward_service.dart';

class StageProgressProvider extends ChangeNotifier {
  final StageService _stageService = StageService();
  final String uid;

  final Map<String, StageProgressModel> _progressMap = {};
  Map<String, StageProgressModel> get progressMap => _progressMap;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  StageProgressProvider(this.uid);

  Future<void> init(List<String> stageIds) async {
    if (_isLoaded) return;
    await loadProgress(stageIds);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> loadProgress(List<String> stageIds) async {
    try {
      final results = await Future.wait(stageIds.map((id) async {
        final local = await _stageService.loadLocalProgress(id);
        if (local != null) return MapEntry(id, local);

        final remote = await _stageService.getStageProgress(uid, id);
        if (remote != null) {
          await _stageService.saveProgress(uid, remote);
          return MapEntry(id, remote);
        }
        return null;
      }));

      for (final entry in results.whereType<MapEntry<String, StageProgressModel>>()) {
        _progressMap[entry.key] = entry.value;
      }

      if (kDebugMode) {
        print('✅ [StageProgressProvider] progressMap loaded: ${_progressMap.keys}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ loadProgress error: $e');
    }
  }

  Future<void> updateProgress(StageProgressModel model) async {
    try {
      _progressMap[model.stageId] = model;
      notifyListeners();
      await _stageService.saveProgress(uid, model);
    } catch (e) {
      if (kDebugMode) print('⚠️ updateProgress error: $e');
    }
  }

  Future<void> claimReward(
      String stageId, String starKey, StageModel stage, UserModel user) async {
    try {
      final model = _progressMap[stageId];
      if (model == null) return;

      final rewardService = RewardService();
      final reward = rewardService.calculateReward(stage, model.stars);
      await rewardService.applyReward(user, reward);

      model.rewardsClaimed[starKey] = true;
      notifyListeners();

      await _stageService.markRewardClaimed(user.uid, stageId, starKey);
      await _stageService.saveProgress(user.uid, model);
    } catch (e) {
      if (kDebugMode) print('⚠️ claimReward error: $e');
    }
  }

  bool isCleared(String stageId) => _progressMap[stageId]?.cleared ?? false;

  double getProgressRatio(String stageId) {
    final model = _progressMap[stageId];
    if (model == null || model.totalStars == 0) return 0.0;
    final earned = model.rewardsClaimed.values.where((v) => v).length;
    return earned / model.totalStars;
  }

  Future<void> clearAllProgress() async {
    _progressMap.clear();
    _isLoaded = false;
    notifyListeners();
  }
}