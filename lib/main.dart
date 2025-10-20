import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'providers/app_providers.dart';
import 'controllers/audio_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'services/ad_reward_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("❌ Google Mobile Ads 초기화 실패: $e");
    }
    await AdRewardService.loadRewardedAd(); // ✅ 보상형 광고 사전 로드
  }

  // ✅ Controller 인스턴스 직접 생성 및 초기화
  final audioController = AudioController();
  await audioController.init();

  final themeController = ThemeController();
  await themeController.loadTheme();

  runApp(
    AppProviders.register(
      audioController: audioController,
      themeController: themeController,
      child: const MyApp(),
    ),
  );
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