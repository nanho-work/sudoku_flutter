// lib/widgets/app_header.dart (수정된 코드)

import 'package:flutter/material.dart';
// 💡 에러 해결: AdSize 인식을 위해 import 추가
import 'package:google_mobile_ads/google_mobile_ads.dart'; 
import '../services/ad_banner_service.dart';

/// 앱의 최상단 헤더 (배너 광고 포함)
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  // 💡 에러 해결: const 제거 및 toDouble() 추가
  @override
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icons/koofy1.png', height: 48),
              const SizedBox(width: 8),
              const Text(
                "모두의 즐거움! Koofy",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        
        // 💡 에러 해결: AdSize가 이제 정의되어 인식됨
        if (_isBannerReady)
          AdBannerService.bannerWidget()
        else
          Container(
            // 💡 에러 해결: AdSize가 이제 정의되어 인식됨
            height: AdSize.banner.height.toDouble(), 
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: _isBannerReady ? null : const Text('광고 로드 중...', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}