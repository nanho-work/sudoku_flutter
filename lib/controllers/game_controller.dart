import 'package:flutter/material.dart';
import 'dart:async';

import '../services/sudoku_solver.dart';
import '../services/sudoku_generator.dart';
import '../services/mission_service.dart';

class GameController extends ChangeNotifier {
  final Map<String, String> difficultyLabels = const {
    "easy": "쉬움",
    "normal": "보통",
    "hard": "어려움",
  };

  // 상태
  late List<List<int>> board;
  late List<List<int>> solution;
  late List<List<bool>> fixed;

  int? selectedRow;
  int? selectedCol;
  int? invalidRow;
  int? invalidCol;

  late List<List<Set<int>>> notes;
  bool noteMode = false;
  int hearts = 5;

  late Stopwatch stopwatch;
  Timer? _timer;

  List<int> numberCounts = List.filled(10, 0);
  int hintsRemaining = 3;

  final String difficulty;
  final DateTime? missionDate;

  bool _disposed = false;

  GameController(this.difficulty, this.missionDate) {
    _initGame();
  }

  // 안전 알림
  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  // 초기화
  void _initGame() {
    final generated = SudokuGenerator.generatePuzzle(difficulty);
    board = generated["puzzle"]!;
    solution = generated["solution"]!;
    fixed = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));

    _updateCounts();
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

    stopwatch = Stopwatch()..start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      _safeNotify();
    });

    selectedRow = null;
    selectedCol = null;
    invalidRow = null;
    invalidCol = null;
    noteMode = false;
    hearts = 5;
    hintsRemaining = 3;

    _safeNotify();
  }

  // 해제 (Provider가 호출)
  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  // 카운트 갱신
  void _updateCounts() {
    numberCounts = List.filled(10, 0);
    for (final row in board) {
      for (final v in row) {
        if (v != 0) numberCounts[v]++;
      }
    }
  }

  // 셀 선택
  void onCellTap(int r, int c) {
    if (_disposed) return;
    selectedRow = r;
    selectedCol = c;
    _safeNotify();
  }

  // ✅ 퍼즐 완성 공통 처리: "저장 → 검증 → 알림" (순서 중요)
  Future<void> _onSolved() async {
    if (missionDate != null) {
      try {
        await MissionService.setCleared(missionDate!);

        // (선택) 즉시 검증해서 로그로 남김
        final ok = await MissionService.isCleared(missionDate!);
      } catch (e, st) {
      }
    }

    // 저장이 끝난 뒤 알림 (여기서 UI가 pop될 수 있음)
    _safeNotify();
  }

  // 숫자 입력
  Future<void> onNumberInput(
    int number,
    void Function(bool correct) playSfx,
    void Function(String msg) showError,
  ) async {
    if (_disposed) return;
    if (selectedRow == null || selectedCol == null) return;

    final r = selectedRow!, c = selectedCol!;
    if (fixed[r][c]) return;
    if (board[r][c] != 0) return;

    if (noteMode) {
      final s = notes[r][c];
      if (s.contains(number)) {
        s.remove(number);
      } else {
        s.add(number);
      }
      _safeNotify();
      return;
    }

    final validPlacement = SudokuSolver.isValid(board, r, c, number);
    final isCorrect = SudokuSolver.isCorrect(solution, r, c, number);

    if (validPlacement && isCorrect) {
      playSfx(true);

      board[r][c] = number;
      notes[r][c] = <int>{};
      invalidRow = null;
      invalidCol = null;
      fixed[r][c] = true;
      _updateCounts();

      if (_isSolved()) {
        // ✅ 저장 먼저
        await _onSolved();
      } else {
        _safeNotify();
      }
    } else {
      playSfx(false);
      hearts--;
      invalidRow = r;
      invalidCol = c;
      _safeNotify();

      if (hearts > 0) {
        showError("잘못된 숫자입니다!");
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_disposed) return;
          invalidRow = null;
          invalidCol = null;
          _safeNotify();
        });
      }
    }
  }

  // 퍼즐 완성 판정
  bool _isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }
  bool get isSolved => _isSolved();

  // 재시작
  void restartGame(void Function() playSfx) {
    if (_disposed) return;
    playSfx();
    _initGame();
  }

  // 지우기
  void clearCell() {
    if (_disposed) return;
    if (selectedRow == null || selectedCol == null) return;
    final r = selectedRow!, c = selectedCol!;
    if (fixed[r][c]) return;

    board[r][c] = 0;
    notes[r][c] = <int>{};
    _updateCounts();
    _safeNotify();
  }

  // 힌트 (✅ 완성되면 저장 호출)
  void showHint(void Function() playSfx, void Function(String) showToast) async {
    if (_disposed) return;
    playSfx();

    if (selectedRow == null || selectedCol == null) return;
    final r = selectedRow!, c = selectedCol!;
    if (fixed[r][c]) return;

    if (hintsRemaining <= 0) {
      showToast("힌트가 모두 소진되었습니다");
      return;
    }

    board[r][c] = solution[r][c];
    notes[r][c] = <int>{};
    _updateCounts();
    hintsRemaining--;

    if (_isSolved()) {
      await _onSolved(); // ✅ 저장 먼저
    } else {
      _safeNotify();
    }
  }

  // 자동 채우기 (✅ 완성되면 저장 호출)
  void autoFill(void Function() playSfx, void Function(String) showToast) async {
    if (_disposed) return;
    playSfx();

    bool filledAny = false;

    // 행
    for (int r = 0; r < 9; r++) {
      int empty = 0, ec = -1;
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) { empty++; ec = c; }
      }
      if (empty == 1 && !fixed[r][ec]) {
        board[r][ec] = solution[r][ec];
        notes[r][ec] = <int>{};
        _updateCounts();
        filledAny = true;
      }
    }

    // 열
    for (int c = 0; c < 9; c++) {
      int empty = 0, er = -1;
      for (int r = 0; r < 9; r++) {
        if (board[r][c] == 0) { empty++; er = r; }
      }
      if (empty == 1 && !fixed[er][c]) {
        board[er][c] = solution[er][c];
        notes[er][c] = <int>{};
        _updateCounts();
        filledAny = true;
      }
    }

    // 박스
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        int empty = 0, er = -1, ec = -1;
        for (int r = br * 3; r < br * 3 + 3; r++) {
          for (int c = bc * 3; c < bc * 3 + 3; c++) {
            if (board[r][c] == 0) { empty++; er = r; ec = c; }
          }
        }
        if (empty == 1 && !fixed[er][ec]) {
          board[er][ec] = solution[er][ec];
          notes[er][ec] = <int>{};
          _updateCounts();
          filledAny = true;
        }
      }
    }

    if (!filledAny) {
      showToast("자동 채우기할 수 있는 칸이 없습니다.");
    }

    if (_isSolved()) {
      await _onSolved(); // ✅ 저장 먼저
    } else {
      _safeNotify();
    }
  }

  // 경과시간 포맷
  String formatElapsedTime() {
    final s = stopwatch.elapsed.inSeconds;
    final m = s ~/ 60;
    final rs = s % 60;
    return "${m.toString().padLeft(2, '0')}:${rs.toString().padLeft(2, '0')}";
  }
}