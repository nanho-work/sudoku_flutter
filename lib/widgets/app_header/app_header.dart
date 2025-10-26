import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import '../../services/ad_banner_service.dart';
import 'profile_section.dart';
import 'gold_display.dart';
import 'setting_dialog.dart';

/// 앱의 최상단 헤더 (배너 광고 + 상단 메뉴)
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + AdSize.banner.height.toDouble());
}

class _AppHeaderState extends State<AppHeader> {
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    AdBannerService.loadMainBanner(
      onLoaded: () => setState(() => _isBannerReady = true),
      onFailed: (error) {
        debugPrint("Main banner failed: $error");
        setState(() => _isBannerReady = false);
      },
    );
  }

  @override
  void dispose() {
    AdBannerService.disposeMainBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkAdPlaceholderColor = Color(0xFF1E272E);

    return SafeArea(
      top: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1행: 광고 (기존 그대로)
          _isBannerReady
              ? AdBannerService.mainBannerWidget()
              : Container(
                  height: AdSize.banner.height.toDouble(),
                  color: darkAdPlaceholderColor,
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context)!.header_loading,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
          const SizedBox(height: 16),

          // 2행: 프로필, 골드, 빈칸, 설정
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: ProfileSection()),
                const Expanded(child: GoldDisplay()),
                const Expanded(child: SizedBox()), // 빈 섹션
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.black, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const SettingsDialog(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}