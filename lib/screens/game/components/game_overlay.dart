import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';
import '../../../controllers/audio_controller.dart';
import '../../../services/audio_service.dart';

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

    showGeneralDialog(
      context: outerContext,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (_, __, ___) => AlertDialog(
        title: const Text('게임 오버'),
        content: const Text('하트를 모두 소진했습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              // 1. 다이얼로그 닫기
              Navigator.of(outerContext, rootNavigator: true).pop();
              // 2. ✅ 홈으로 이동: GameScreen 닫기
              Navigator.of(outerContext).pop(); 
              
              // GameScreen이 pop되면 이 위젯도 dispose되므로 _dialogShown 리셋은 불필요하지만,
              // 일관성을 위해 추가할 수 있습니다.
              // setState(() { _dialogShown = false; }); 
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

    showGeneralDialog(
      context: outerContext,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => AlertDialog(
        title: const Text('축하합니다!'),
        content: Text('퍼즐을 완성했습니다 🎉\n시간: ${controller.formatElapsedTime()}'),
        actions: [
          TextButton(
            onPressed: () {
              // 1. 다이얼로그 닫기
              Navigator.of(outerContext, rootNavigator: true).pop(); 
              // 2. 홈으로 이동: GameScreen 닫기
              Navigator.of(outerContext).pop(); 
              // GameScreen이 pop되므로 _dialogShown은 자동으로 정리됨
            },
            child: const Text('홈으로'),
          ),
          TextButton(
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowDialogs(context, controller);
    });

    return const SizedBox.shrink();
  }
}