import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/audio_controller.dart'; // ✅ BGM 제어용 (Provider에서 받은 인스턴스 사용)

class AdRewardService {
  static RewardedAd? _rewardedAd;

  /// ✅ 광고 로드
  static Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: 'ca-app-pub-5773331970563455/1279915976', // ⚠️ 실제 ID로 교체
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          // fullScreenContentCallback은 showRewardedAd 호출 시 설정하도록 변경됨
          _rewardedAd = ad;
          debugPrint("✅ Rewarded Ad Loaded");
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          debugPrint("❌ Rewarded Ad Failed: $error");
        },
      ),
    );
  }

  /// ✅ 광고 표시
  static void showRewardedAd({
    required Function onReward,
    Function? onFail,
    required AudioController audioController,
  }) {
    if (_rewardedAd == null) {
      debugPrint("⚠️ No RewardedAd loaded");
      if (onFail != null) onFail();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        audioController.pauseAll(); // 🔇 광고 시작 시 BGM 정지 (Provider 인스턴스 사용)
      },
      onAdDismissedFullScreenContent: (ad) {
        audioController.resumeAll(); // 🔊 광고 끝나면 BGM 복귀 (Provider 인스턴스 사용)
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onReward(); // ✅ 보상 실행 (ex. controller.restoreHearts())
      },
    );

    _rewardedAd = null;
    loadRewardedAd(); // 광고 재로딩
  }
}