import 'package:flutter/material.dart';
import './button_styles.dart';

/// 숫자 입력 패드 (1~9 버튼)
class NumberPad extends StatelessWidget {
  final Function(int) onNumberInput;
  final List<int> numberCounts; // 각 숫자 사용 횟수
  final int? selectedNumber;    // 현재 선택된 셀의 숫자

  const NumberPad({
    super.key,
    required this.onNumberInput,
    required this.numberCounts,
    this.selectedNumber,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 8;
        double buttonWidth = (constraints.maxWidth - spacing * 8) / 9;
        double textSize = buttonWidth < 40 ? 18 : 20;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(9, (index) {
            int number = index + 1;
            bool isUsedUp = numberCounts[number] == 9;
            bool isSelected = selectedNumber == number;

            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: buttonWidth,
                maxWidth: buttonWidth,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: ElevatedButton(
                  onPressed: isUsedUp ? null : () => onNumberInput(number),
                  style: numberButtonStyle.copyWith(
                    backgroundColor: isUsedUp
                        ? MaterialStateProperty.all<Color>(Colors.grey.shade300)
                        : isSelected
                            ? MaterialStateProperty.all<Color>(Colors.blue.shade100) // 배경 강조
                            : null,
                    foregroundColor: isUsedUp
                        ? MaterialStateProperty.all<Color>(Colors.grey)
                        : isSelected
                            ? MaterialStateProperty.all<Color>(Colors.blue) // 글씨 강조
                            : null,
                  ),
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
          }),
        );
      },
    );
  }
}