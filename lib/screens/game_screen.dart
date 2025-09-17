import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/sudoku_board.dart';
import '../widgets/number_pad.dart';
import '../services/sudoku_solver.dart';
import '../services/sudoku_generator.dart';
import '../services/mission_service.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/button_styles.dart';
import 'dart:math';

/// 스도쿠 보드 + 숫자 입력 화면
class GameScreen extends StatefulWidget {
  final String difficulty;
  final DateTime? missionDate;

  const GameScreen({super.key, required this.difficulty, this.missionDate});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Map<String, String> difficultyLabels = {
    "easy": "쉬움",
    "normal": "보통",
    "hard": "어려움"
  };
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _bgmStarted = false;
  late BannerAd _bannerAd;
  bool _isBannerReady = false;
  void _startBgmIfNeeded() {
    if (!_bgmStarted) {
      _bgmStarted = true;
      _playBgm();
    }
  }

  late List<List<int>> board;     // 퍼즐 보드 (빈칸 포함)
  late List<List<int>> solution;  // 정답 보드
  late List<List<bool>> fixed;
  int? selectedRow;
  int? selectedCol;
  int? invalidRow;
  int? invalidCol;

  late List<List<Set<int>>> notes;
  bool noteMode = false;
  int hearts = 5;

  late Stopwatch _stopwatch;
  Timer? _timer;

  List<int> numberCounts = List.filled(10, 0); // index=숫자

  int hintsRemaining = 3;
  double cellScale = 1.0;

  Future<void> _playSound(String fileName) async {
    await _audioPlayer.play(AssetSource('sounds/$fileName.mp3'));
  }

  @override
  void initState() {
    super.initState();
    // 난이도에 맞는 퍼즐 + 정답 생성
    final generated = SudokuGenerator.generatePuzzle(widget.difficulty);
    board = generated["puzzle"]!;
    solution = generated["solution"]!;
    fixed = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));
    _updateCounts();
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // 웹 자동재생 제한: 최초 사용자 인터랙션 시 시작합니다.
    _startBgmIfNeeded();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/8722125095', // 테스트용 배너 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerReady = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }
  Future<void> _playBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setSource(AssetSource('sounds/bgm.mp3')); // 경로+확장자 포함
    await _bgmPlayer.resume();
  }

  void _updateCounts() {
    numberCounts = List.filled(10, 0);
    for (var row in board) {
      for (var value in row) {
        if (value != 0) numberCounts[value]++;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  void _onCellTap(int row, int col) {
    _startBgmIfNeeded();
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
  }

  void _onNumberInput(int number) {
    _startBgmIfNeeded();
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      if (board[selectedRow!][selectedCol!] != 0) return;
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
          _playSound('success');
          setState(() {
            board[selectedRow!][selectedCol!] = number;
            notes[selectedRow!][selectedCol!] = <int>{};
            invalidRow = null;
            invalidCol = null;
            _updateCounts();
            fixed[selectedRow!][selectedCol!] = true;
            // cellScale = 1.2; // scaling animation removed
          });
          // Future.delayed(const Duration(milliseconds: 200), () {
          //   if (!mounted) return;
          //   setState(() {
          //     cellScale = 1.0;
          //   });
          // });

          // 퍼즐 완성 여부 체크
          if (_isSolved()) {
            _showCompleteDialog();
          }
        } else {
          _playSound('fail');
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

  Future<void> _showCompleteDialog() async {
    _playSound('complete');
    await MissionService.setCleared(DateTime.now());
    await MissionService.setCleared(widget.missionDate ?? DateTime.now());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("축하합니다!"),
        content: Text("퍼즐을 완성했습니다 🎉\n시간: ${_formatElapsedTime()}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // close game screen, go to home
            },
            child: const Text("홈으로"),
          ),
          TextButton(
            onPressed: () {
              _restartGame();
              Navigator.of(context).pop(); // close dialog only
            },
            child: const Text("새 게임"),
          ),
        ],
      ),
    );
  }

  void _gameOver() {
    _playSound('gameover');
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
    _startBgmIfNeeded();
    _playSound('click');
    final generated = SudokuGenerator.generatePuzzle(widget.difficulty);
    setState(() {
      board = generated["puzzle"]!;
      solution = generated["solution"]!;
      fixed = List.generate(9, (r) => List.generate(9, (c) => board[r][c] != 0));
      selectedRow = null;
      selectedCol = null;
      notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
      noteMode = false;
      hearts = 5;
      hintsRemaining = 3;
      _stopwatch.reset();
      _stopwatch.start();
      _updateCounts();
    });
  }

  void _clearCell() {
    _playSound('click');
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      setState(() {
        board[selectedRow!][selectedCol!] = 0;
        notes[selectedRow!][selectedCol!] = <int>{};
        _updateCounts();
      });
    }
  }

  void _showHint() {
    _startBgmIfNeeded();
    if (selectedRow != null && selectedCol != null) {
      if (fixed[selectedRow!][selectedCol!]) return;
      if (hintsRemaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("힌트가 모두 소진되었습니다")),
        );
        return;
      }
      _playSound('hint');
      setState(() {
        board[selectedRow!][selectedCol!] = solution[selectedRow!][selectedCol!];
        _updateCounts();
        hintsRemaining--;
      });
      if (_isSolved()) {
        _showCompleteDialog();
      }
    }
  }

  void _autoFill() {
    bool filledAny = false;

    // Check rows
    for (int r = 0; r < 9; r++) {
      int emptyCount = 0;
      int emptyCol = -1;
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          emptyCount++;
          emptyCol = c;
        }
      }
      if (emptyCount == 1) {
        if (!fixed[r][emptyCol]) {
          setState(() {
            board[r][emptyCol] = solution[r][emptyCol];
            notes[r][emptyCol] = <int>{};
            _updateCounts();
          });
          filledAny = true;
        }
      }
    }

    // Check columns
    for (int c = 0; c < 9; c++) {
      int emptyCount = 0;
      int emptyRow = -1;
      for (int r = 0; r < 9; r++) {
        if (board[r][c] == 0) {
          emptyCount++;
          emptyRow = r;
        }
      }
      if (emptyCount == 1) {
        if (!fixed[emptyRow][c]) {
          setState(() {
            board[emptyRow][c] = solution[emptyRow][c];
            notes[emptyRow][c] = <int>{};
            _updateCounts();
          });
          filledAny = true;
        }
      }
    }

    // Check 3x3 boxes
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        int emptyCount = 0;
        int emptyR = -1;
        int emptyC = -1;
        for (int r = boxRow * 3; r < boxRow * 3 + 3; r++) {
          for (int c = boxCol * 3; c < boxCol * 3 + 3; c++) {
            if (board[r][c] == 0) {
              emptyCount++;
              emptyR = r;
              emptyC = c;
            }
          }
        }
        if (emptyCount == 1) {
          if (!fixed[emptyR][emptyC]) {
            setState(() {
              board[emptyR][emptyC] = solution[emptyR][emptyC];
              notes[emptyR][emptyC] = <int>{};
              _updateCounts();
            });
            filledAny = true;
          }
        }
      }
    }

    if (!filledAny) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("자동 채우기할 수 있는 칸이 없습니다."),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 24, left: 24, right: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _playSound('success');
      if (_isSolved()) {
        _showCompleteDialog();
      }
    }
  }

  String _formatElapsedTime() {
    final seconds = _stopwatch.elapsed.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = min(screenSize.width * 0.9, screenSize.height * 0.5)- 40; // 0.5는 하단 버튼 포함 여유 고려 예시
    return Scaffold(
      appBar: AppBar(title: const Text("스도쿠")),
      body: Column(
        children: [
          if (_isBannerReady)
            Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              alignment: Alignment.center,
              child: AdWidget(ad: _bannerAd),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: boardSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "난이도: ${difficultyLabels[widget.difficulty] ?? widget.difficulty}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "시간: ${_formatElapsedTime()}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < hearts ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.red,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                    child: NumberPad(
                      onNumberInput: _onNumberInput,
                      numberCounts: numberCounts,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: boardSize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _restartGame,
                          style: actionButtonStyle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Icon(Icons.refresh),
                              SizedBox(height: 4),
                              Text("새 게임"),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: hintsRemaining > 0 ? _showHint : null,
                          style: actionButtonStyle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.lightbulb),
                              const SizedBox(height: 4),
                              Text("힌트 ($hintsRemaining)"),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _playSound('click');
                            setState(() {
                              noteMode = !noteMode;
                            });
                          },
                          style: actionButtonStyle.copyWith(
                            backgroundColor: WidgetStatePropertyAll(noteMode ? Colors.blue : Colors.grey[600]),
                            foregroundColor: noteMode
                                ? const WidgetStatePropertyAll(Colors.white)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_note),
                              const SizedBox(height: 4),
                              Text(noteMode ? "메모 " : "메모 "),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _autoFill,
                          style: actionButtonStyle,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_fix_high),
                              SizedBox(height: 4),
                              Text("채우기"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}