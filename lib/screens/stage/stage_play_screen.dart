import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../widgets/sudoku_board.dart';
import '../game/components/number_pad.dart';
import '../../services/sudoku_solver.dart';   // ✅ 자동 정답 검증
import 'stage_info_bar.dart';
import 'reward_popup.dart';

/// 스테이지 플레이 화면
class StagePlayScreen extends StatefulWidget {
  final StageModel stage;
  final UserModel? user;

  const StagePlayScreen({
    super.key,
    required this.stage,
    this.user,
  });

  @override
  State<StagePlayScreen> createState() => _StagePlayScreenState();
}

class _StagePlayScreenState extends State<StagePlayScreen> {
  late List<List<int>> board;
  late List<List<Set<int>>> notes;
  Timer? _timer;
  Duration elapsed = Duration.zero;
  int? selectedRow;
  int? selectedCol;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    assert(widget.stage.gridSize == 9, '현재 SudokuBoard는 9x9만 지원합니다.');

    board = List.generate(
      9,
      (r) => List.generate(9, (c) => widget.stage.puzzle[r][c]),
    );
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _onNumberInput(int num) {
    if (selectedRow == null || selectedCol == null) return;
    setState(() {
      board[selectedRow!][selectedCol!] = num;
    });
    _checkCompletion();
  }

  void _checkCompletion() {
    if (_dialogShowing) return;
    if (!SudokuSolver.isSolved(board)) return;

    _dialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RewardPopup(
        stage: widget.stage,
        user: widget.user,
        stars: const {'1': true, '2': true, '3': true},
        onClose: () {
          if (mounted) {
            Navigator.of(context).pop(); // 팝업 닫기
            Navigator.of(context).pop(); // 스테이지 선택으로 복귀
          }
        },
      ),
    ).then((_) => _dialogShowing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stage.name)),
      body: Column(
        children: [
          StageInfoBar(stage: widget.stage, elapsed: elapsed),
          Expanded(
            child: Center(
              child: SudokuBoard(
                board: board,
                notes: notes,
                onCellTap: _onCellTap,
                selectedRow: selectedRow,
                selectedCol: selectedCol,
              ),
            ),
          ),
          NumberPad(
            onNumberInput: _onNumberInput,
            numberCounts: List.filled(10, 0),
          ),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _checkCompletion,
        label: const Text('검증'),
        icon: const Icon(Icons.verified),
      ),
    );
  }
}