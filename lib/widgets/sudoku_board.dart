import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

/// 스도쿠 보드 (전역 공용)
class SudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<List<Set<int>>> notes;
  final Function(int, int) onCellTap;
  final int? selectedRow;
  final int? selectedCol;
  final int? invalidRow;
  final int? invalidCol;
  final double? size; // ✅ 외부에서 크기 조절 가능

  const SudokuBoard({
    super.key,
    required this.board,
    required this.notes,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    this.invalidRow,
    this.invalidCol,
    this.size,
  });

  static bool canAddMemo(List<List<int>> board, int row, int col, int number) {
    for (int c = 0; c < 9; c++) if (board[row][c] == number) return false;
    for (int r = 0; r < 9; r++) if (board[r][col] == number) return false;
    int sr = (row ~/ 3) * 3, sc = (col ~/ 3) * 3;
    for (int r = sr; r < sr + 3; r++) {
      for (int c = sc; c < sc + 3; c++) {
        if (board[r][c] == number) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final double boardSize = size ??
      (MediaQuery.of(context).size.width - 32)
          .clamp(0, MediaQuery.of(context).size.height * 0.5);
    final cellSize = boardSize / 9;
    final fontSize = cellSize * 0.8; // 셀 크기에 맞춰 크게 표시
          
    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final value = board[row][col];
            final isSelected = (row == selectedRow && col == selectedCol);
            final isHighlighted = (selectedRow != null && row == selectedRow) ||
                (selectedCol != null && col == selectedCol);
            final isInvalid = (row == invalidRow && col == invalidCol);

            final selectedValue =
                (selectedRow != null && selectedCol != null)
                    ? board[selectedRow!][selectedCol!]
                    : 0;
            final isSameValueHighlighted =
                value != 0 && selectedValue != 0 && value == selectedValue;

            return GestureDetector(
              onTap: () => onCellTap(row, col),
              child: Container(
                decoration: BoxDecoration(
                  color: isInvalid
                      ? colors.cellInvalid.withOpacity(0.4)
                      : isSelected
                          ? colors.cellSelected.withOpacity(0.3)
                          : isSameValueHighlighted
                              ? colors.cellSelected.withOpacity(0.3)
                              : (isHighlighted
                                  ? colors.cellHighlighted.withOpacity(0.15)
                                  : colors.cellDefault),
                  border: Border(
                    top: BorderSide(
                        color: Colors.black,
                        width: row % 3 == 0 ? 2 : 0.5),
                    left: BorderSide(
                        color: Colors.black,
                        width: col % 3 == 0 ? 2 : 0.5),
                    right: BorderSide(
                        color: Colors.black,
                        width: col == 8 ? 2 : 0.5),
                    bottom: BorderSide(
                        color: Colors.black,
                        width: row == 8 ? 2 : 0.5),
                  ),
                ),
                child: Center(
                  child: value != 0
                      ? Text(
                          value.toString(),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: TextStyle(
                            fontSize: fontSize,
                            height: 1.0,
                            fontWeight: isSameValueHighlighted
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSameValueHighlighted
                                ? colors.textMain
                                : colors.textSub,
                          ),
                        )
                      : _buildNotes(context, row, col, colors),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotes(
      BuildContext context, int row, int col, dynamic colors) {
    final visibleNotes = notes[row][col]
        .where((note) => SudokuBoard.canAddMemo(board, row, col, note))
        .toList();
    if (visibleNotes.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.topLeft,
      child: Wrap(
        children: visibleNotes
            .map((n) => Text(
                  n.toString(),
                  style: TextStyle(fontSize: 10, color: colors.placeholder),
                ))
            .toList(),
      ),
    );
  }
}