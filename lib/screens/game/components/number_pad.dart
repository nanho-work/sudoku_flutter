import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/audio_controller.dart';
import '../../../services/audio_service.dart';
import '../../../widgets/button_styles.dart'; // button_styles.dart import 유지

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
  }) {
    // numberCounts는 1부터 9까지의 사용 횟수를 담고 있다고 가정
    bool isUsedUp = numberCounts[number] == 9;
    bool isSelected = selectedNumber == number;
    
    // 버튼 스타일 설정 (사용 횟수 및 선택 상태 반영)
    final buttonStyle = numberButtonStyle.copyWith(
      backgroundColor: isUsedUp
          ? MaterialStateProperty.all<Color>(Colors.grey.shade300)
          : isSelected
              ? MaterialStateProperty.all<Color>(Colors.blue.shade100)
              : null,
      foregroundColor: isUsedUp
          ? MaterialStateProperty.all<Color>(Colors.grey)
          : isSelected
              ? MaterialStateProperty.all<Color>(Colors.blue)
              : null,
      elevation: isUsedUp ? MaterialStateProperty.all<double>(0) : null,
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    
    // 💡 좌우 여백 값 (GameHeader, GameBoard와 동일하게 20.0으로 설정)
    const double horizontalPadding = 40.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 8;
        
        // 1. 유효 너비 (Padding 제외) 계산
        double effectiveWidth = constraints.maxWidth - (horizontalPadding * 2);
        
        // 2. 5개 버튼이 채울 수 있는 계산된 너비
        double calculatedWidth = (effectiveWidth - spacing * 4) / 5; 

        // 💡 핵심 수정: 버튼 너비에 maxButtonSize 제약을 적용
        double buttonWidth = calculatedWidth.clamp(0.0, maxButtonSize);
        
        // 텍스트 크기: 버튼 너비에 비례하되, 최소/최대 크기 제한
        double textSize = buttonWidth.clamp(minTextSize, maxTextSize); 
        
        // --- 버튼 리스트 생성 (중앙 정렬을 위해 List.generate 대신 명시적 나열) ---
        List<Widget> buildRow1Buttons() {
          List<Widget> buttons = [];
          for (int i = 1; i <= 5; i++) {
            buttons.add(_buildNumberButton(
              context: context,
              number: i,
              buttonWidth: buttonWidth,
              textSize: textSize,
              audio: audio,
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
            ));
            buttons.add(SizedBox(width: spacing));
          }
          // 빈 공간 플레이스 홀더 추가 (5번째 칸)
          buttons.add(_buildEmptyPlaceholder(buttonWidth: buttonWidth));
          return buttons;
        }
        // -------------------------------------------------------------------

        return Padding(
          // 💡 동적 여백 20.0 적용
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              // --- 1. 첫 번째 줄 (1, 2, 3, 4, 5) ---
              Row(
                // 💡 [수정] 중앙 정렬로 변경
                mainAxisAlignment: MainAxisAlignment.center,
                children: buildRow1Buttons(),
              ),

              SizedBox(height: spacing), // 두 줄 사이의 간격

              // --- 2. 두 번째 줄 (6, 7, 8, 9, 빈 공간) ---
              Row(
                // 💡 [수정] 중앙 정렬로 변경
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
