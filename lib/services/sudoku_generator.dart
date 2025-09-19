import 'dart:math';

class SudokuGenerator {
  static final Random _random = Random();

  // 퍼즐 생성: 후보 칸 셔플, 최대 시도 제한
  static Map<String, List<List<int>>> generatePuzzle(String difficulty) {
    List<List<int>> solution = _generateSolvedBoard();

    int removeCount;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        removeCount = 35; // 쉽게 40칸 제거
        break;
      case 'normal':
        removeCount = 45;
        break;
      case 'hard':
        removeCount = 55; // 하드 난이도도 55~58로 제한 (성능 고려)
        break;
      default:
        removeCount = 40;
    }

    List<List<int>> puzzle = _removeNumbersEfficiently(solution, removeCount);
    return {"puzzle": puzzle, "solution": solution};
  }
  
  // 백트래킹 정답 보드 생성
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

  static bool _isSafe(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // 칸 제거 성능 개선버전
  static List<List<int>> _removeNumbersEfficiently(
      List<List<int>> board, int removeCount) {
    List<List<int>> puzzle =
        board.map((row) => List<int>.from(row)).toList(); // 깊은 복사

    // 모든 좌표를 리스트로, 셔플
    List<Map<String, int>> cells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        cells.add({"row": r, "col": c});
      }
    }
    cells.shuffle(_random);

    int removed = 0, idx = 0, maxTries = cells.length * 2;
    while (removed < removeCount && idx < cells.length && maxTries-- > 0) {
      int row = cells[idx]["row"] as int;
      int col = cells[idx]["col"] as int;
      if (puzzle[row][col] != 0) {
        int temp = puzzle[row][col];
        puzzle[row][col] = 0;
        // 유일 해 검사, 최대 2개 해 찾으면 중단
        if (_hasUniqueSolutionFast(puzzle)) {
          removed++;
        } else {
          puzzle[row][col] = temp;
        }
      }
      idx++;
    }
    return puzzle;
  }

  // 빠른 유일 해 체크: 해 2개 발견 시 바로 중단
  static bool _hasUniqueSolutionFast(List<List<int>> board) {
    int solutions = 0;
    bool helper(List<List<int>> b) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (b[r][c] == 0) {
            // 1~9 중 가능한 숫자 최소 후보 우선
            for (int num = 1; num <= 9; num++) {
              if (_isSafe(b, r, c, num)) {
                b[r][c] = num;
                if (helper(b)) {
                  b[r][c] = 0;
                  return true; // 해 2개 이상이면 바로 종료
                }
                b[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      solutions++;
      return solutions > 1; // 해가 두 개면 true(중단)
    }

    List<List<int>> copyBoard = board.map((row) => List<int>.from(row)).toList();
    helper(copyBoard);
    return solutions == 1;
  }
}
