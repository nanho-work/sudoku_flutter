import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/audio_controller.dart';
import '../controllers/skin_controller.dart';
import '../services/stage_service.dart';
import '../services/skin_local_cache.dart';
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
  double _progress = 0;

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
    await _precacheStageThumbnails(context);
    await _checkForUpdate();
    if (_updateRequired) return;

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
  }

  Future<void> _precacheAllSkins(
      BuildContext context, SkinController controller) async {
    try {
      for (final skin in controller.catalog) {
        if (skin.imageUrl.isNotEmpty) {
          await precacheImage(CachedNetworkImageProvider(skin.imageUrl), context);
          await SkinLocalCache.downloadToDocuments(skin.imageUrl);
        }
        if (skin.bgUrl != null && skin.bgUrl!.isNotEmpty) {
          await precacheImage(CachedNetworkImageProvider(skin.bgUrl!), context);
          await SkinLocalCache.downloadToDocuments(skin.bgUrl!);
        }
      }
      debugPrint('✅ 모든 캐릭터 이미지 프리캐시 + 로컬 캐시 완료');
    } catch (e) {
      debugPrint('⚠️ 캐릭터 프리캐시 중 오류: $e');
    }
  }

  Future<void> _precacheStageThumbnails(BuildContext context) async {
    try {
      final stages = await StageService().loadStages();
      for (final stage in stages) {
        final thumb = stage.thumbnail;
        if (thumb != null && thumb.isNotEmpty) {
          if (thumb.startsWith('http')) {
            await precacheImage(CachedNetworkImageProvider(thumb), context);
            await SkinLocalCache.downloadToDocuments(thumb);
          } else {
            await precacheImage(AssetImage(thumb), context);
          }
        }
      }
      debugPrint('✅ 모든 스테이지 썸네일 프리캐시 + 캐시 완료');
    } catch (e) {
      debugPrint('⚠️ 스테이지 썸네일 프리캐시 중 오류: $e');
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
              fit: BoxFit.fill,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('리소스 준비 중...', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 240,
                      child: LinearProgressIndicator(
                        value: _progress,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}