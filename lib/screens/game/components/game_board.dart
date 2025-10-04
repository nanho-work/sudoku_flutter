import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';
import '../../../widgets/sudoku_board.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final Size screenSize = MediaQuery.of(context).size;
    final double boardSize = (screenSize.width * 0.9).clamp(0, screenSize.height * 0.5) - 40;

    return Center(
      child: SizedBox(
        width: boardSize,
        height: boardSize,
        child: SudokuBoard(
          board: controller.board,
          notes: controller.notes,
          onCellTap: controller.onCellTap,
          selectedRow: controller.selectedRow,
          selectedCol: controller.selectedCol,
          invalidRow: controller.invalidRow,
          invalidCol: controller.invalidCol,
        ),
      ),
    );
  }
}
