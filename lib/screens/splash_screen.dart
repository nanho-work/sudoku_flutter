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
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

    final skinController = context.read<SkinController>();
    await _downloadAllResources(skinController);

    await _checkForUpdate();
    if (_updateRequired) return;
  }

  Future<void> _downloadAllResources(SkinController controller) async {
    try {
      debugPrint('🚀 StageService.loadStages() 호출');
      final stages = await StageService().loadStages();
      debugPrint('📦 불러온 스테이지 수: ${stages.length}');
      final urls = <String>{
        ...controller.catalog.map((e) => e.imageUrl).where((e) => e.isNotEmpty),
        ...controller.catalog.map((e) => e.bgUrl ?? '').where((e) => e.isNotEmpty),
        ...stages.map((e) => e.thumbnail ?? '').where((e) => e.isNotEmpty),
      };
      debugPrint('🧩 다운로드 대상 URL 개수: ${urls.length}');
      debugPrint('🔗 다운로드 시작: ${urls.length}개의 리소스');
      int done = 0;
      for (final url in urls) {
        debugPrint('⬇️ [$done/${urls.length}] $url 다운로드 중...');
        await SkinLocalCache.downloadToDocuments(url);
        done++;
        if (!mounted) return;
        setState(() => _progress = done / urls.length);
      }
      debugPrint('🏁 리소스 다운로드 완료율: $_progress (${done}/${urls.length})');
      if (done == urls.length) {
        debugPrint('✅ 모든 리소스 다운로드 완료');
        if (!mounted) return;
        _fadeController.reverse();
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      }
    } catch (e) {
      debugPrint('⚠️ 리소스 다운로드 오류: $e');
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: const Duration(seconds: 5), minimumFetchInterval: Duration.zero));
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
                  final url = Uri.parse('https://play.google.com/store/apps/details?id=com.koofy.sudoku');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _fadeController,
            child: Image.asset('assets/images/splash_bg.png', fit: BoxFit.contain),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('리소스 다운로드 중...', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 240,
                    child: LinearProgressIndicator(
                      value: _progress,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${(_progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}