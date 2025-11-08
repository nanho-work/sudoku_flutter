import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/skin_model.dart';

class SkinLocalCache {
  static const _kCatalog = 'skins_catalog_json';
  static const _kState = 'skins_state_json';

  static Future<void> saveCatalog(List<SkinItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCatalog, jsonEncode(list.map((e) => e.toMap()).toList()));
  }

  static Future<List<SkinItem>?> loadCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCatalog);
    if (raw == null) return null;
    final List data = jsonDecode(raw);
    return data.map((e) => SkinItem.fromMap(Map<String, dynamic>.from(e))).toList();
  }

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

  static Future<void> downloadToDocuments(String url) async {
    if (url.isEmpty) return;

    // ✅ 1. 로컬 에셋 경로는 다운로드 시도 안 함
    if (url.startsWith('assets/')) {
      debugPrint('🟡 로컬 에셋 경로 무시: $url');
      return;
    }

    try {
      final uri = Uri.parse(url);
      final decodedPath = Uri.decodeComponent(uri.path);
      final segments = decodedPath.split('/').where((s) => s.isNotEmpty).toList();

      final dir = await getApplicationDocumentsDirectory();
      final folderPath = '${dir.path}/skins';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      final name = segments.last.split('?').first;
      final file = File('$folderPath/$name');
      if (await file.exists()) return;

      final res = await http.get(Uri.parse(url));
      final contentType = res.headers['content-type'] ?? '';
      final isJson = url.toLowerCase().endsWith('.json') ||
          contentType.contains('application/json');

      if (isJson) {
        await file.writeAsString(utf8.decode(res.bodyBytes), flush: true);
      } else {
        await file.writeAsBytes(res.bodyBytes, flush: true);
      }
      debugPrint('✅ 다운로드 완료: $name');
    } catch (e) {
      debugPrint('⚠️ 다운로드 실패 ($url): $e');
    }
  }

  static Future<String?> getLocalPath(String url) async {
    if (url.isEmpty) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = Uri.parse(url).pathSegments.last.split('?').first;
      final file = File('${dir.path}/skins/$name');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ 로컬 경로 조회 실패 ($url): $e');
      return null;
    }
  }

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