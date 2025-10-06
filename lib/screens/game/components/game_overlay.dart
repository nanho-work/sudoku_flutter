import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';
import '../../../controllers/audio_controller.dart';
import '../../../services/audio_service.dart';
import '../../../controllers/theme_controller.dart';

class GameOverlay extends StatefulWidget {
  const GameOverlay({Key? key}) : super(key: key);

  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  bool _dialogShown = false;

  void _maybeShowDialogs(BuildContext outerContext, GameController controller) {
    // 다이얼로그가 닫혔을 때 플래그를 리셋하는 로직입니다.
    if (_dialogShown && controller.hearts > 0 && !controller.isSolved) {
      _dialogShown = false;
    }

    if (_dialogShown) return;

    if (controller.hearts <= 0) {
      _showGameOverDialog(outerContext);
    } else if (controller.isSolved) {
      _showCompleteDialog(outerContext);
    }
  }

  void _showGameOverDialog(BuildContext outerContext) {
    if (_dialogShown) return;
    _dialogShown = true;

    final audio = context.read<AudioController>();
    audio.playSfx(SoundFiles.gameover);

    final themeController = Provider.of<ThemeController>(context, listen: false);
    final colors = themeController.colors;

    showGeneralDialog(
      context: outerContext,
      barrierDismissible: false,
      barrierColor: Colors.black87, // 더 진한 배경으로 변경
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) => AlertDialog(
        // 💡 UI 개선: 다크 테마 적용
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '게임 오버',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '하트를 모두 소진했습니다.',
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            // 💡 UI 개선: 액센트 컬러 버튼 스타일
            style: TextButton.styleFrom(
              foregroundColor: colors.textPrimary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // 1. 다이얼로그 닫기
              Navigator.of(outerContext, rootNavigator: true).pop();
              // 2. 홈으로 이동: GameScreen 닫기
              Navigator.of(outerContext).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext outerContext) {
    if (_dialogShown) return;
    _dialogShown = true;

    final audio = context.read<AudioController>();
    final controller = context.read<GameController>();
    audio.playSfx(SoundFiles.complete);

    final themeController = Provider.of<ThemeController>(context, listen: false);
    final colors = themeController.colors;

    showGeneralDialog(
      context: outerContext,
      barrierDismissible: false,
      barrierColor: Colors.black87, // 더 진한 배경으로 변경
      pageBuilder: (_, __, ___) => AlertDialog(
        // 💡 UI 개선: 다크 테마 적용
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '축하합니다!',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '퍼즐을 완성했습니다 🎉\n시간: ${controller.formatElapsedTime()}',
          style: TextStyle(color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            // 💡 UI 개선: 액센트 컬러 버튼 스타일
            style: TextButton.styleFrom(
              foregroundColor: colors.textPrimary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // 1. 다이얼로그 닫기
              Navigator.of(outerContext, rootNavigator: true).pop();
              // 2. 홈으로 이동: GameScreen 닫기
              Navigator.of(outerContext).pop();
            },
            child: const Text('홈으로'),
          ),
          TextButton(
            // 💡 UI 개선: 액센트 컬러 버튼 스타일
            style: TextButton.styleFrom(
              foregroundColor: colors.accent,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              controller.restartGame(() {});

              // 1. 플래그를 먼저 리셋하고
              setState(() {
                _dialogShown = false;
              });

              // 2. 다이얼로그 닫기
              Navigator.of(outerContext, rootNavigator: true).pop();
            },
            child: const Text('새 게임'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final themeController = Provider.of<ThemeController>(context);
    final colors = themeController.colors;

    // Widget life cycle에 따라 한 번만 호출되도록 보장합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowDialogs(context, controller);
    });

    return const SizedBox.shrink();
  }
}
