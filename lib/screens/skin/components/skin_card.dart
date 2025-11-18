import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';

/// 스킨 카드
/// - 스플래쉬에서 미리 다운로드한 로컬 캐시와
///   SkinController의 sync getter(getLocalImagePathSync / getLocalBgPathSync),
///   그리고 URL 기반 Composition 캐시(getComposition)를 사용하는 버전
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
    final String bgUrl = item.bgUrl ?? '';
    final String charUrl = item.imageUrl;

    // ✅ 컨트롤러의 동기 로컬 경로 조회 사용 (스플래쉬에서 미리 채워둔 맵)
    final String? bgLocal = skinCtrl.getLocalBgPathSync(bgUrl);
    final String? charLocal = skinCtrl.getLocalImagePathSync(charUrl);

    final bool bgIsJson = _isJson(bgUrl);
    final bool charIsJson = _isJson(charUrl);

    // ✅ Composition 키는 URL 자체를 사용 (Splash / Controller와 동일 규칙)
    final LottieComposition? bgComp = bgUrl.isNotEmpty
        ? skinCtrl.getComposition(bgUrl)
        : null;
    final LottieComposition? charComp = charUrl.isNotEmpty
        ? skinCtrl.getComposition(charUrl)
        : null;

    Widget buildBg() {
      if (bgUrl.isEmpty) {
        return const SizedBox.shrink();
      }

      // Lottie(JSON) 배경
      if (bgIsJson) {
        // 1순위: 메모리 상 Composition 캐시
        if (bgComp != null) {
          return Lottie(
            composition: bgComp,
            fit: BoxFit.fill,
            repeat: true,
          );
        }

        // 2순위: 로컬 파일(JSON) 존재 시
        if (bgLocal != null && File(bgLocal).existsSync()) {
          return Lottie.file(
            File(bgLocal),
            fit: BoxFit.fill,
          );
        }

        // 3순위: 네트워크 JSON
        return Lottie.network(
          bgUrl,
          fit: BoxFit.fill,
        );
      }

      // 이미지 배경 (png/jpg 등)
      if (bgLocal != null && File(bgLocal).existsSync()) {
        return Image.file(
          File(bgLocal),
          fit: BoxFit.fill,
        );
      }

      return CachedNetworkImage(
        imageUrl: bgUrl,
        fit: BoxFit.fill,
      );
    }

    Widget buildChar() {
      if (charUrl.isEmpty) {
        return const SizedBox.shrink();
      }

      // Lottie(JSON) 캐릭터
      if (charIsJson) {
        // 1순위: 메모리 Composition
        if (charComp != null) {
          return Lottie(
            composition: charComp,
            fit: BoxFit.contain,
            repeat: true,
          );
        }

        // 2순위: 로컬 JSON 파일 존재 시
        if (charLocal != null && File(charLocal).existsSync()) {
          return Lottie.file(
            File(charLocal),
            fit: BoxFit.contain,
          );
        }

        // 3순위: 네트워크 JSON
        return Lottie.network(
          charUrl,
          fit: BoxFit.contain,
        );
      }

      // 이미지 캐릭터
      if (charLocal != null && File(charLocal).existsSync()) {
        return Image.file(
          File(charLocal),
          fit: BoxFit.contain,
        );
      }

      return CachedNetworkImage(
        imageUrl: charUrl,
        fit: BoxFit.contain,
      );
    }

    return GestureDetector
      (onTap: onTap,
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
              // 배경
              Positioned.fill(child: buildBg()),

              // 캐릭터 (아래쪽 정렬)
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 80,
                  child: buildChar(),
                ),
              ),

              // 잠금 오버레이
              if (!unlocked)
                Positioned.fill(
                  child: Container(color: Colors.black38),
                ),

              // 선택 배지
              if (isSelected)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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

              // 미보유 + 가격 표시
              if (!unlocked && item.unlockCost > 0)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
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