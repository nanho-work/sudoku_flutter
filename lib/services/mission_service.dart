import 'package:shared_preferences/shared_preferences.dart';

class MissionService {
  static const String _missionKey = 'mission_completed_date';
  static const String _missionsKey = 'missions_completed_dates';

  /// 오늘 클리어했는지 여부 확인
  static Future<bool> isClearedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // yyyy-MM-dd
    return prefs.getString(_missionKey) == today;
  }

  /// 오늘 클리어로 저장
  static Future<void> setClearedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_missionKey, today);
  }

  /// 특정 날짜를 클리어로 저장
  static Future<void> setCleared(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = date.toIso8601String().substring(0, 10); // yyyy-MM-dd
    final List<String> dates = prefs.getStringList(_missionsKey) ?? [];
    final Set<String> dateSet = dates.toSet();
    dateSet.add(dateStr);
    await prefs.setStringList(_missionsKey, dateSet.toList());
  }

  /// 특정 날짜가 클리어되었는지 확인
  static Future<bool> isCleared(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = date.toIso8601String().substring(0, 10);
    final List<String> dates = prefs.getStringList(_missionsKey) ?? [];
    return dates.contains(dateStr);
  }

  /// 해당 월에 클리어된 모든 날짜 반환
  static Future<List<DateTime>> getClearedDatesInMonth(DateTime monthDate) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> dates = prefs.getStringList(_missionsKey) ?? [];
    final int year = monthDate.year;
    final int month = monthDate.month;
    return dates
        .map((s) => DateTime.tryParse(s))
        .where((d) => d != null && d.year == year && d.month == month)
        .cast<DateTime>()
        .toList();
  }
}