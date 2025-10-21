import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 배너 광고 서비스 (메인/게임 구분)
class AdBannerService {
  static BannerAd? _mainBannerAd;
  static BannerAd? _gameBannerAd;

  /// ------------------------------
  /// 🏠 메인 레이아웃용 배너 로드
  /// ------------------------------
  static void loadMainBanner({
    required VoidCallback onLoaded,
    required Function(LoadAdError) onFailed,
  }) {
    _mainBannerAd?.dispose(); // 혹시 남아있다면 정리
    _mainBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/8722125095', // ✅ 실제 메인 배너 ID
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

  /// ------------------------------
  /// 🎮 게임 플레이용 배너 로드
  /// ------------------------------
  static void loadGameBanner({
    required VoidCallback onLoaded,
    required Function(LoadAdError) onFailed,
  }) {
    _gameBannerAd?.dispose();
    _gameBannerAd = BannerAd(
      adUnitId: 'ca-app-pub-5773331970563455/8722125095', // ✅ 게임 화면용 ID
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

  /// ------------------------------
  /// 🧩 배너 위젯
  /// ------------------------------
  static Widget mainBannerWidget() {
    if (_mainBannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _mainBannerAd!.size.width.toDouble(),
      height: _mainBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _mainBannerAd!),
    );
  }

  static Widget gameBannerWidget() {
    if (_gameBannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _gameBannerAd!.size.width.toDouble(),
      height: _gameBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _gameBannerAd!),
    );
  }

  /// ------------------------------
  /// 🧹 리소스 정리
  /// ------------------------------
  static void disposeMainBanner() {
    _mainBannerAd?.dispose();
    _mainBannerAd = null;
  }

  static void disposeGameBanner() {
    _gameBannerAd?.dispose();
    _gameBannerAd = null;
  }
}