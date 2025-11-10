import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../controllers/audio_controller.dart';
import '../controllers/skin_controller.dart';
import '../services/stage_service.dart';
import '../services/skin_local_cache.dart';
import 'main_layout.dart';
import 'login/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AudioController _audio;
  bool _updateRequired = false;
  double _progress = 0;
  String _statusText = '리소스를 준비하는 중입니다...';
  late final AnimationController _textFadeController;

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
    debugPrint('🚀 Splash init 시작');
    _audio = context.read<AudioController>();
    debugPrint('🟢 Splash init try-block 시작');
    try {
      final skinController = context.read<SkinController>();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

      if (mounted) {
        setState(() {
          _statusText = '스킨 정보를 불러오는 중입니다...';
        });
      }

      debugPrint('🔹 1) 스킨 초기화 시작');
      await skinController.initSkins(userId);
      debugPrint('✅ 스킨 초기화 완료');
      if (mounted) {
        setState(() {
          _progress = 0.2;
          _statusText = '리소스를 다운로드 중입니다...';
        });
      }

      debugPrint('🔹 로컬 캐시 프리로드 시작');
      await skinController.ensureLocalPreload();
      debugPrint('✅ 로컬 캐시 프리로드 완료 — 캐시 디렉토리 점검 중');
      final cacheDir = await getApplicationDocumentsDirectory();
      final files = cacheDir.listSync();
      debugPrint('📂 캐시 디렉토리 파일 수: ${files.length}');
      for (final f in files) {
        debugPrint(' - ${f.path}');
      }
      if (mounted) {
        setState(() {
          _progress = 0.4;
          _statusText = '최적화 중...';
        });
      }

      debugPrint('🔹 캐릭터 리소스 프리캐시 시작');
      await _precacheAllSkins(context, skinController);
      debugPrint('✅ 캐릭터 리소스 프리캐시 완료');
      if (mounted) {
        setState(() {
          _progress = 0.6;
          _statusText = '캐릭터 리소스를 불러오는 중입니다...';
        });
      }

      debugPrint('🔹 스테이지 썸네일 프리캐시 시작');
      await _precacheStageThumbnails(context);
      debugPrint('✅ 스테이지 썸네일 프리캐시 완료');
      if (mounted) {
        setState(() {
          _progress = 0.8;
          _statusText = '스테이지 썸네일을 준비하는 중입니다...';
        });
      }

      debugPrint('🔹 배경 로티 프리로드 시작');
      final skinState = skinController.state;
      if (skinState?.selectedBgId != null && skinState!.selectedBgId!.isNotEmpty) {
        final localBgPath = await SkinLocalCache.getLocalPath(skinState.selectedBgId!);
        if (localBgPath != null && localBgPath.contains('.json')) {
          try {
            final file = File(localBgPath);
            final completer = Completer<void>();
            final lottie = Lottie.file(
              file,
              fit: BoxFit.fill,
              onLoaded: (_) {
                debugPrint('🎬 Lottie first frame loaded (GPU ready)');
                completer.complete();
              },
            );

            OverlayEntry? entry;
            entry = OverlayEntry(
              builder: (_) => Offstage(child: lottie),
            );
            Overlay.of(context).insert(entry);

            await completer.future;
            entry.remove();

            debugPrint('✅ GPU Lottie preload complete');
            debugPrint('✅ 배경 로티 프리로드 완료');
          } catch (e) {
            debugPrint('⚠️ 배경 로티 프리로드 실패(GPU 단계): $e');
          }
        }
      }
      if (mounted) {
        setState(() {
          _progress = 0.9;
          _statusText = '배경 애니메이션을 준비하는 중입니다...';
        });
      }

      debugPrint('🔹 원격 업데이트 확인 시작');
      await _checkForUpdate();
      debugPrint('✅ 업데이트 체크 완료, 결과: $_updateRequired');
      if (_updateRequired || !mounted) return;

      if (mounted) {
        setState(() {
          _progress = 0.95;
          _statusText = '잠시 후 입장합니다...';
        });
      }

      // 약간의 딜레이 후 화면 전환
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _statusText = '잠시 후 입장합니다...';
        });
      }

      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      debugPrint('➡️ 메인 레이아웃 진입 준비 (isLoggedIn=$isLoggedIn)');
      if (_progress >= 0.99) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isLoggedIn ? const MainLayout() : const LoginScreen(),
          ),
        );
        debugPrint('✅ 메인 레이아웃으로 전환 완료 — Splash 종료');
        debugPrint('🏁 Splash init 정상 종료');
      }
    } catch (e, st) {
      debugPrint('❌ Splash init 실패');
      debugPrint('⚠️ Splash init error: $e\n$st');
    }
  }

  Future<void> _precacheAllSkins(
      BuildContext context, SkinController controller) async {
    try {
      for (final skin in controller.catalog) {
        // 캐릭터 이미지 (PNG/JPG/WebP 등)만 프리캐시
        if (skin.imageUrl.isNotEmpty && _isImageUrl(skin.imageUrl)) {
          if (!mounted) return;
          await precacheImage(
            CachedNetworkImageProvider(skin.imageUrl),
            context,
          );
        }
        // 이미지든 JSON이든 모두 로컬로 다운로드 (오프라인 캐시 목적)
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
            if (!mounted) return;
            await precacheImage(CachedNetworkImageProvider(thumb), context);
            await SkinLocalCache.downloadToDocuments(thumb);
          } else {
            if (!mounted) return;
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