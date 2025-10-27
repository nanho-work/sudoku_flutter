import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_controller.dart';
import '../controllers/theme_controller.dart';
import 'home/home_screen.dart';
import 'mission_screen.dart';
import 'info_screen.dart';
import 'ranking/ranking_screen.dart';
import 'guide_screen.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header/app_header.dart'; // AppHeader
import '../services/ad_banner_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  late AudioController audio;
  int _currentIndex = 0;
  bool _isBannerReady = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    MissionScreen(),
    GuideScreen(),
    RankingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdBannerService.loadMainBanner(
      onLoaded: () => setState(() => _isBannerReady = true),
      onFailed: (error) {
        debugPrint("Main banner failed: $error");
        setState(() => _isBannerReady = false);
      },
    );
    audio = context.read<AudioController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audio.startMainBgm();
      debugPrint("🎵 MainLayout initState: startMainBgm() called (delayed)");
    });
  }

  @override
  void dispose() {
    AdBannerService.disposeMainBanner();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("📱 Lifecycle changed: $state");
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audio.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      audio.resumeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;

    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isBannerReady
                ? AdBannerService.mainBannerWidget()
                : Container(
                    height: AdSize.banner.height.toDouble(),
                    color: const Color(0xFF1E272E),
                  ),
            SizedBox(height : 6),
            const AppHeader(),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
      backgroundColor: colors.background,
    );
  }
}