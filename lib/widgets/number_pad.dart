import 'package:flutter/material.dart';
import './button_styles.dart';

/// 숫자 입력 패드 (1~9 버튼)
class NumberPad extends StatelessWidget {
  final Function(int) onNumberInput;
  final List<int> numberCounts;  // 각 숫자 사용 횟수

  const NumberPad({
    super.key,
    required this.onNumberInput,
    required this.numberCounts,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 9, // 9개 숫자를 한 줄에 고정
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: List.generate(9, (index) {
        int number = index + 1;
        bool isUsedUp = numberCounts[number] != null && numberCounts[number] == 9;

        return ElevatedButton(
          onPressed: isUsedUp ? null : () => onNumberInput(number),
          style: numberButtonStyle.copyWith(
            backgroundColor: isUsedUp
                ? MaterialStateProperty.all<Color>(Colors.grey.shade300)
                : null,
            foregroundColor: isUsedUp
                ? MaterialStateProperty.all<Color>(Colors.grey)
                : null,
          ),
          child: Text(number.toString()),
        );
      }),
    );
  }
}