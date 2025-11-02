import 'package:flutter/material.dart';

/// 🔢 StageNumberPad
/// 숫자 입력 전용 패드 (항상 한 줄에 9개 고정)
class StageNumberPad extends StatelessWidget {
  final void Function(int)? onNumberInput;
  final int maxNumber;

  const StageNumberPad({
    super.key,
    this.onNumberInput,
    this.maxNumber = 9,
  });

  @override
  Widget build(BuildContext context) {
    final numbers = List.generate(maxNumber, (i) => i + 1);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: GridView.count(
        crossAxisCount: 9, // ✅ 항상 한 줄에 9칸
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: const EdgeInsets.all(4),
        children: numbers.map((num) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.black87,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () => onNumberInput?.call(num),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                num.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}