import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin_model.dart';

class SkinLocalCache {
  static const _kCatalog = 'skins_catalog_json';
  static const _kState = 'skins_state_json';

  /// 카탈로그 저장/로드
  static Future<void> saveCatalog(List<SkinItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final arr = list.map((e) => e.toMap()).toList();
    await prefs.setString(_kCatalog, jsonEncode(arr));
  }

  static Future<List<SkinItem>?> loadCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCatalog);
    if (raw == null) return null;
    final List data = jsonDecode(raw);
    return data.map((e) => SkinItem.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  /// 상태 저장/로드
  static Future<void> saveState(SkinState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kState, jsonEncode(_encodeState(state)));
  }

  static Future<SkinState?> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kState);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw));
    return _decodeState(map);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCatalog);
    await prefs.remove(_kState);
  }

  // JSON 직렬화 보조(SharedPreferences엔 Timestamp 못넣음)
  static Map<String, dynamic> _encodeState(SkinState s) => {
        'selectedCharId': s.selectedCharId,
        'selectedBgId': s.selectedBgId,
        'unlockedIds': s.unlockedIds.toList(),
        'updatedAt': s.updatedAt.toIso8601String(),
      };

  static SkinState _decodeState(Map<String, dynamic> m) => SkinState(
        selectedCharId: m['selectedCharId'] ?? 'char_koofy_lv1',
        selectedBgId: m['selectedBgId'] ?? 'bg_koofy_lv1',
        unlockedIds: Set<String>.from((m['unlockedIds'] as List?) ?? const []),
        updatedAt: DateTime.tryParse(m['updatedAt'] ?? '') ?? DateTime.now(),
      );
}