import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ranking_model.dart';

class RankingService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'game_records';

  /// ------------ Week key helpers ------------
  static String currentWeekKey({DateTime? now}) => _generateWeekKey(now ?? DateTime.now());

  /// Year-week key like "2025-W43" (Mon-start)
  static String _generateWeekKey(DateTime date) {
    // ISO-week like 계산의 근사치. 월요일 시작.
    final monday = date.subtract(Duration(days: (date.weekday + 6) % 7));
    final firstMonday = _firstMondayOfYear(date.year);
    final weekNumber = (monday.difference(firstMonday).inDays ~/ 7) + 1;
    return '${date.year}-W$weekNumber';
  }

  static DateTime _firstMondayOfYear(int year) {
    final d = DateTime(year, 1, 1);
    final offset = (d.weekday + 6) % 7; // Mon=0 ... Sun=6
    return d.subtract(Duration(days: offset));
  }

  /// ------------ Deterministic doc id ------------
  static String _docId({
    required String userId,
    required String difficulty,
    required String gameMode,
    required String weekKey,
  }) =>
      '$weekKey|$gameMode|$difficulty|$userId';

  /// 허용 난이도 검증
  static bool _isValidDifficulty(String d) =>
      d == 'easy' || d == 'normal' || d == 'hard' || d == 'extreme';

  /// 🔹 최고 기록 저장/갱신 (동일 주차·모드·난이도·유저 1문서 보장)
  static Future<void> saveOrUpdateBestRecord(RankingRecord record) async {
    final weekKey = currentWeekKey();
    if (!_isValidDifficulty(record.difficulty)) {
      throw ArgumentError('invalid difficulty: ${record.difficulty}');
    }

    final docId = _docId(
      userId: record.userId,
      difficulty: record.difficulty,
      gameMode: record.gameMode,
      weekKey: weekKey,
    );

    await _db.runTransaction((txn) async {
      final ref = _db.collection(_collection).doc(docId);
      final snap = await txn.get(ref);

      if (snap.exists) {
        final existing = RankingRecord.fromMap(snap.data()!);

        // 더 빠른 기록만 갱신
        if (record.clearTime < existing.clearTime) {
          txn.update(ref, {
            'clearTime': record.clearTime,
            'device': record.device,
            // 서버 시간으로 갱신
            'recordedAt': FieldValue.serverTimestamp(),
            // 닉네임은 캐시형이므로 최근 값으로 동기화(옵션)
            'nickname': record.nickname,
          });
        }
      } else {
        final map = record.toMap()
          ..['weekKey'] = weekKey
          ..['recordedAt'] = FieldValue.serverTimestamp();
        txn.set(ref, map, SetOptions(merge: true));
      }
    });
  }

  /// 🔹 특정 난이도 상위 랭킹(기본: 이번 주)
  /// 필요 인덱스 (콘솔에서 생성 안내됨):
  /// where(difficulty) + where(gameMode) + where(weekKey) + orderBy(clearTime)
  static Future<List<RankingRecord>> getTopRankings(
    String difficulty, {
    int limit = 20,
    String? weekKey,
    String gameMode = 'classic',
  }) async {
    final wk = weekKey ?? currentWeekKey();
    if (!_isValidDifficulty(difficulty)) return [];

    var query = _db
        .collection(_collection)
        .where('difficulty', isEqualTo: difficulty)
        .where('gameMode', isEqualTo: gameMode)
        .where('weekKey', isEqualTo: wk)
        .orderBy('clearTime', descending: false)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map((d) => RankingRecord.fromMap(d.data())).toList();
  }

  /// 🔹 유저 개인 기록 리스트(최신순). 주차 필터 옵션.
  static Future<List<RankingRecord>> getUserRecords(
    String userId, {
    String? weekKey,
    int limit = 50,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    var q = _db.collection(_collection).where('userId', isEqualTo: userId);
    if (weekKey != null) q = q.where('weekKey', isEqualTo: weekKey);
    q = q.orderBy('recordedAt', descending: true).limit(limit);

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    final snap = await q.get();
    return snap.docs.map((d) => RankingRecord.fromMap(d.data())).toList();
  }

  /// 🔹 유저의 특정 주차·난이도·모드 **최고기록 단건** 조회
  static Future<RankingRecord?> getUserBestForWeek({
    required String userId,
    required String difficulty,
    String gameMode = 'classic',
    String? weekKey,
  }) async {
    final wk = weekKey ?? currentWeekKey();
    final docId = _docId(
      userId: userId,
      difficulty: difficulty,
      gameMode: gameMode,
      weekKey: wk,
    );
    final snap = await _db.collection(_collection).doc(docId).get();
    if (!snap.exists) return null;
    return RankingRecord.fromMap(snap.data()!);
  }

  /// 🔹 주차 목록 조회 (최신순)
  static Future<List<String>> getAvailableWeeks({
    String gameMode = 'classic',
    String? difficulty,
    int limit = 12,
  }) async {
    var q = _db.collection(_collection)
      .where('gameMode', isEqualTo: gameMode)
      .orderBy('weekKey', descending: true)
      .limit(limit);

    if (difficulty != null && _isValidDifficulty(difficulty)) {
      q = q.where('difficulty', isEqualTo: difficulty);
    }

    final snap = await q.get();
    final keys = snap.docs.map((d) => d['weekKey'] as String? ?? '').where((k) => k.isNotEmpty).toSet().toList();
    keys.sort((a, b) => b.compareTo(a)); // 최신순
    return keys;
  }

  /// 🔹 실시간 랭킹 스트림
  static Stream<List<RankingRecord>> streamTopRankings(
    String difficulty, {
    String? weekKey,
    String gameMode = 'classic',
    int limit = 100,
  }) {
    final wk = weekKey ?? currentWeekKey();
    return _db
        .collection(_collection)
        .where('difficulty', isEqualTo: difficulty)
        .where('gameMode', isEqualTo: gameMode)
        .where('weekKey', isEqualTo: wk)
        .orderBy('clearTime', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => RankingRecord.fromMap(d.data())).toList());
  }
  /// 🔹 주차 키를 사람이 보기 좋은 형식으로 변환 ("2025-W44" → "2025년 44주차")
  static String formatWeekLabel(String weekKey) {
    final parts = weekKey.split('-W');
    if (parts.length == 2) {
      final year = parts[0];
      final week = parts[1];
      return '${year}년 ${week}주차';
    }
    return weekKey;
  }
}