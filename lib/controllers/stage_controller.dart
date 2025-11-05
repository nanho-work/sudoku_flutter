import 'dart:async' show Timer, unawaited;
import 'package:flutter/foundation.dart';
import '../models/stage_model.dart';
import '../models/stage_progress_model.dart';
import '../services/stage_service.dart';
import '../providers/stage_progress_provider.dart';
import '../services/stage_generator.dart';

/// 🧩 StageController
class StageController extends ChangeNotifier {
  final StageModel stage;
  final String uid;
  final StageService _stageService = StageService();

  late List<List<int>> board;
  late List<List<int>> solution;
  late List<List<Set<int>>> notes;
  late List<int> shape;

  Timer? _timer;
  Duration elapsed = Duration.zero;

  int? selectedRow;
  int? selectedCol;
  bool cleared = false;
  bool timeOver = false;
  int hintsUsed = 0;
  int wrongAttempts = 0;

  StageController({required this.stage, required this.uid}) {
    _initStage();
  }

  void _initStage() {
    final n = stage.gridSize;

    // shape 복원 또는 추론
    if (stage.shape != null && stage.shape!.length == 2) {
      shape = stage.shape!;
    } else {
      shape = _inferBlockShape(n);
    }

    // 퍼즐/솔루션 복원 또는 StageGenerator 사용
    if (stage.puzzle != null && stage.solution != null) {
      board = List.generate(n, (r) => List.generate(n, (c) => stage.puzzle![r][c]));
      solution = List.generate(n, (r) => List.generate(n, (c) => stage.solution![r][c]));
    } else {
      final generated = StageGenerator.generate(
        gridSize: n,
        removeCount: stage.removeCount,
      );
      board = generated['puzzle']!;
      solution = generated['solution']!;
    }

    // 메모 초기화
    notes = List.generate(n, (_) => List.generate(n, (_) => <int>{}));

    // 시간 제한 조건
    final cond = stage.conditions ?? {};
    final int? timeLimit = cond['time_limit'];

    // 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      if (timeLimit != null && timeLimit > 0 && elapsed.inSeconds >= timeLimit) {
        timeOver = true;
        stopTimer();
      }
      notifyListeners();
    });
  }

  List<int> _inferBlockShape(int n) {
    if (n % 3 == 0) return [3, 3];
    if (n % 2 == 0) return [2, n ~/ 2];
    return [1, n];
  }

  void stopTimer() => _timer?.cancel();

  void selectCell(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  void onNumberInput(int number) {
    if (selectedRow == null || selectedCol == null) return;
    if (cleared || timeOver) return;

    final r = selectedRow!;
    final c = selectedCol!;
    if (board[r][c] != 0) return;

    if (number != solution[r][c]) {
      recordWrongAttempt();
      notifyListeners();
      return;
    }

    board[r][c] = number;

    if (_isSolved()) {
      cleared = true;
      stopTimer();
      unawaited(saveProgress());
    }

    notifyListeners();
  }

  bool _isSolved() {
    final n = board.length;
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == 0 || board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  void useHint() {
    if (cleared || timeOver) return;

    // 선택된 셀만 힌트 제공
    if (selectedRow == null || selectedCol == null) return;
    final r = selectedRow!, c = selectedCol!;

    // 이미 채워진 칸이면 무시
    if (board[r][c] != 0) return;

    // 정답 채워넣기
    board[r][c] = solution[r][c];
    hintsUsed++;

    if (_isSolved()) {
      cleared = true;
      stopTimer();
      unawaited(saveProgress());
    }

    notifyListeners();
  }

  void recordWrongAttempt() {
    wrongAttempts++;
    notifyListeners();
  }

  bool get isCleared => cleared;
  int get elapsedSeconds => elapsed.inSeconds;

  /// ✅ 조건 평가 (JSON 기반)
  Map<String, bool> evaluateConditions() {
    final cond = stage.conditions ?? {};
    final int maxHints = cond['max_hints'] ?? 9999;
    final int maxWrong = cond['max_wrong'] ?? 9999;
    final int timeLimit = cond['time_limit'] ?? 0;

    return {
      "1": hintsUsed <= maxHints,
      "2": wrongAttempts <= maxWrong,
      "3": timeLimit == 0 ? true : elapsed.inSeconds <= timeLimit,
    };
  }

  Future<void> saveProgress() async {
    // 기존 진행 데이터 불러오기
    final existing = await _stageService.getStageProgress(uid, stage.id);

    final progress = StageProgressModel(
      stageId: stage.id,
      cleared: cleared,
      stars: evaluateConditions(),
      // 기존 보상 상태 유지
      rewardsClaimed: existing?.rewardsClaimed ??
          const {"1": false, "2": false, "3": false},
      hintsUsed: hintsUsed,
      wrongAttempts: wrongAttempts,
      clearTime: elapsed.inSeconds,
      lastPlayed: DateTime.now(),
    );

    await _stageService.saveProgress(uid, progress);
    await _stageService.unlockNextStage(uid, stage.id);

    try {
      final provider = StageProgressProvider(uid);
      await provider.loadProgress([stage.id]);
    } catch (_) {}
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}