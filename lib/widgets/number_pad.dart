import 'package:flutter/material.dart';

/// 숫자 입력 패드 (1~9 버튼)
class NumberPad extends StatelessWidget {
  final Function(int) onNumberInput;

  const NumberPad({super.key, required this.onNumberInput});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(9, (index) {
        int number = index + 1;
        return ElevatedButton(
          onPressed: () => onNumberInput(number),
          child: Text(number.toString()),
        );
      }),
    );
  }
}