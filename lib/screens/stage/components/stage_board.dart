import 'package:flutter/material.dart';

/// 🎯 StageBoard (정사각형 블록 기반)
/// gridSize와 shape(blockRows, blockCols)만으로 블록 경계 처리
class StageBoard extends StatelessWidget {
  final List<List<int>> board;
  final int? selectedRow;
  final int? selectedCol;
  final List<int> shape; // [blockRows, blockCols]
  final void Function(int, int)? onCellTap;

  const StageBoard({
    super.key,
    required this.board,
    required this.shape,
    this.selectedRow,
    this.selectedCol,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final n = board.length;
    final blockRows = shape[0];
    final blockCols = shape[1];

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          children: List.generate(n, (r) {
            return Expanded(
              child: Row(
                children: List.generate(n, (c) {
                  final value = board[r][c];
                  final isSelected = selectedRow == r && selectedCol == c;

                  // 🔹 블록 경계 판단 (정형 구조)
                  final bool topBorder = r % blockRows == 0;
                  final bool leftBorder = c % blockCols == 0;
                  final bool rightBorder = (c + 1) % blockCols == 0;
                  final bool bottomBorder = (r + 1) % blockRows == 0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onCellTap?.call(r, c),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.yellow.shade100
                              : Colors.white,
                          border: Border(
                            top: BorderSide(
                                color: Colors.black,
                                width: topBorder ? 1.5 : 0.3),
                            left: BorderSide(
                                color: Colors.black,
                                width: leftBorder ? 1.5 : 0.3),
                            right: BorderSide(
                                color: Colors.black,
                                width: rightBorder ? 1.5 : 0.3),
                            bottom: BorderSide(
                                color: Colors.black,
                                width: bottomBorder ? 1.5 : 0.3),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          value == 0 ? '' : value.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _fontSize(n),
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  double _fontSize(int n) {
    if (n <= 4) return 22;
    if (n <= 6) return 18;
    return 14;
  }
}