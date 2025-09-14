/// 퍼즐 풀이 및 검증 서비스
class SudokuSolver {
  // 주어진 숫자가 해당 위치에 유효한지 검사
  static bool isValid(List<List<int>> board, int row, int col, int num) {
    if (board[row][col] != 0) return false; // 이미 채워진 칸이면 불가
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // 빈 칸을 찾아서 위치를 반환, 없으면 null 반환
  static List<int>? findEmpty(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          return [row, col];
        }
      }
    }
    return null;
  }

  // 백트래킹을 이용하여 퍼즐을 푸는 메서드
  static bool solve(List<List<int>> board) {
    final emptyPos = findEmpty(board);
    if (emptyPos == null) {
      return true; // 모든 칸이 채워졌으면 성공
    }
    int row = emptyPos[0];
    int col = emptyPos[1];

    for (int num = 1; num <= 9; num++) {
      if (isValid(board, row, col, num)) {
        board[row][col] = num;
        if (solve(board)) {
          return true;
        }
        board[row][col] = 0; // 되돌리기
      }
    }
    return false; // 해당 위치에 어떤 숫자도 넣을 수 없음
  }

  // 퍼즐이 모두 채워지고 유효한지 검사
  static bool isSolved(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        int num = board[row][col];
        if (num == 0 || !isValidForCheck(board, row, col, num)) {
          return false;
        }
      }
    }
    return true;
  }

  // isValid와 달리 현재 위치의 숫자를 제외하고 검사
  static bool isValidForCheck(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (i != col && board[row][i] == num) return false;
      if (i != row && board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int curRow = startRow + i;
        int curCol = startCol + j;
        if ((curRow != row || curCol != col) && board[curRow][curCol] == num) {
          return false;
        }
      }
    }
    return true;
  }
  // 정답 보드와 비교하여 입력값이 맞는지 확인
  static bool isCorrect(List<List<int>> solution, int row, int col, int num) {
    return solution[row][col] == num;
  }
}