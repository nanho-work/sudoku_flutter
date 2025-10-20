import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import '../../../controllers/game_controller.dart';
import '../../../controllers/audio_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../widgets/button_styles.dart'; // 외부 스타일 대신 내부에서 정의
import '../../../services/audio_service.dart';

/// 게임 하단 버튼바 (새 게임 / 힌트 / 메모 / 채우기)
class GameButtonBar extends StatelessWidget {
  const GameButtonBar({Key? key}) : super(key: key);

  // 💡 좌우 여백 값 정의 (GameHeader, NumberPad와 동일하게 20.0으로 통일)
  // GameScreen의 Padding 위젯에서 EdgeInsets.symmetric(horizontal: 16.0)을 적용했으므로,
  // 여기서는 Row의 좌우 패딩을 16.0으로 맞추거나, 필요하다면 0으로 처리하고 외부에서 패딩을 제어합니다.
  // 여기서는 외부 Padding 위젯에 기대어 0으로 설정하여 내부 여백만 관리합니다.
  static const double horizontalPadding = 16.0; // GameScreen의 기본 Padding과 맞춤


  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final controller = context.watch<GameController>();
    final audio = context.read<AudioController>();
    final colors = context.watch<ThemeController>().colors;

    void playSfx([bool success = true]) =>
        audio.playSfx(success ? SoundFiles.success : SoundFiles.fail);

    // 💡 스낵바 디자인을 다크 테마에 맞게 개선
    void showToast(String msg) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(msg, style: TextStyle(color: colors.textMain)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: colors.accent.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            duration: const Duration(seconds: 2),
          ),
        );
    }

    return Padding(
      // 💡 GameScreen에서 이미 충분한 좌우 여백을 주었으므로, Row 위젯 자체의 패딩은 최소화하거나 제거합니다.
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 공간을 균등 분배
        children: [
          // 1. 새 게임
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.restartGame(() {
                audio.playSfx(SoundFiles.click);
              }),
              style: buttonStyle(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(height: 4),
                  Text(loc.new_game, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. 힌트
          Expanded(
            child: ElevatedButton(
              onPressed: controller.hintsRemaining > 0
                  ? () => controller.showHint(
                        () => audio.playSfx(SoundFiles.hint),
                        showToast,
                        context,
                      )
                  : null,
              // 💡 힌트 비활성화 시 스타일 적용
              style: controller.hintsRemaining > 0
                  ? buttonStyle(context)
                  : buttonStyle(context).copyWith(
                      backgroundColor: MaterialStatePropertyAll(colors.card),
                      foregroundColor: MaterialStatePropertyAll(colors.textSub),
                      elevation: const MaterialStatePropertyAll(0),
                    ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb, size: 20),
                  const SizedBox(height: 4),
                  Text('${loc.game_button_hint} (${controller.hintsRemaining})', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 3. 메모 (토글 버튼)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                controller.toggleNoteMode();
                audio.playSfx(SoundFiles.click);
              },
              // 💡 메모 모드 활성화 시 액센트 색상 적용
              style: buttonStyle(context).copyWith(
                backgroundColor: MaterialStatePropertyAll(
                  controller.noteMode ? colors.accent : colors.easyCard,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_note, size: 20),
                  const SizedBox(height: 4),
                  Text(loc.game_button_note, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 4. 채우기 (오토 필)
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.autoFill(
                () => audio.playSfx(SoundFiles.success),
                showToast,
                context,
              ),
              style: buttonStyle(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_fix_high, size: 20),
                  const SizedBox(height: 4),
                  Text(loc.game_button_auto_fill, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
