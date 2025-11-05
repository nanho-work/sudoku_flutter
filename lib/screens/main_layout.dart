import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../controllers/audio_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/skin_controller.dart';
import '../models/user_model.dart';
import 'home/home_screen.dart';
import 'mission_screen.dart';
import 'guide_screen.dart';
import 'ranking/ranking_screen.dart';
import 'stage/stage_select_screen.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_header/app_header.dart';
import '../services/ad_banner_service.dart';
import '../providers/stage_progress_provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  AudioController? audio;
  int _currentIndex = 0;
  bool _isBannerReady = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    MissionScreen(),
    StageSelectScreen(),
    GuideScreen(),
    RankingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      await context.read<SkinController>().initSkins(userId);

      audio = context.read<AudioController>();
      if (mounted) {
        audio?.startMainBgm();
      }
    });

    AdBannerService.loadMainBanner(
      onLoaded: () => setState(() => _isBannerReady = true),
      onFailed: (_) => setState(() => _isBannerReady = false),
    );
  }

  @override
  void dispose() {
    AdBannerService.disposeMainBanner();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTap(int index) => setState(() => _currentIndex = index);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audio?.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      audio?.resumeAll();
    }
  }

  bool _isValidImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final skinController = context.watch<SkinController>();
    final userModel = context.watch<UserModel?>();
    final selectedBg = skinController.selectedBg?.imageUrl;

    if (selectedBg != null && _isValidImageUrl(selectedBg)) {
      precacheImage(CachedNetworkImageProvider(selectedBg), context)
          .catchError((_) => debugPrint('⚠️ Background precache failed.'));
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          if (selectedBg != null)
            Positioned.fill(
              child: selectedBg.contains('.json')
                  ? Lottie.network(
                      selectedBg,
                      fit: BoxFit.cover,
                      frameRate: FrameRate.max,
                      errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                    )
                  : CachedNetworkImage(
                      imageUrl: selectedBg,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.black12),
                      errorWidget: (_, __, ___) => Container(color: Colors.black12),
                    ),
            ),
          SafeArea(
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
                const SizedBox(height: 6),
                if (userModel != null) const AppHeader(),
                Expanded(child: _screens[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}