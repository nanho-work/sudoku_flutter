import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/skin_model.dart';
import '../services/skin_service.dart';
import '../services/skin_local_cache.dart';

/// 온라인 우선, 실패 시 로컬 캐시 fallback.
/// 상태는 외부에서 Provider(ChangeNotifierProvider)로 감싸 사용.
class SkinController extends ChangeNotifier {
  List<SkinItem> _catalog = [];
  SkinState? _state;

  List<SkinItem> get catalog => _catalog;
  SkinState? get state => _state;

  SkinItem? get selectedChar =>
      _catalog.firstWhere((e) => e.id == _state?.selectedCharId, orElse: () => _fallbackChar());
  SkinItem? get selectedBg {
    final char = selectedChar;
    if (char == null || char.bgUrl == null) return null;
    return SkinItem(
      id: 'bg_virtual_${char.id}',
      type: 'bg',
      name: '${char.name} 배경',
      imageUrl: char.bgUrl!,
      bgUrl: char.bgUrl!,
    );
  }

  SkinItem _fallbackChar() =>
      SkinService.fallbackCatalog().firstWhere((e) => e.type == 'char');

  /// ✅ 캐시 우선 → 서버 동기화 비동기
  Future<void> initSkins(String userId) async {
    try {
      final cachedCatalog = await SkinLocalCache.loadCatalog();
      final cachedState = await SkinLocalCache.loadState();

      _catalog = cachedCatalog ?? SkinService.fallbackCatalog();
      _state = cachedState ??
          SkinState(
            selectedCharId: 'char_koofy_lv1',
            selectedBgId: 'bg_koofy_lv1',
            unlockedIds: {'char_koofy_lv1', 'bg_koofy_lv1'},
            updatedAt: DateTime.now(),
          );
      notifyListeners(); // 캐시 즉시 반영

      // 백그라운드 서버 동기화
      unawaited(loadAll(userId));
    } catch (_) {
      _catalog = SkinService.fallbackCatalog();
      _state = SkinState(
        selectedCharId: 'char_koofy_lv1',
        selectedBgId: 'bg_koofy_lv1',
        unlockedIds: {'char_koofy_lv1', 'bg_koofy_lv1'},
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// 서버 로드: 성공 시 캐시 갱신
  Future<void> loadAll(String userId) async {
    try {
      final remoteCatalog = await SkinService.fetchCatalog();
      _catalog = remoteCatalog.isNotEmpty
          ? remoteCatalog
          : SkinService.fallbackCatalog();
      await SkinLocalCache.saveCatalog(_catalog);

      _state = await SkinService.fetchOrInitUserState(userId, _catalog);
      await SkinLocalCache.saveState(_state!);
      notifyListeners();
    } catch (_) {
      _catalog = await SkinLocalCache.loadCatalog() ?? SkinService.fallbackCatalog();
      _state = await SkinLocalCache.loadState() ??
          SkinState(
            selectedCharId: 'char_koofy_lv1',
            selectedBgId: 'bg_koofy_lv1',
            unlockedIds: {'char_koofy_lv1', 'bg_koofy_lv1'},
            updatedAt: DateTime.now(),
          );
      notifyListeners();
    }
  }

  bool isUnlocked(String skinId) => _state?.unlockedIds.contains(skinId) ?? false;

  Future<void> setUnlocked(String userId, String skinId, bool unlocked) async {
    if (_state == null) return;
    final next = {..._state!.unlockedIds};
    unlocked ? next.add(skinId) : next.remove(skinId);
    _state = _state!.copyWith(unlockedIds: next, updatedAt: DateTime.now());
    await SkinLocalCache.saveState(_state!);
    notifyListeners();
    try {
      await SkinService.setUnlocked(userId, skinId, unlocked);
    } catch (_) {}
  }

  Future<void> select(String userId, {String? charId, String? bgId}) async {
    if (_state == null) return;
    final next = _state!.copyWith(
      selectedCharId: charId ?? _state!.selectedCharId,
      selectedBgId: bgId ?? _state!.selectedBgId,
      updatedAt: DateTime.now(),
    );
    _state = next;
    await SkinLocalCache.saveState(_state!);
    notifyListeners();
    try {
      await SkinService.select(userId, charId: charId, bgId: bgId);
    } catch (_) {}
  }

  Future<void> sync(String userId) async {
    if (_state == null) return;
    try {
      await SkinService.syncFromLocal(userId, _state!);
    } catch (_) {}
  }
}