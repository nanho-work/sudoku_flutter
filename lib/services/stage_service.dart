import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../models/stage_progress_model.dart';

class StageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<StageModel> _cachedStages = [];

  // 🔹 숫자 추출 정렬 헬퍼
  int _num(String id) => int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  // 🔹 Firestore → 로컬 동기화
  Future<void> syncStagesFromFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await _db.collection('stages').get();

    _cachedStages.clear();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      await prefs.setString('stage_${doc.id}', jsonEncode(data));
      _cachedStages.add(StageModel.fromJson(data));
    }
    _cachedStages.sort((a, b) => _num(a.id).compareTo(_num(b.id)));
  }

  // 🔹 스테이지 로드 (Firestore → 로컬 폴백)
  Future<List<StageModel>> loadStages() async {
    if (_cachedStages.isNotEmpty) {
      _cachedStages.sort((a, b) => _num(a.id).compareTo(_num(b.id)));
      return _cachedStages;
    }
    try {
      final snapshot = await _db.collection('stages').get();
      final stages =
          snapshot.docs.map((doc) => StageModel.fromJson(doc.data())).toList();
      stages.sort((a, b) => _num(a.id).compareTo(_num(b.id)));
      _cachedStages = stages;

      final prefs = await SharedPreferences.getInstance();
      for (final s in stages) {
        await prefs.setString('stage_${s.id}', jsonEncode(s.toJson()));
      }
      return stages;
    } catch (e) {
      debugPrint('⚠️ Firestore load failed: $e');
      final localStages = await loadStagesFromLocal();
      return _cachedStages = localStages;
    }
  }

  // 🔹 로컬 로드
  Future<List<StageModel>> loadStagesFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('stage_'));
    final List<StageModel> stages = [];

    for (final key in keys) {
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) continue;
      final data = jsonDecode(jsonStr);
      stages.add(StageModel.fromJson(data));
    }
    stages.sort((a, b) => _num(a.id).compareTo(_num(b.id)));
    return stages;
  }

  // 🔹 진행상태 로드 (로컬)
  Future<StageProgressModel?> loadLocalProgress(String stageId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('progress_$stageId');
    if (data == null) return null;
    return StageProgressModel.fromJson(jsonDecode(data));
  }

  // 🔹 진행상태 로드 (Firestore)
  Future<StageProgressModel?> getStageProgress(String uid, String stageId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(stageId)
          .get();
      if (!doc.exists) return null;
      return StageProgressModel.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('⚠️ getStageProgress error: $e');
      return null;
    }
  }

  // 🔹 진행상태 저장 (Firestore + 로컬)
  Future<void> saveProgress(String uid, StageProgressModel progress) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(progress.stageId)
          .set(progress.toJson());
    } catch (e) {
      debugPrint('⚠️ saveProgress error: $e');
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('progress_${progress.stageId}', progress.toJsonString());
  }

  // 🔹 잠금 여부
  bool isLocked(StageModel stage, Map<String, StageProgressModel> progressMap) {
    if (stage.unlockCondition == null || stage.unlockCondition!.isEmpty) {
      return false;
    }
    final prevProgress = progressMap[stage.unlockCondition];
    return prevProgress == null || !prevProgress.cleared;
  }

  // 🔹 보상 수령
  Future<void> markRewardClaimed(String uid, String stageId, String starKey) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(stageId)
          .update({'rewards_claimed.$starKey': true});
    } catch (e) {
      debugPrint('⚠️ markRewardClaimed error: $e');
    }
  }

  // 🔹 다음 스테이지 자동 해제
  Future<void> unlockNextStage(String uid, String currentStageId) async {
    try {
      final stages = await loadStages();
      final currentIndex = stages.indexWhere((s) => s.id == currentStageId);
      if (currentIndex == -1 || currentIndex + 1 >= stages.length) return;

      final nextStage = stages[currentIndex + 1];
      final nextId = nextStage.id;

      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(nextId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({
          'stageId': nextId,
          'cleared': false,
          'stars': {"1": false, "2": false, "3": false},
          'rewards_claimed': {"1": false, "2": false, "3": false},
          'lastPlayed': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ unlockNextStage error: $e');
    }
  }

  List<String> getAllStageIds() => _cachedStages.map((s) => s.id).toList();
  List<StageModel> getAllStages() => List.unmodifiable(_cachedStages);
}