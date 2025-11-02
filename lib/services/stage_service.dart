import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../models/stage_progress_model.dart';

class StageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firestore → 로컬 동기화
  Future<void> syncStagesFromFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = await _db.collection('stages').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      await prefs.setString('stage_${doc.id}', jsonEncode(data));
    }
  }

  // 스테이지 로드 (Firestore 기준, 실패 시 로컬)
  Future<List<StageModel>> loadStages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<StageModel> stages = [];

    try {
      final snapshot = await _db.collection('stages').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        stages.add(StageModel.fromJson(data));
        await prefs.setString('stage_${doc.id}', jsonEncode(data));
      }
      return stages;
    } catch (e) {
      print('⚠️ Firestore load failed: $e');
      return await loadStagesFromLocal();
    }
  }

  // 로컬 로드
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
    return stages;
  }

  // 진행상태 로드 (로컬)
  Future<StageProgressModel?> loadLocalProgress(String stageId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('progress_$stageId');
    if (data == null) return null;
    return StageProgressModel.fromJson(jsonDecode(data));
  }

  // 진행상태 로드 (Firestore)
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
      print('⚠️ getStageProgress error: $e');
      return null;
    }
  }

  // 진행상태 저장
  Future<void> saveProgress(String uid, StageProgressModel progress) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(progress.stageId)
          .set(progress.toJson());
    } catch (e) {
      print('⚠️ saveProgress error: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('progress_${progress.stageId}', progress.toJsonString());
  }

  // 잠금 해제 여부
  bool isLocked(StageModel stage, Map<String, StageProgressModel> progressMap) {
    if (stage.unlockCondition == null || stage.unlockCondition!.isEmpty) {
      return false;
    }
    final prevProgress = progressMap[stage.unlockCondition];
    return prevProgress == null || !prevProgress.cleared;
  }

  // 보상 수령 처리
  Future<void> markRewardClaimed(String uid, String stageId, String starKey) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('stage_progress')
          .doc(stageId)
          .update({'rewards_claimed.$starKey': true});
    } catch (e) {
      print('⚠️ markRewardClaimed error: $e');
    }
  }

  Future<void> unlockNextStage(String uid, String currentStageId) async {
    try {
        // 모든 스테이지 로드
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
}