import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/audio_controller.dart';
import '../controllers/skin_controller.dart';
import 'main_layout.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AudioController _audio;
  bool _updateRequired = false;

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  Future<void> _initSplash() async {
    _audio = context.read<AudioController>();
    _audio.playSfx('start_bg.mp3');

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    final skinController = context.read<SkinController>();
    await _precacheAllSkins(context, skinController);

    await _checkForUpdate();
    if (_updateRequired) return;

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  Future<void> _precacheAllSkins(BuildContext context, SkinController controller) async {
    try {
      for (final skin in controller.catalog) {
        if (skin.imageUrl.isNotEmpty) {
          await precacheImage(CachedNetworkImageProvider(skin.imageUrl), context);
        }
        if (skin.bgUrl != null && skin.bgUrl!.isNotEmpty) {
          await precacheImage(CachedNetworkImageProvider(skin.bgUrl!), context);
        }
      }
      debugPrint('✅ 모든 캐릭터 이미지 프리캐시 완료');
    } catch (e) {
      debugPrint('⚠️ 캐릭터 프리캐시 중 오류: $e');
    }
  }

  Future<void> _checkForUpdate() async {
    try {
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
    } catch (e, st) {
      debugPrint('⚠️ Remote Config 확인 실패: $e\n$st');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}