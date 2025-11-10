import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../../../models/ranking_model.dart';
import '../../../services/skin_local_cache.dart';

class RankingTop3 extends StatelessWidget {
  final List<RankingRecord> top3;
  const RankingTop3({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    debugPrint("🔹 Building RankingTop3 with ${top3.length} records");

    Widget _buildCharacterWidget(String url) {
      // Use FutureBuilder to handle async local path lookup
      return FutureBuilder<String?>(
        future: SkinLocalCache.getLocalPath(url),
        builder: (context, snapshot) {
          final localPath = snapshot.data ?? '';
          if (localPath.isNotEmpty && File(localPath).existsSync()) {
            if (localPath.toLowerCase().contains('.json')) {
              debugPrint("🟢 Using local Lottie file from cache: $localPath");
              return Lottie.file(
                File(localPath),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              );
            } else {
              debugPrint("🟢 Using local image file from cache: $localPath");
              return Image.file(
                File(localPath),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              );
            }
          } else {
            if (url.toLowerCase().contains('.json')) {
              debugPrint("🌐 Using network Lottie: $url");
              return Lottie.network(
                url,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              );
            } else {
              debugPrint("🌐 Using network image: $url");
              return CachedNetworkImage(
                imageUrl: url,
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
              );
            }
          }
        },
      );
    }

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
                    child: _buildCharacterWidget(record.characterImageUrl),
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
              Container(
                color: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(record.nickname, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Container(
                color: Colors.white.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text('${record.clearTime.toStringAsFixed(2)}초', style: const TextStyle(fontSize: 12)),
              ),
            ],
          );
        }),
      ),
    );
  }
}