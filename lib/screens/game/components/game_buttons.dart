import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';
import '../../../controllers/audio_controller.dart';
import '../../../controllers/theme_controller.dart';
// import '../../../widgets/button_styles.dart'; // 외부 스타일 대신 내부에서 정의
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
    final controller = context.watch<GameController>();
    final audio = context.read<AudioController>();
    final colors = context.watch<ThemeController>().colors;

    // 💡 다크 테마에 맞는 기본 버튼 스타일 정의
    final ButtonStyle baseActionButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: colors.textPrimary,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      elevation: 8,
    );

    // 💡 힌트 버튼 (비활성화 상태) 스타일 정의
    final ButtonStyle disabledActionButtonStyle = baseActionButtonStyle.copyWith(
      backgroundColor: MaterialStatePropertyAll(colors.card),
      foregroundColor: MaterialStatePropertyAll(colors.textSecondary),
      elevation: const MaterialStatePropertyAll(0),
    );

    void playSfx([bool success = true]) =>
        audio.playSfx(success ? SoundFiles.success : SoundFiles.fail);

    // 💡 스낵바 디자인을 다크 테마에 맞게 개선
    void showToast(String msg) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: TextStyle(color: colors.textPrimary)),
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
              style: baseActionButtonStyle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 20, color: colors.textPrimary),
                  const SizedBox(height: 4),
                  Text("새 게임", textAlign: TextAlign.center, style: TextStyle(color: colors.textPrimary)),
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
                      )
                  : null,
              // 💡 힌트 비활성화 시 스타일 적용
              style: controller.hintsRemaining > 0 ? baseActionButtonStyle : disabledActionButtonStyle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb, size: 20, color: colors.textPrimary),
                  const SizedBox(height: 4),
                  Text("힌트 (${controller.hintsRemaining})", textAlign: TextAlign.center, style: TextStyle(color: colors.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // 3. 메모 (토글 버튼)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                controller.noteMode = !controller.noteMode;
                audio.playSfx(SoundFiles.click);
              },
              // 💡 메모 모드 활성화 시 액센트 색상 적용
              style: baseActionButtonStyle.copyWith(
                backgroundColor: MaterialStatePropertyAll(
                  controller.noteMode ? colors.accent : baseActionButtonStyle.backgroundColor!.resolve({}),
                ),
                foregroundColor: MaterialStatePropertyAll(colors.textPrimary),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note, size: 20, color: colors.textPrimary),
                  const SizedBox(height: 4),
                  Text("메모", textAlign: TextAlign.center, style: TextStyle(color: colors.textPrimary)),
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
              ),
              style: baseActionButtonStyle,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_fix_high, size: 20, color: colors.textPrimary),
                  const SizedBox(height: 4),
                  Text("채우기", textAlign: TextAlign.center, style: TextStyle(color: colors.textPrimary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
