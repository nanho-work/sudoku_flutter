import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import '../models/skin_model.dart';
import '../services/skin_service.dart';
import '../services/skin_local_cache.dart';

/// 온라인 우선, 실패 시 로컬 캐시 fallback.
/// 상태는 외부에서 Provider(ChangeNotifierProvider)로 감싸 사용.
class SkinController extends ChangeNotifier {
  List<SkinItem> _catalog = [];
  SkinState? _state;

  final Map<String, String?> _localImagePath = {};
  final Map<String, String?> _localBgPath = {};
  final Map<String, LottieComposition> _compositionCache = {};

  List<SkinItem> get catalog => _catalog;
  SkinState? get state => _state;

  LottieComposition? getComposition(String key) => _compositionCache[key];

  void cacheComposition(String url, LottieComposition comp) {
    _compositionCache[url] = comp;
  }

  String? localBgPathByUrl(String url) => _localBgPath[url];


  Future<String?> getLocalImagePath(String url) async {
    if (url.isEmpty) return null;
    final cached = _localImagePath[url];
    if (cached != null) return cached;
    return await SkinLocalCache.getLocalPath(url);
  }

  Future<String?> getLocalBgPath(String url) async {
    if (url.isEmpty) return null;
    final cached = _localBgPath[url];
    if (cached != null) return cached;
    return await SkinLocalCache.getLocalPath(url);
  }

  /// 동기: 이미지 로컬 경로 반환
  String? getLocalImagePathSync(String url) {
    if (url.isEmpty) return null;
    return _localImagePath[url];
  }

  /// 동기: 배경 로컬 경로 반환
  String? getLocalBgPathSync(String url) {
    if (url.isEmpty) return null;
    return _localBgPath[url];
  }
  

  SkinItem? get selectedChar => _catalog.firstWhere(
        (e) => e.id == _state?.selectedCharId,
        orElse: () => _fallbackChar(),
      );

  SkinItem? get selectedBg {
    final char = selectedChar;
    if (char?.bgUrl == null) return null;
    return SkinItem(
      id: 'bg_virtual_${char!.id}',
      type: 'bg',
      name: '${char.name} 배경',
      imageUrl: char.bgUrl!,
      bgUrl: char.bgUrl!,
    );
  }

  SkinItem _fallbackChar() =>
      SkinService.fallbackCatalog().firstWhere((e) => e.type == 'char');

  Future<void> _preloadLocalPaths() async {
    for (final item in _catalog) {
      final localImg = await SkinLocalCache.getLocalPath(item.imageUrl);
      if (localImg != null) _localImagePath[item.imageUrl] = localImg;

      if (item.bgUrl != null) {
        final localBg = await SkinLocalCache.getLocalPath(item.bgUrl!);
        if (localBg != null) _localBgPath[item.bgUrl!] = localBg;
      }
    }
  }

  Future<void> initSkins(String userId) async {
    try {
      _catalog = await SkinLocalCache.loadCatalog() ?? SkinService.fallbackCatalog();
      _state = await SkinLocalCache.loadState() ??
          SkinState(
            selectedCharId: 'char_koofy_lv1',
            selectedBgId: 'bg_koofy_lv1',
            unlockedIds: {'char_koofy_lv1', 'bg_koofy_lv1'},
            updatedAt: DateTime.now(),
          );

      await _preloadLocalPaths();
      notifyListeners();

      unawaited(loadAll(userId));
    } catch (_) {}
  }

  Future<void> loadAll(String userId) async {
    try {
      final remoteCatalog = await SkinService.fetchCatalog();
      if (remoteCatalog.isNotEmpty) {
        _catalog = remoteCatalog;
        await SkinLocalCache.saveCatalog(_catalog);
      }

      _state = await SkinService.fetchOrInitUserState(userId, _catalog);
      await SkinLocalCache.saveState(_state!);

      await _preloadLocalPaths();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> select(String userId, {String? charId, String? bgId}) async {
    if (_state == null) return;

    _state = _state!.copyWith(
      selectedCharId: charId ?? _state!.selectedCharId,
      selectedBgId: bgId ?? _state!.selectedBgId,
      updatedAt: DateTime.now(),
    );

    await SkinLocalCache.saveState(_state!);
    notifyListeners();

    try {
      await SkinService.select(userId, charId: charId, bgId: bgId);
    } catch (_) {}
  }

  bool isUnlocked(String skinId) => _state?.unlockedIds.contains(skinId) ?? false;
}