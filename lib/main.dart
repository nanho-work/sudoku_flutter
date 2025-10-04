import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/splash_screen.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 광고 초기화 (웹 제외)
  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
    } catch (e, stack) {
      debugPrint("❌ Google Mobile Ads 초기화 실패: $e");
      debugPrint(stack.toString());
    }
  }

  runApp(AppProviders.register(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koofy Sudoku',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}