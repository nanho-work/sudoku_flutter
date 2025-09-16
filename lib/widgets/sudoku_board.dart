import 'package:flutter/material.dart';

/// 스도쿠 보드 UI
class SudokuBoard extends StatelessWidget {
  final List<List<int>> board;
  final List<List<Set<int>>> notes;
  final Function(int, int) onCellTap;
  final int? selectedRow;
  final int? selectedCol;
  final int? invalidRow;
  final int? invalidCol;

  const SudokuBoard({
    super.key,
    required this.board,
    required this.notes,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    this.invalidRow,
    this.invalidCol,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 9,
      ),
      itemCount: 81,
      itemBuilder: (context, index) {
        final row = index ~/ 9;
        final col = index % 9;
        final value = board[row][col];

        final isSelected = (row == selectedRow && col == selectedCol);
        final isHighlighted = (selectedRow != null && row == selectedRow) ||
            (selectedCol != null && col == selectedCol);
        final isInvalid = (row == invalidRow && col == invalidCol);

        final selectedValue = (selectedRow != null && selectedCol != null)
            ? board[selectedRow!][selectedCol!]
            : 0;
        final isSameValueHighlighted =
            value != 0 && selectedValue != 0 && value == selectedValue;

        return GestureDetector(
          onTap: () => onCellTap(row, col),
          child: Container(
            decoration: BoxDecoration(
              color: isInvalid
                  ? Colors.red.withOpacity(0.4)
                  : isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : (isHighlighted ? Colors.grey.withOpacity(0.15) : Colors.white),
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: row % 3 == 0 ? 2 : 0.5,
                ),
                left: BorderSide(
                  color: Colors.black,
                  width: col % 3 == 0 ? 2 : 0.5,
                ),
                right: BorderSide(
                  color: Colors.black,
                  width: col == 8 ? 2 : 0.5,
                ),
                bottom: BorderSide(
                  color: Colors.black,
                  width: row == 8 ? 2 : 0.5,
                ),
              ),
            ),
            child: Center(
              child: value != 0
                  ? Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            isSameValueHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isSameValueHighlighted ? Colors.blue[900] : Colors.black,
                      ),
                    )
                  : (notes[row][col].isNotEmpty
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: notes[row][col]
                              .map((note) => Text(
                                    note.toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ))
                              .toList(),
                        )
                      : const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }
}