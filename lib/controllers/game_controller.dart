import 'package:flutter/material.dart';
import '../services/sudoku_solver.dart';
import '../services/sudoku_generator.dart';
import '../services/mission_service.dart';
import 'dart:async';

class GameController extends ChangeNotifier {
  final Map<String, String> difficultyLabels = {
    "easy": "쉬움",
    "normal": "보통",
    "hard": "어려움"
  };

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
  Timer? timer;

  List<int> numberCounts = List.filled(10, 0);

  int hintsRemaining = 3;

  final String difficulty;
  final DateTime? missionDate;

  GameController(this.difficulty, this.missionDate) {
    _initGame();
  }

  // 게임을 초기화하고 퍼즐, 해답, 고정 셀, 노트, 타이머 등을 설정합니다.
  void _initGame() {
    final generated = SudokuGenerator.generatePuzzle(difficulty);
    board = generated["puzzle"]!;
    solution = generated["solution"]!;
    fixed = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));
    _updateCounts();
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    stopwatch = Stopwatch()..start();
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    selectedRow = null;
    selectedCol = null;
    noteMode = false;
    hearts = 5;
    hintsRemaining = 3;
    invalidRow = null;
    invalidCol = null;
    notifyListeners();
  }

  // 현재 보드에서 각 숫자의 사용 개수를 갱신합니다.
  void _updateCounts() {
    numberCounts = List.filled(10, 0);
    for (var row in board) {
      for (var value in row) {
        if (value != 0) numberCounts[value]++;
      }
    }
  }

  // 컨트롤러가 dispose될 때 타이머와 스톱워치를 정지합니다.
  void disposeController() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  // 셀을 터치했을 때 선택된 행과 열을 갱신하고 알림을 보냅니다.
  void onCellTap(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  // 숫자 입력 시 노트 모드 여부에 따라 셀에 숫자 또는 노트를 추가/제거하며, 정답 여부에 따라 효과음을 재생하고 목숨을 차감합니다.
  void onNumberInput(int number, void Function(bool correct) playSfx, void Function(String msg) showError) {
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      if (board[selectedRow!][selectedCol!] != 0) return;
      if (noteMode) {
        if (notes[selectedRow!][selectedCol!].contains(number)) {
          notes[selectedRow!][selectedCol!].remove(number);
        } else {
          notes[selectedRow!][selectedCol!].add(number);
        }
        notifyListeners();
      } else {
        if (SudokuSolver.isValid(board, selectedRow!, selectedCol!, number) &&
          SudokuSolver.isCorrect(solution, selectedRow!, selectedCol!, number)) {
          playSfx(true);
          board[selectedRow!][selectedCol!] = number;
          notes[selectedRow!][selectedCol!] = <int>{};
          invalidRow = null;
          invalidCol = null;
          _updateCounts();
          fixed[selectedRow!][selectedCol!] = true;
          if (_isSolved()) {
            notifyListeners();
          }
          notifyListeners();
        } else {
          playSfx(false);
          hearts--;
          invalidRow = selectedRow;
          invalidCol = selectedCol;
          notifyListeners();
          if (hearts <= 0) {
            // Game Over handled by UI
          } else {
            showError("잘못된 숫자입니다!");
            Future.delayed(const Duration(milliseconds: 500), () {
              invalidRow = null;
              invalidCol = null;
              notifyListeners();
            });
          }
        }
      }
    }
  }

  // 퍼즐이 모두 올바르게 풀렸는지 확인합니다.
  bool _isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }
  bool get isSolved => _isSolved();
  

  // 게임을 재시작하며 효과음을 재생하고 초기화합니다.
  void restartGame(void Function() playSfx) {
    playSfx();
    _initGame();
  }

  // 선택된 셀의 값을 지우고 노트도 초기화합니다.
  void clearCell() {
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      board[selectedRow!][selectedCol!] = 0;
      notes[selectedRow!][selectedCol!] = <int>{};
      _updateCounts();
      notifyListeners();
    }
  }

  // 힌트 사용 시 정답을 셀에 입력하고 힌트 개수를 차감합니다.
  void showHint(void Function() playSfx, void Function(String) showToast) {
    playSfx();
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      if (hintsRemaining <= 0) {
        showToast("힌트가 모두 소진되었습니다");
        return;
      }
      board[selectedRow!][selectedCol!] = solution[selectedRow!][selectedCol!];
      _updateCounts();
      hintsRemaining--;
      if (_isSolved()) {
        notifyListeners();
      }
      notifyListeners();
    }
  }

  // 자동 채우기: 한 행, 열, 박스에 비어있는 칸이 하나일 때 그 칸을 정답으로 채웁니다.
  void autoFill(void Function() playSfx, void Function(String) showToast) {
    playSfx();
    bool filledAny = false;
    // ... 로직 생략 — 기존 autoFill 로직 동일하게 복붙 ...

    for (int r = 0; r < 9; r++) {
      int emptyCount = 0;
      int emptyCol = -1;
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          emptyCount++;
          emptyCol = c;
        }
      }
      if (emptyCount == 1) {
        if (!fixed[r][emptyCol]) {
          board[r][emptyCol] = solution[r][emptyCol];
          notes[r][emptyCol] = <int>{};
          _updateCounts();
          filledAny = true;
        }
      }
    }
    for (int c = 0; c < 9; c++) {
      int emptyCount = 0;
      int emptyRow = -1;
      for (int r = 0; r < 9; r++) {
        if (board[r][c] == 0) {
          emptyCount++;
          emptyRow = r;
        }
      }
      if (emptyCount == 1) {
        if (!fixed[emptyRow][c]) {
          board[emptyRow][c] = solution[emptyRow][c];
          notes[emptyRow][c] = <int>{};
          _updateCounts();
          filledAny = true;
        }
      }
    }
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        int emptyCount = 0;
        int emptyR = -1;
        int emptyC = -1;
        for (int r = boxRow * 3; r < boxRow * 3 + 3; r++) {
          for (int c = boxCol * 3; c < boxCol * 3 + 3; c++) {
            if (board[r][c] == 0) {
              emptyCount++;
              emptyR = r;
              emptyC = c;
            }
          }
        }
        if (emptyCount == 1 && !fixed[emptyR][emptyC]) {
          board[emptyR][emptyC] = solution[emptyR][emptyC];
          notes[emptyR][emptyC] = <int>{};
          _updateCounts();
          filledAny = true;
        }
      }
    }
    if (!filledAny) {
      showToast("자동 채우기할 수 있는 칸이 없습니다.");
    }
    if (_isSolved()) notifyListeners();
    notifyListeners();
  }

  // 스톱워치의 경과 시간을 "MM:SS" 형식의 문자열로 반환합니다.
  String formatElapsedTime() {
    final seconds = stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
