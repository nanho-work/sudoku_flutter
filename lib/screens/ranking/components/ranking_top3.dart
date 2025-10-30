import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          return Column(
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: record.characterImageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error, size: 24),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
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