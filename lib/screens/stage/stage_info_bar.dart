import 'package:flutter/material.dart';
import '../../models/stage_model.dart';

/// 상단 스테이지 정보바 (이름 + 난이도 + 경과시간)
class StageInfoBar extends StatelessWidget {
  final StageModel stage;
  final Duration elapsed;

  const StageInfoBar({
    super.key,
    required this.stage,
    required this.elapsed,
  });

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${stage.name} (${stage.difficulty})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '⏱ ${_formatTime(elapsed)}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}