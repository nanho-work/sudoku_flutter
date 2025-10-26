import 'package:flutter/material.dart';
import '../../../models/ranking_model.dart';

class RankingTop3 extends StatelessWidget {
  final List<RankingRecord> top3;
  const RankingTop3({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) {
          if (i >= top3.length) return const SizedBox(width: 80);
          final record = top3[i];
          final rank = i + 1;
          final color = [Colors.amber, Colors.grey, Colors.brown][i];
          return Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(record.nickname, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${record.clearTime.toStringAsFixed(2)}초', style: const TextStyle(fontSize: 12)),
            ],
          );
        }),
      ),
    );
  }
}