import 'package:flutter/material.dart';
// 💡 에러 해결: AdSize 인식을 위해 import 추가
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import '../services/ad_banner_service.dart';

/// 앱의 최상단 헤더 (배너 광고 포함) - 다크 테마 적용
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  // 배너 높이를 포함하여 AppBar의 선호 사이즈를 계산
  Size get preferredSize => Size.fromHeight(kToolbarHeight + AdSize.banner.height.toDouble());
}

class _AppHeaderState extends State<AppHeader> {
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    AdBannerService.loadBannerAd(
      onLoaded: () {
        setState(() {
          _isBannerReady = true;
        });
      },
      onFailed: (error) {
        debugPrint("Ad loading failed: $error");
        setState(() {
          _isBannerReady = false;
        });
      },
    );
  }

  @override
  void dispose() {
    AdBannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 다크 모드에 사용할 색상 정의 (HomeScreen의 Surface/Background와 통일)
    const Color darkAppBarColor = Color(0xFF263238); 
    const Color darkAdPlaceholderColor = Color(0xFF1E272E); 
    // const Color accentColor = Colors.lightBlueAccent; // 로고 복원으로 인해 임시 미사용

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          // 💡 UI 개선: 다크 배경색 적용 및 깊이감 추가
          backgroundColor: darkAppBarColor,
          elevation: 8, 
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 💡 로고 에셋 복원: 원래의 Koofy 로고 이미지를 사용하고 크기를 지정합니다.
              Image.asset('assets/icons/koofy1.png', height: 48), 
              const SizedBox(width: 8),
              const Text(
                "모두의 즐거움! Koofy",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w800,
                  color: Colors.white, // 흰색 텍스트
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        
        // --- 배너 광고 섹션 ---
        if (_isBannerReady)
          AdBannerService.bannerWidget()
        else
          // 💡 UI 개선: 다크 테마에 맞는 광고 로드 중 컨테이너
          Container(
            height: AdSize.banner.height.toDouble(), 
            color: darkAdPlaceholderColor, // 어두운 배경색 적용
            alignment: Alignment.center,
            child: const Text(
              '광고 로드 중...', 
              style: TextStyle(fontSize: 12, color: Colors.grey), // 회색 텍스트
            ),
          ),
      ],
    );
  }
}
