import 'package:flutter/material.dart';

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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(9, (index) {
        int number = index + 1;
        bool isUsedUp = numberCounts[number] != null && numberCounts[number] == 9;

        return ElevatedButton(
          onPressed: isUsedUp ? null : () => onNumberInput(number),
          style: ElevatedButton.styleFrom(
            backgroundColor: isUsedUp ? Colors.grey[300] : null,
          ),
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isUsedUp ? Colors.grey : Colors.black,
            ),
          ),
        );
      }),
    );
  }
}