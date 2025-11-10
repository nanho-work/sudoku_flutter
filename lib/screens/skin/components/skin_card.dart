import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';
import '../../../services/skin_local_cache.dart';

class SkinCard extends StatelessWidget {
  final SkinController skinCtrl;
  final SkinItem item;
  final bool unlocked;
  final bool isSelected;
  final VoidCallback? onTap;

  const SkinCard({
    super.key,
    required this.skinCtrl,
    required this.item,
    required this.unlocked,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('🧩 [SKIN CARD START] ${item.id} | unlocked=$unlocked | selected=$isSelected');
    final charUrl = item.imageUrl;
    final bgUrl = item.bgUrl ?? '';

    final isJsonBg = bgUrl.toLowerCase().contains('.json');
    final isJsonChar = charUrl.toLowerCase().contains('.json');

    Widget buildBgWidget(String? localPath) {
      if (isJsonBg) {
        if (localPath != null && File(localPath).existsSync()) {
          debugPrint('[BG] Using local JSON bg asset. bgUrl: $bgUrl, localPath: $localPath');
          return Lottie.file(File(localPath), fit: BoxFit.fill, repeat: true);
        } else if (bgUrl.isNotEmpty) {
          debugPrint('[BG] Using network JSON bg asset. bgUrl: $bgUrl, localPath: $localPath');
          return Lottie.network(bgUrl, fit: BoxFit.fill, repeat: true);
        } else {
          debugPrint('[BG] No bg asset found. bgUrl: $bgUrl, localPath: $localPath');
          return const SizedBox.shrink();
        }
      } else {
        if (localPath != null && File(localPath).existsSync()) {
          debugPrint('[BG] Using local image bg asset. bgUrl: $bgUrl, localPath: $localPath');
          return Image.file(File(localPath), fit: BoxFit.fill);
        } else if (bgUrl.isNotEmpty) {
          debugPrint('[BG] Using network image bg asset. bgUrl: $bgUrl, localPath: $localPath');
          return CachedNetworkImage(imageUrl: bgUrl, fit: BoxFit.fill);
        } else {
          debugPrint('[BG] No bg asset found. bgUrl: $bgUrl, localPath: $localPath');
          return const SizedBox.shrink();
        }
      }
    }

    Widget buildCharWidget(String? localPath) {
      if (isJsonChar) {
        if (localPath != null && File(localPath).existsSync()) {
          debugPrint('[CHAR] Using local JSON char asset. charUrl: $charUrl, localPath: $localPath');
          return Lottie.file(File(localPath), fit: BoxFit.fill, repeat: true);
        } else {
          debugPrint('[CHAR] Using network JSON char asset. charUrl: $charUrl, localPath: $localPath');
          return Lottie.network(charUrl, fit: BoxFit.fill, repeat: true);
        }
      } else {
        if (localPath != null && File(localPath).existsSync()) {
          debugPrint('[CHAR] Using local image char asset. charUrl: $charUrl, localPath: $localPath');
          return Image.file(File(localPath), fit: BoxFit.fill);
        } else {
          debugPrint('[CHAR] Using network image char asset. charUrl: $charUrl, localPath: $localPath');
          return CachedNetworkImage(imageUrl: charUrl, fit: BoxFit.fill);
        }
      }
    }

    return FutureBuilder<List<String?>>(
      future: Future.wait([
        SkinLocalCache.getLocalPath(bgUrl),
        SkinLocalCache.getLocalPath(charUrl),
      ]),
      builder: (context, snapshot) {
        debugPrint('──────────────────────────────');
        debugPrint('🕒 [SKIN CARD FUTURE BUILDER] Build called. Has data: ${snapshot.hasData}');
        final bgLocalPath = snapshot.hasData ? snapshot.data![0] : null;
        final charLocalPath = snapshot.hasData ? snapshot.data![1] : null;
        debugPrint('🗂️ [SKIN CARD PATHS] bgLocalPath: $bgLocalPath, charLocalPath: $charLocalPath');
        debugPrint('──────────────────────────────');

        debugPrint('✅ [SKIN CARD READY] bgLocalPath=$bgLocalPath | charLocalPath=$charLocalPath');

        final widget = GestureDetector(
          onTap: onTap,
          child: Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: buildBgWidget(bgLocalPath)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(height: 80, child: buildCharWidget(charLocalPath)),
                  ),
                  if (!unlocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black38,
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '착용중',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (!unlocked && item.unlockCost > 0)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item.unlockCost}💰',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        debugPrint('🏁 [SKIN CARD END] ${item.id}');
        return widget;
      },
    );
  }
}