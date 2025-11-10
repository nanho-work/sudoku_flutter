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
      if (await file.exists()) {
        debugPrint('📂 캐시 존재하여 다운로드 생략: $name, path=${file.path}');
        return;
      }
      debugPrint('📄 다운로드 시도 파일명: $name');
      debugPrint('📍 예상 저장 경로: ${file.path}');

      final res = await http.get(Uri.parse(url));
      debugPrint('🌐 HTTP 응답 상태코드: ${res.statusCode}');
      debugPrint('📦 content-type: ${res.headers['content-type']}');

      final contentType = res.headers['content-type'] ?? '';
      final isJson = url.toLowerCase().endsWith('.json') ||
          contentType.contains('application/json');

      if (isJson) {
        await file.writeAsString(utf8.decode(res.bodyBytes), flush: true);
      } else {
        await file.writeAsBytes(res.bodyBytes, flush: true);
      }
      debugPrint('💾 파일 저장 확인: exists=${await file.exists()}, size=${await file.length()} bytes, path=${file.path}');
      debugPrint('✅ 다운로드 완료: $name');
    } catch (e) {
      debugPrint('⚠️ 다운로드 실패 ($url): $e');
    }
  }

  static Future<String?> getLocalPath(String key) async {
    if (key.isEmpty) return null;
    try {
      debugPrint('🧭 getLocalPath() 호출됨 - key: $key');

      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/skins');

      if (!await folder.exists()) {
        debugPrint('⚠️ 스킨 폴더 없음: ${folder.path}');
        return null;
      }

      // 1) key가 URL이면 파일명만 추출, 아니면 그대로 사용
      String decodedName;
      if (key.startsWith('http')) {
        debugPrint('🔍 URL 기반 키 감지, 파일명 파싱 시도');
        final uri = Uri.parse(key);
        final rawName = uri.pathSegments.last.split('?').first;
        final decoded = Uri.decodeComponent(rawName);
        decodedName = decoded.contains('/')
            ? decoded.split('/').last
            : decoded;
      } else {
        // URL이 아닌 경우(id 또는 파일명 자체)
        decodedName = key;
      }

      debugPrint('🔍 기본 매칭 이름: $decodedName');

      // 2) 정확히 일치하는 파일 먼저 탐색
      final exactFile = File('${folder.path}/$decodedName');
      if (await exactFile.exists()) {
        debugPrint('📂 캐시 파일(정확 일치) 발견: ${exactFile.path}');
        return exactFile.path;
      }

      // 3) 접두사 기반 확장자 매칭 (bg_koofy_lv1 → bg_koofy_lv1.json / .png 등)
      final files = folder.listSync();
      for (final f in files.whereType<File>()) {
        final name = f.uri.pathSegments.last;
        if (name == decodedName || name.startsWith('$decodedName.')) {
          debugPrint('🔎 접두사 매칭 발견: $name → ${f.path}');
          return f.path;
        }
      }

      debugPrint('🟠 캐시 파일 없음: $decodedName');
      try {
        final dirList = folder.listSync().map((e) => e.path).join(', ');
        debugPrint('📁 현재 스킨 폴더 파일: $dirList');
      } catch (e2) {
        debugPrint('⚠️ 상위폴더 조회 실패: $e2');
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ 로컬 경로 조회 실패 ($key): $e');
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