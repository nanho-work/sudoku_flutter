import 'package:flutter/material.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../services/sudoku_solver.dart';
import '../services/sudoku_generator.dart';

/// 스도쿠 보드 + 숫자 입력 화면
class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<int>> board;     // 퍼즐 보드 (빈칸 포함)
  late List<List<int>> solution;  // 정답 보드
  int? selectedRow;
  int? selectedCol;
  int? invalidRow;
  int? invalidCol;

  late List<List<Set<int>>> notes;
  bool noteMode = false;
  int hearts = 5;

  @override
  void initState() {
    super.initState();
    // 난이도에 맞는 퍼즐 + 정답 생성
    final generated = SudokuGenerator.generatePuzzle(widget.difficulty);
    board = generated["puzzle"]!;
    solution = generated["solution"]!;
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
  }

  void _onCellTap(int row, int col) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    if (selectedRow != null && selectedCol != null) {
      if (noteMode) {
        setState(() {
          if (notes[selectedRow!][selectedCol!].contains(number)) {
            notes[selectedRow!][selectedCol!].remove(number);
          } else {
            notes[selectedRow!][selectedCol!].add(number);
          }
        });
      } else {
        if (SudokuSolver.isValid(board, selectedRow!, selectedCol!, number) &&
            SudokuSolver.isCorrect(solution, selectedRow!, selectedCol!, number)) {
          setState(() {
            board[selectedRow!][selectedCol!] = number;
            notes[selectedRow!][selectedCol!] = <int>{};
            invalidRow = null;
            invalidCol = null;
          });

          // 퍼즐 완성 여부 체크
          if (_isSolved()) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("축하합니다!"),
                content: const Text("퍼즐을 완성했습니다 🎉"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("확인"),
                  ),
                ],
              ),
            );
          }
        } else {
          setState(() {
            hearts--;
            invalidRow = selectedRow;
            invalidCol = selectedCol;
          });
          if (hearts <= 0) {
            _gameOver();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("잘못된 숫자입니다!"),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(milliseconds: 900),
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (!mounted) return;
              setState(() {
                invalidRow = null;
                invalidCol = null;
              });
            });
          }
        }
      }
    }
  }

  void _gameOver() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("게임 오버"),
        content: const Text("하트를 모두 소진했습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // go back to home
            },
            child: const Text("확인"),
          ),
        ],
      ),
    );
  }

  bool _isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  void _restartGame() {
    final generated = SudokuGenerator.generatePuzzle(widget.difficulty);
    setState(() {
      board = generated["puzzle"]!;
      solution = generated["solution"]!;
      selectedRow = null;
      selectedCol = null;
      notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
      noteMode = false;
      hearts = 5;
    });
  }

  void _clearCell() {
    if (selectedRow != null && selectedCol != null) {
      setState(() {
        board[selectedRow!][selectedCol!] = 0;
        notes[selectedRow!][selectedCol!] = <int>{};
      });
    }
  }

  void _showHint() {
    if (selectedRow != null && selectedCol != null) {
      setState(() {
        board[selectedRow!][selectedCol!] = solution[selectedRow!][selectedCol!];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = screenSize.height * 0.6; // 세로 기준 반응형
    return Scaffold(
      appBar: AppBar(title: Text("난이도 - ${widget.difficulty}")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                );
              }),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: boardSize,
              height: boardSize,
              child: SudokuBoard(
                board: board,
                notes: notes, 
                onCellTap: _onCellTap,
                selectedRow: selectedRow,
                selectedCol: selectedCol,
                invalidRow: invalidRow,
                invalidCol: invalidCol,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: boardSize,
              child: NumberPad(onNumberInput: _onNumberInput),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _restartGame,
                  child: const Text("새 게임"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearCell,
                  child: const Text("지우기"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _showHint,
                  child: const Text("힌트"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      noteMode = !noteMode;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: noteMode ? Colors.orange : null,
                  ),
                  child: Text(noteMode ? "메모 ON" : "메모 OFF"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}