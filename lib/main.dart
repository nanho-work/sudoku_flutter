import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/app_providers.dart';
import 'controllers/theme_controller.dart';
import 'screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("❌ Google Mobile Ads 초기화 실패: $e");
    }
  }

  runApp(AppProviders.register(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
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
          // locale: const Locale('ko'), // Uncomment to force Korean
          theme: ThemeData(
            brightness: brightness,
            primaryColor: colors.primary,
            scaffoldBackgroundColor: colors.background,
            colorScheme: ColorScheme(
              brightness: brightness,
              primary: colors.primary,
              onPrimary: colors.textPrimary,
              secondary: colors.accent,
              onSecondary: colors.textSecondary,
              error: colors.error,
              onError: Colors.white,
              background: colors.background,
              onBackground: colors.textPrimary,
              surface: colors.surface,
              onSurface: colors.textPrimary,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}