import 'package:flutter/material.dart';

class RankingHeader extends StatelessWidget {
  final String currentDifficulty;
  final ValueChanged<String> onDifficultyChanged;

  const RankingHeader({
    super.key,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final difficulties = {
      'easy': '쉬움',
      'normal': '보통',
      'hard': '어려움',
      'extreme': '지옥',
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: difficulties.entries.map((entry) {
          final isSelected = entry.key == currentDifficulty;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onDifficultyChanged(entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD6B97B) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B6F3D) : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}