import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 배너 광고 서비스 (공용)
class AdBannerService {
  static BannerAd? _bannerAd;

  /// 배너 광고 로드
  static void loadBannerAd({
    required VoidCallback onLoaded,
    required Function(LoadAdError) onFailed,
  }) {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/8722125095', // ✅ 실제 광고 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed(error);
        },
      ),
    )..load();
  }

  /// 배너 위젯 반환
  static Widget bannerWidget() {
    if (_bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// 리소스 정리
  static void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }
}