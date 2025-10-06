import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/audio_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../services/audio_service.dart';
// import '../../../widgets/button_styles.dart'; // 외부 스타일 대신 내부에서 정의

/// 숫자 입력 패드 (1~9 버튼)
/// 레이아웃: 1~5 (첫 번째 줄), 6~9 + 빈 공간 (두 번째 줄)
class NumberPad extends StatelessWidget {
  final Function(int) onNumberInput;
  final List<int> numberCounts; // 각 숫자 사용 횟수 (index 1~9 사용)
  final int? selectedNumber;    // 현재 선택된 셀의 숫자

  // 💡 버튼이 과도하게 커지는 것을 방지하기 위한 최대 너비 설정
  static const double maxButtonSize = 60.0;
  static const double minTextSize = 18.0;
  static const double maxTextSize = 20.0;
  // 💡 GameScreen의 좌우 패딩에 맞춰 16.0으로 조정
  static const double horizontalPadding = 16.0; 

  const NumberPad({
    super.key,
    required this.onNumberInput,
    required this.numberCounts,
    this.selectedNumber,
  });

  // 💡 [핵심] 숫자 버튼을 생성하는 공통 빌더 함수
  Widget _buildNumberButton({
    required BuildContext context,
    required int number,
    required double buttonWidth,
    required double textSize,
    required AudioController audio,
    required Color accentColor,
    required Color buttonBaseColor,
    required Color disabledColor,
    required Color textColor,
  }) {
    // numberCounts는 1부터 9까지의 사용 횟수를 담고 있다고 가정
    bool isUsedUp = numberCounts[number] == 9;
    bool isSelected = selectedNumber == number;
    
    // 기본 스타일 정의
    final baseStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
      elevation: isUsedUp ? 0 : 8,
      shadowColor: isSelected ? accentColor.withOpacity(0.5) : Colors.black,
    );
    
    // 버튼 상태에 따른 색상 정의
    Color? bgColor;
    Color? fgColor;

    if (isUsedUp) {
      // 1. 사용 완료 (Used Up)
      bgColor = disabledColor;
      fgColor = Colors.white38;
    } else if (isSelected) {
      // 2. 현재 선택된 셀의 값과 일치
      bgColor = accentColor;
      fgColor = Colors.black; // 밝은 배경에 검은색 텍스트
    } else {
      // 3. 기본 상태
      bgColor = buttonBaseColor;
      fgColor = textColor;
    }
    
    final buttonStyle = baseStyle.copyWith(
      backgroundColor: MaterialStatePropertyAll(bgColor),
      foregroundColor: MaterialStatePropertyAll(fgColor),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        // 💡 buttonWidth가 maxButtonSize보다 커지지 않도록 제약
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
      ),
      child: AspectRatio(
        aspectRatio: 1, // 정사각형 버튼
        child: ElevatedButton(
          onPressed: isUsedUp
              ? null // 사용 완료 시 비활성화
              : () {
                  audio.playSfx(SoundFiles.click);
                  onNumberInput(number);
                },
          style: buttonStyle,
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: textSize,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, // 선택 시 더욱 굵게
            ),
          ),
        ),
      ),
    );
  }

  // 💡 빈 공간 플레이스 홀더 (5번째 칸)
  Widget _buildEmptyPlaceholder({required double buttonWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
      ),
      child: const AspectRatio(
        aspectRatio: 1,
        child: SizedBox.shrink(), // 빈 공간만 차지하는 투명 위젯
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioController>();
    final colors = context.watch<ThemeController>().colors;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 8;
        
        // 1. 유효 너비 (Padding 제외) 계산
        // constraints.maxWidth는 GameScreen의 ConstrainedBox(maxWidth: 600) 내에서 계산되므로,
        // 별도의 외부 패딩 계산 없이 내부 여백만 고려합니다.
        double effectiveWidth = constraints.maxWidth - (horizontalPadding * 2);
        
        // 2. 5개 버튼이 채울 수 있는 계산된 너비
        double calculatedWidth = (effectiveWidth - spacing * 4) / 5; 

        // 💡 핵심 수정: 버튼 너비에 maxButtonSize 제약을 적용
        double buttonWidth = calculatedWidth.clamp(0.0, maxButtonSize);
        
        // 텍스트 크기: 버튼 너비에 비례하되, 최소/최대 크기 제한
        double textSize = buttonWidth * 0.4; 
        textSize = textSize.clamp(minTextSize, maxTextSize); 
        
        // --- 버튼 리스트 생성 (중앙 정렬을 위해 명시적 나열) ---
        List<Widget> buildRow1Buttons() {
          List<Widget> buttons = [];
          for (int i = 1; i <= 5; i++) {
            buttons.add(_buildNumberButton(
              context: context,
              number: i,
              buttonWidth: buttonWidth,
              textSize: textSize,
              audio: audio,
              accentColor: colors.accent,
              buttonBaseColor: colors.surface,
              disabledColor: colors.cleared,
              textColor: colors.textPrimary,
            ));
            if (i < 5) {
              buttons.add(SizedBox(width: spacing));
            }
          }
          return buttons;
        }

        List<Widget> buildRow2Buttons() {
          List<Widget> buttons = [];
          for (int i = 6; i <= 9; i++) {
            buttons.add(_buildNumberButton(
              context: context,
              number: i,
              buttonWidth: buttonWidth,
              textSize: textSize,
              audio: audio,
              accentColor: colors.accent,
              buttonBaseColor: colors.surface,
              disabledColor: colors.cleared,
              textColor: colors.textPrimary,
            ));
            buttons.add(SizedBox(width: spacing));
          }
          // 빈 공간 플레이스 홀더 추가 (5번째 칸)
          buttons.add(_buildEmptyPlaceholder(buttonWidth: buttonWidth));
          return buttons;
        }
        // -------------------------------------------------------------------

        return Padding(
          // 💡 동적 여백 16.0 적용
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // --- 1. 첫 번째 줄 (1, 2, 3, 4, 5) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildRow1Buttons(),
              ),

              SizedBox(height: spacing), // 두 줄 사이의 간격

              // --- 2. 두 번째 줄 (6, 7, 8, 9, 빈 공간) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildRow2Buttons(),
              ),
            ],
          ),
        );
      },
    );
  }
}
