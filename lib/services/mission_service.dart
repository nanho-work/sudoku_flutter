import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class MissionService {
  static const String _missionKey = 'mission_completed_date';
  static const String _missionsKey = 'missions_completed_dates';

  /// 오늘 클리어 여부 (레거시 호환)
  static Future<bool> isClearedToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ✅ 캐시 최신화
    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final stored = prefs.getString(_missionKey);
    final result = stored == todayStr;
    return result;
  }

  /// 오늘을 클리어로 저장 (레거시 대비)
  static Future<void> setClearedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _formatDate(DateTime.now());
    await prefs.setString(_missionKey, todayStr);
  }

  /// 특정 날짜를 클리어로 저장
  static Future<void> setCleared(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = _formatDate(date);


    // 기존 목록 불러오기 + 중복 제거
    final List<String> current = prefs.getStringList(_missionsKey) ?? [];
    final Set<String> updated = {...current, dateStr};

    // 저장
    await prefs.setStringList(_missionsKey, updated.toList());
    await prefs.reload(); // ✅ 저장 직후 캐시 갱신 추가
  }

  /// 특정 날짜가 클리어 되었는지
  static Future<bool> isCleared(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // ✅ 최신화
    final dateStr = _formatDate(date);

    final List<String> stored = prefs.getStringList(_missionsKey) ?? [];
    final result = stored.contains(dateStr);
    return result;
  }

  /// 해당 월의 클리어 날짜 목록
  static Future<List<DateTime>> getClearedDatesInMonth(DateTime monthDate) async {
    final y = monthDate.year;
    final m = monthDate.month;

    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList(_missionsKey) ?? [];

    // 'yyyy-MM-dd' 문자열을 DateTime으로 변환
    final result = <DateTime>[];
    for (final s in stored) {
      try {
        final parts = s.split('-');
        if (parts.length == 3) {
          final d = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          if (d.year == y && d.month == m) result.add(d);
        }
      } catch (e) {
      }
    }

    return result;
  }

  /// 내부 공통 포맷터 — 항상 yyyy-MM-dd 형태로 변환
  static String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return "${normalized.year.toString().padLeft(4, '0')}-"
        "${normalized.month.toString().padLeft(2, '0')}-"
        "${normalized.day.toString().padLeft(2, '0')}";
  }
}