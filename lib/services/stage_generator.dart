import 'dart:math';
import 'stage_solver.dart';

/// StageGenerator: Generates regular block (rectangular) Sudoku puzzles.
class StageGenerator {
  /// Generates a Sudoku puzzle and its solution.
  /// [gridSize]: Size of the grid (e.g., 4, 6, 8, 9, etc.)
  /// [removeCount]: Number of cells to remove for puzzle.
  static Map<String, dynamic> generate({
    required int gridSize,
    int? removeCount,
  }) {
    assert(gridSize >= 2, 'gridSize must be >= 2');

    // Infer blockShape strictly as per instructions
    final List<int> shape = _inferBlockShape(gridSize);
    final int blockRows = shape[0], blockCols = shape[1];

    // Generate a solved grid
    final solution = _generateSolvedSudoku(gridSize, blockRows, blockCols);

    // Copy solution for puzzle
    final puzzle = solution.map((row) => List<int>.from(row)).toList();

    // Remove cells
    final remove = removeCount ?? _defaultRemoveCount(gridSize);
    _removeCells(puzzle, remove, Random());

    return {
      "gridSize": gridSize,
      "shape": [blockRows, blockCols],
      "puzzle": puzzle,
      "solution": solution,
    };
  }

  /// Infers block shape strictly as per instructions.
  static List<int> _inferBlockShape(int gridSize) {
    if (gridSize == 2) return [2, 2];
    if (gridSize == 4) return [2, 2];
    if (gridSize == 6) return [2, 3];
    if (gridSize == 8) return [2, 4];
    if (gridSize == 9) return [3, 3];
    // Fallback to 1 x gridSize
    return [1, gridSize];
  }

  /// Default number of cells to remove for given grid size.
  static int _defaultRemoveCount(int n) {
    final total = n * n;
    if (n <= 3) return (total * 0.25).round();
    if (n <= 5) return (total * 0.35).round();
    if (n <= 7) return (total * 0.45).round();
    return (total * 0.55).round();
  }

  /// Removes [removeCount] cells randomly from [board].
  static void _removeCells(List<List<int>> board, int removeCount, Random rand) {
    final n = board.length;
    final cells = <int>[];
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        cells.add(r * n + c);
      }
    }
    cells.shuffle(rand);
    for (int i = 0; i < removeCount && i < cells.length; i++) {
      final idx = cells[i];
      final r = idx ~/ n;
      final c = idx % n;
      board[r][c] = 0;
    }
  }

  /// Generates a solved Sudoku grid using backtracking.
  static List<List<int>> _generateSolvedSudoku(int n, int blockRows, int blockCols) {
    final grid = List.generate(n, (_) => List.filled(n, 0));
    final rand = Random();
    bool solve(int row, int col) {
      if (row == n) return true;
      final nextRow = col == n - 1 ? row + 1 : row;
      final nextCol = col == n - 1 ? 0 : col + 1;
      final nums = List<int>.generate(n, (i) => i + 1)..shuffle(rand);
      for (final num in nums) {
        if (_isSafe(grid, row, col, num, n, blockRows, blockCols)) {
          grid[row][col] = num;
          if (solve(nextRow, nextCol)) return true;
          grid[row][col] = 0;
        }
      }
      return false;
    }
    solve(0, 0);
    return grid;
  }

  static bool _isSafe(List<List<int>> grid, int row, int col, int num, int n, int blockRows, int blockCols) {
    // Row and column
    for (int i = 0; i < n; i++) {
      if (grid[row][i] == num || grid[i][col] == num) return false;
    }
    // Block
    final startRow = (row ~/ blockRows) * blockRows;
    final startCol = (col ~/ blockCols) * blockCols;
    for (int r = 0; r < blockRows; r++) {
      for (int c = 0; c < blockCols; c++) {
        if (grid[startRow + r][startCol + c] == num) return false;
      }
    }
    return true;
  }
}