import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';
import '../../../controllers/audio_controller.dart';
import '../../../widgets/button_styles.dart';
import '../../../services/audio_service.dart';

/// 게임 하단 버튼바 (새 게임 / 힌트 / 메모 / 채우기)
class GameButtonBar extends StatelessWidget {
  const GameButtonBar({Key? key}) : super(key: key);

  // 💡 좌우 여백 값 정의 (GameHeader, NumberPad와 동일하게 20.0으로 통일)
  static const double horizontalPadding = 40.0;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final audio = context.read<AudioController>();

    void playSfx([bool success = true]) =>
        audio.playSfx(success ? SoundFiles.success : SoundFiles.fail);

    void showToast(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }

    // 💡 핵심 수정: Row 위젯을 Padding으로 감싸 좌우 여백 20.0 적용
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        // 💡 [수정] 중앙 정렬로 변경
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          ElevatedButton(
            onPressed: () => controller.restartGame(() {
              audio.playSfx(SoundFiles.click);
            }),
            style: actionButtonStyle,
            child: const Column(
              children: [
                Icon(Icons.refresh),
                SizedBox(height: 4),
                Text("새 게임"),
              ],
            ),
          ),
          // 💡 버튼 사이 여백 추가
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.hintsRemaining > 0
                ? () => controller.showHint(
                      () => audio.playSfx(SoundFiles.hint),
                      showToast,
                    )
                : null,
            style: actionButtonStyle,
            child: Column(
              children: [
                const Icon(Icons.lightbulb),
                const SizedBox(height: 4),
                Text("힌트 (${controller.hintsRemaining})"),
              ],
            ),
          ),
          // 💡 버튼 사이 여백 추가
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              controller.noteMode = !controller.noteMode;
              audio.playSfx(SoundFiles.click);
            },
            style: actionButtonStyle.copyWith(
              backgroundColor: WidgetStatePropertyAll(
                controller.noteMode ? Colors.blue : Colors.grey[600],
              ),
              foregroundColor: controller.noteMode
                  ? const WidgetStatePropertyAll(Colors.white)
                  : null,
            ),
            child: const Column(
              children: [
                Icon(Icons.edit_note),
                SizedBox(height: 4),
                Text("메모"),
              ],
            ),
          ),
          // 💡 버튼 사이 여백 추가
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => controller.autoFill(
              () => audio.playSfx(SoundFiles.success),
              showToast,
            ),
            style: actionButtonStyle,
            child: const Column(
              children: [
                Icon(Icons.auto_fix_high),
                SizedBox(height: 4),
                Text("채우기"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
