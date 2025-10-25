import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/audio_controller.dart';
import 'main_layout.dart';
import 'package:provider/provider.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AudioController _audio;

  @override
  void initState() {
    super.initState();

    _audio = context.read<AudioController>();
    _audio.playSfx('start_bg.mp3');

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _checkForUpdate();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      _fadeController.reverse();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      });
    });
  }

  Future<void> _checkForUpdate() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final latestVersion = remoteConfig.getString('latest_version');
    final info = await PackageInfo.fromPlatform();
    final currentVersion = '${info.version}+${info.buildNumber}';
    if (latestVersion.isNotEmpty && currentVersion.compareTo(latestVersion) < 0) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('업데이트 필요'),
          content: const Text('새로운 버전이 출시되었습니다. 업데이트 후 이용해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        ),
      );
      return;
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