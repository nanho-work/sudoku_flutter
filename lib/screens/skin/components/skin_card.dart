import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';

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

  bool _isJson(String url) => url.toLowerCase().contains('.json');

  @override
  Widget build(BuildContext context) {
    final bgUrl = item.bgUrl ?? '';
    final charUrl = item.imageUrl;

    final bgLocal = skinCtrl.bgLocalCache[item.id];
    final charLocal = skinCtrl.charLocalCache[item.id];

    final bgIsJson = _isJson(bgUrl);
    final charIsJson = _isJson(charUrl);

    final bgComp = skinCtrl.getComposition("${item.id}_bg");
    final charComp = skinCtrl.getComposition("${item.id}_char");

    Widget buildBg() {
      if (bgIsJson) {
        if (bgComp != null) {
          return Lottie(
            composition: bgComp,
            fit: BoxFit.fill,
            repeat: true,
          );
        }
        if (bgLocal != null && File(bgLocal).existsSync()) {
          return Lottie.file(
            File(bgLocal),
            fit: BoxFit.fill,
          );
        }
        return Lottie.network(
          bgUrl,
          fit: BoxFit.fill,
        );
      } else {
        if (bgLocal != null && File(bgLocal).existsSync()) {
          return Image.file(File(bgLocal), fit: BoxFit.fill);
        }
        if (bgUrl.isNotEmpty) {
          return CachedNetworkImage(imageUrl: bgUrl, fit: BoxFit.fill);
        }
        return const SizedBox.shrink();
      }
    }

    Widget buildChar() {
      if (charIsJson) {
        if (charComp != null) {
          return Lottie(
            composition: charComp,
            fit: BoxFit.contain,
            repeat: true,
          );
        }
        if (charLocal != null && File(charLocal).existsSync()) {
          return Lottie.file(
            File(charLocal),
            fit: BoxFit.contain,
          );
        }
        return Lottie.network(
          charUrl,
          fit: BoxFit.contain,
        );
      } else {
        if (charLocal != null && File(charLocal).existsSync()) {
          return Image.file(File(charLocal), fit: BoxFit.contain);
        }
        return CachedNetworkImage(imageUrl: charUrl, fit: BoxFit.contain);
      }
    }

    return GestureDetector(
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
              Positioned.fill(child: buildBg()),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(height: 80, child: buildChar()),
              ),
              if (!unlocked)
                Positioned.fill(
                  child: Container(color: Colors.black38),
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
  }
}