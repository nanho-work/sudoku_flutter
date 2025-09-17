/// 퍼즐 생성 서비스 (난이도별 퍼즐 자동 생성)
import 'dart:math';

class SudokuGenerator {
  static final Random _random = Random();

  /// 난이도별 퍼즐 생성
  static Map<String, List<List<int>>> generatePuzzle(String difficulty) {
    // 1. 정답 보드 생성
    List<List<int>> solution = _generateSolvedBoard();

    // 2. 난이도별 제거할 칸 수 지정
    int removeCount;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        removeCount = 40; // 약 35칸 제거 (쉬움)
        break;
      case 'normal':
        removeCount = 50; // 약 50칸 제거 (보통)
        break;
      case 'hard':
        removeCount = 60; // 약 65칸 제거 (어려움)
        break;
      default:
        removeCount = 40;
    }

    // 3. 칸 제거해서 퍼즐 생성
    List<List<int>> puzzle = _removeNumbers(solution, removeCount);

    return {
      "puzzle": puzzle,
      "solution": solution,
    };
  }

  /// 백트래킹으로 정답 보드 생성
  static List<List<int>> _generateSolvedBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  static bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1)..shuffle(_random);
          for (int num in numbers) {
            if (_isSafe(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// 숫자 배치 가능 여부 체크
  static bool _isSafe(List<List<int>> board, int row, int col, int num) {
    // 행, 열 검사
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    // 3x3 박스 검사
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  /// 난이도에 따라 지정한 개수만큼 칸 비우기
  static List<List<int>> _removeNumbers(List<List<int>> board, int removeCount) {
    List<List<int>> puzzle =
        board.map((row) => List<int>.from(row)).toList(); // 복사본 생성

    int removed = 0;
    while (removed < removeCount) {
      int row = _random.nextInt(9);
      int col = _random.nextInt(9);

      if (puzzle[row][col] != 0) {
        int temp = puzzle[row][col];
        puzzle[row][col] = 0;
        if (_hasUniqueSolution(puzzle)) {
          removed++;
        } else {
          puzzle[row][col] = temp;
        }
      }
    }
    return puzzle;
  }

  static bool _hasUniqueSolution(List<List<int>> board) {
    int solutions = 0;

    bool solve(List<List<int>> b) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (b[r][c] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (_isSafe(b, r, c, num)) {
                b[r][c] = num;
                if (solve(b)) {
                  b[r][c] = 0;
                  return true;
                }
                b[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      solutions++;
      return solutions > 1 ? true : false;
    }

    List<List<int>> copyBoard = board.map((row) => List<int>.from(row)).toList();
    solve(copyBoard);
    return solutions == 1;
  }
}