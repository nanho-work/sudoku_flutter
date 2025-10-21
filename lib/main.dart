import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'providers/app_providers.dart';
import 'controllers/audio_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/ad_reward_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 컨트롤러 생성
  final audioController = AudioController();
  final themeController = ThemeController();

  // 앱을 즉시 실행 (SplashScreen까지 바로 진입)
  runApp(
    AppProviders.register(
      audioController: audioController,
      themeController: themeController,
      child: const MyApp(),
    ),
  );

  // 백그라운드 초기화 (광고 승인 대기 중이라도 앱 실행됨)
  unawaited(_initializeAsync(audioController, themeController));
}

Future<void> _initializeAsync(
  AudioController audioController,
  ThemeController themeController,
) async {
  try {
    if (!kIsWeb) {
      try {
        await MobileAds.instance.initialize();
        await AdRewardService.loadRewardedAd();
      } catch (e) {
        debugPrint("⚠️ 광고 초기화 실패 (무시됨): $e");
      }
    }

    await audioController.init();
    await themeController.loadTheme();
    debugPrint("✅ 비동기 초기화 완료");
  } catch (e, st) {
    debugPrint("❌ 초기화 중 오류 발생: $e\n$st");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        final colors = themeController.colors;
        final brightness = themeController.brightness;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Koofy Sudoku',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko'),
            Locale('en'),
            Locale('ja'),
            Locale('zh'),
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}