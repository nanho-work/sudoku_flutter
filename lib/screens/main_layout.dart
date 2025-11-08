import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import '../services/skin_local_cache.dart';
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
    debugPrint('MainLayout initState started');
    WidgetsBinding.instance.addObserver(this);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    debugPrint('MainLayout initState userId: $userId');

    context.read<SkinController>().initSkins(userId).then((_) {
      final skinController = context.read<SkinController>();
      debugPrint('SkinController initSkins completed');
      debugPrint('SkinController catalog length: ${skinController.catalog.length}');
      if (skinController.catalog.isNotEmpty) {
        debugPrint('First catalog item id: ${skinController.catalog.first.id}');
      }
      debugPrint('SkinController state: ${skinController.state}');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      audio = context.read<AudioController>();
      if (mounted) {
        audio?.startMainBgm();
      }
    });

    AdBannerService.loadMainBanner(
      onLoaded: () => setState(() {
        _isBannerReady = true;
        debugPrint('AdBannerService: Main banner loaded and ready');
      }),
      onFailed: (_) => setState(() {
        _isBannerReady = false;
        debugPrint('AdBannerService: Main banner failed to load');
      }),
    );
  }

  @override
  void dispose() {
    debugPrint('MainLayout dispose called: disposing main banner and removing observer');
    AdBannerService.disposeMainBanner();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTap(int index) {
    debugPrint('MainLayout _onTap called: changing tab from $_currentIndex to $index');
    setState(() => _currentIndex = index);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('MainLayout didChangeAppLifecycleState: current state is $state');
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audio?.pauseAll();
      debugPrint('AudioController: paused all audio due to app lifecycle state $state');
    } else if (state == AppLifecycleState.resumed) {
      audio?.resumeAll();
      debugPrint('AudioController: resumed all audio due to app lifecycle state resumed');
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
    debugPrint('🔍 MainLayout build() 시작');
    try {
      final colors = context.watch<ThemeController>().colors;
      final skinController = context.watch<SkinController>();
      final userModel = context.watch<UserModel?>();
      final selectedBg = skinController.selectedBg?.imageUrl;

      debugPrint('MainLayout build _currentIndex: $_currentIndex, userModel is null: ${userModel == null}, selectedCharId: ${skinController.state?.selectedCharId}, selectedBg: $selectedBg');

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
                child: FutureBuilder<String?>(
                  future: SkinLocalCache.getLocalPath(selectedBg),
                  builder: (context, snapshot) {
                    debugPrint('FutureBuilder connectionState: ${snapshot.connectionState}');
                    final cachePath = snapshot.data;
                    final fileExists = cachePath != null && File(cachePath).existsSync();
                    debugPrint('FutureBuilder: selectedBg: $selectedBg, cachePath: $cachePath, file exists: $fileExists');
                    if (cachePath != null && fileExists) {
                      if (selectedBg.contains('.json')) {
                        debugPrint('Rendering Lottie.file from cachePath');
                        return Lottie.file(
                          File(cachePath),
                          fit: BoxFit.fill,
                          frameRate: FrameRate.max,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                        );
                      } else {
                        debugPrint('Rendering Image.file from cachePath');
                        return Image.file(
                          File(cachePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                        );
                      }
                    } else {
                      if (selectedBg.contains('.json')) {
                        debugPrint('Rendering Lottie.network from url');
                        return Lottie.network(
                          selectedBg,
                          fit: BoxFit.fill,
                          frameRate: FrameRate.max,
                          errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                        );
                      } else {
                        debugPrint('Rendering CachedNetworkImage from url');
                        return CachedNetworkImage(
                          imageUrl: selectedBg,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.black12),
                          errorWidget: (_, __, ___) => Container(color: Colors.black12),
                        );
                      }
                    }
                  },
                ),
              ),
            SafeArea(
              top: true,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (_) {
                      debugPrint(_isBannerReady
                          ? 'Rendering AdBannerService.mainBannerWidget'
                          : 'Rendering placeholder container for banner');
                      return const SizedBox.shrink();
                    },
                  ),
                  if (_isBannerReady) ...[
                    AdBannerService.mainBannerWidget(),
                  ] else ...[
                    Container(
                      height: AdSize.banner.height.toDouble(),
                      color: const Color(0xFF1E272E),
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (userModel != null) ...[
                    Builder(
                      builder: (_) {
                        debugPrint('Rendering AppHeader because userModel is not null');
                        return const AppHeader();
                      },
                    ),
                  ],
                  Builder(
                    builder: (_) {
                      debugPrint('Rendering screen widget at index $_currentIndex');
                      return _screens[_currentIndex];
                    },
                  ),
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
    } catch (e, stack) {
      debugPrint('Error in MainLayout build: $e\n$stack');
      rethrow;
    }
  }
}