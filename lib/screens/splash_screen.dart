import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/audio_controller.dart';
import '../controllers/skin_controller.dart';
import '../services/stage_service.dart';
import '../services/skin_local_cache.dart';
import 'main_layout.dart';
import 'login/login_screen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AudioController _audio;
  late final AnimationController _textFadeController;
  double _progress = 0;
  String _statusText = '리소스를 준비하는 중입니다...';
  bool _updateRequired = false;

  @override
  void initState() {
    super.initState();
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.3,
      upperBound: 1.0,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _initSplash());
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.png') ||
        lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.webp');
  }

  Future<void> _initSplash() async {
    try {
      _audio = context.read<AudioController>();
      final skinController = context.read<SkinController>();
      setState(() {
        _statusText = '리소스를 불러오는 중입니다...';
        _progress = 0.1;
      });

      // [1] 모든 리소스 다운로드&프리캐시, composition 파싱까지 await
      await _preloadAllAssets(skinController, context);

      setState(() {
        _progress = 0.9;
        _statusText = '최적화 완료...';
      });

      await _checkForUpdate();
      if (_updateRequired || !mounted) return;

      setState(() {
        _progress = 1.0;
        _statusText = '준비 완료!';
      });

      await Future.delayed(const Duration(milliseconds: 300)); // 부드러운 UX
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isLoggedIn ? const MainLayout() : const LoginScreen(),
        ),
      );
    } catch (e, st) {
    }
  }

  Future<void> _preloadAllAssets(SkinController skinController, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    await skinController.initSkins(userId);
    await skinController.loadAll(userId);
    await skinController.ensureLocalPreload();

    await _precacheAllSkins(context, skinController);
    await _precacheStageThumbnails(context);

    final skinState = skinController.state;
    if (skinState?.selectedBgId != null && skinState!.selectedBgId!.isNotEmpty) {
      final localBgPath = await SkinLocalCache.getLocalPath(skinState.selectedBgId!);
      if (localBgPath != null && localBgPath.contains('.json')) {
        // ✅ Lottie composition 파싱 후 SkinController에 캐싱!
        final bytes = await File(localBgPath).readAsBytes();
        final composition = await LottieComposition.fromBytes(bytes);
        skinController.cacheComposition(skinState.selectedBgId!, composition);
      }
    }
  }

  Future<void> _precacheAllSkins(BuildContext context, SkinController controller) async {
    for (final skin in controller.catalog) {
      if (skin.imageUrl.isNotEmpty && _isImageUrl(skin.imageUrl)) {
        if (!mounted) return;
        await precacheImage(
          CachedNetworkImageProvider(skin.imageUrl),
          context,
        );
      }
      if (skin.imageUrl.isNotEmpty) {
        await SkinLocalCache.downloadToDocuments(skin.imageUrl);
      }
      if (skin.bgUrl != null && skin.bgUrl!.isNotEmpty) {
        final bg = skin.bgUrl!;
        final isLottie = bg.toLowerCase().contains('.json');
        if (!isLottie && _isImageUrl(bg)) {
          if (!mounted) return;
          await precacheImage(
            CachedNetworkImageProvider(bg),
            context,
          );
        }
        await SkinLocalCache.downloadToDocuments(bg);
      }
    }
  }

  Future<void> _precacheStageThumbnails(BuildContext context) async {
    final stages = await StageService().loadStages();
    for (final stage in stages) {
      final thumb = stage.thumbnail;
      if (thumb != null && thumb.isNotEmpty) {
        if (thumb.startsWith('http')) {
          if (!mounted) return;
          await precacheImage(CachedNetworkImageProvider(thumb), context);
          await SkinLocalCache.downloadToDocuments(thumb);
        } else {
          if (!mounted) return;
          await precacheImage(AssetImage(thumb), context);
        }
      }
    }
  }

  Future<void> _checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: Duration.zero,
      ),
    );
    await remoteConfig.fetchAndActivate();

    final latestVersion = remoteConfig.getString('latest_version');
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(info.buildNumber) ?? 0;
    final latestBuild = int.tryParse(latestVersion.split('+').last) ?? 0;

    if (currentBuild < latestBuild) {
      _updateRequired = true;
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('업데이트 필요'),
          content: const Text('새로운 버전이 출시되었습니다.\n업데이트 후 이용해주세요.'),
          actions: [
            TextButton(
              onPressed: () async {
                final url = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.koofy.sudoku');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('업데이트하러 가기'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FadeTransition(
              opacity: _textFadeController,
              child: Text(
                _statusText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 240,
              child: LinearProgressIndicator(
                value: _progress,
                valueColor: const AlwaysStoppedAnimation(Colors.lightBlueAccent),
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toInt()}%', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
