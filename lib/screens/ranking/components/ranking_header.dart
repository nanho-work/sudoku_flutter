import 'package:flutter/material.dart';
import '../../../services/ranking_service.dart';

class RankingHeader extends StatelessWidget {
  final String currentDifficulty;
  final String currentWeek;
  final ValueChanged<String> onDifficultyChanged;
  final ValueChanged<String> onWeekChanged;

  const RankingHeader({
    super.key,
    required this.currentDifficulty,
    required this.currentWeek,
    required this.onDifficultyChanged,
    required this.onWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final difficulties = ['easy', 'normal', 'hard', 'extreme'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: const Color(0xFFECE0C6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 주차 표시
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () async {
                  final weeks = await RankingService.getAvailableWeeks(difficulty: currentDifficulty);
                  final idx = weeks.indexOf(currentWeek);
                  if (idx < weeks.length - 1) onWeekChanged(weeks[idx + 1]);
                },
              ),
              Text(
                currentWeek,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () async {
                  final weeks = await RankingService.getAvailableWeeks(difficulty: currentDifficulty);
                  final idx = weeks.indexOf(currentWeek);
                  if (idx > 0) onWeekChanged(weeks[idx - 1]);
                },
              ),
            ],
          ),

          // 난이도 선택
          DropdownButton<String>(
            value: currentDifficulty,
            items: difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: (v) {
              if (v != null) onDifficultyChanged(v);
            },
          ),
        ],
      ),
    );
  }
}