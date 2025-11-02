/// 🔹 StageSolver (비정형 블록 + 블록 크기별 숫자 제한)
/// 2~9 모든 크기 지원
class StageSolver {
  static bool solve(
    List<List<int>> board, {
    required List<List<int>> blockPattern,
  }) {
    final n = board.length;
    final blockSizes = _computeBlockSizes(blockPattern);

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (board[r][c] == 0) {
          final blockId = blockPattern[r][c];
          final maxVal = blockSizes[blockId]!.clamp(1, n);
          for (int num = 1; num <= maxVal; num++) {
            if (_isSafe(board, blockPattern, r, c, num, blockSizes)) {
              board[r][c] = num;
              if (solve(board, blockPattern: blockPattern)) return true;
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  /// 유일해 판정
  static bool hasUniqueSolution(
    List<List<int>> board, {
    required List<List<int>> blockPattern,
  }) {
    final blockSizes = _computeBlockSizes(blockPattern);
    int count = 0;

    bool helper(List<List<int>> b) {
      final n = b.length;
      for (int r = 0; r < n; r++) {
        for (int c = 0; c < n; c++) {
          if (b[r][c] == 0) {
            final blockId = blockPattern[r][c];
            final maxVal = blockSizes[blockId]!.clamp(1, n);
            for (int num = 1; num <= maxVal; num++) {
              if (_isSafe(b, blockPattern, r, c, num, blockSizes)) {
                b[r][c] = num;
                if (helper(b)) return true;
                b[r][c] = 0;
              }
            }
            return false;
          }
        }
      }
      count++;
      return count > 1;
    }

    final clone = board.map((r) => List<int>.from(r)).toList();
    helper(clone);
    return count == 1;
  }

  /// 블록 크기 계산
  static Map<int, int> _computeBlockSizes(List<List<int>> pattern) {
    final map = <int, int>{};
    for (final row in pattern) {
      for (final id in row) {
        map[id] = (map[id] ?? 0) + 1;
      }
    }
    return map;
  }

  /// 검증: 행/열/블록 중복 + 블록 크기 기반 숫자 제한
  static bool _isSafe(
    List<List<int>> board,
    List<List<int>> pattern,
    int row,
    int col,
    int num,
    Map<int, int> blockSizes,
  ) {
    final n = board.length;
    final blockId = pattern[row][col];
    final blockMax = blockSizes[blockId]!;

    // 블록 크기보다 큰 숫자는 불가
    if (num > blockMax) return false;

    // 행/열 중복 금지
    for (int i = 0; i < n; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    // 같은 블록 내 중복 금지
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        if (pattern[r][c] == blockId && board[r][c] == num) return false;
      }
    }
    return true;
  }
}