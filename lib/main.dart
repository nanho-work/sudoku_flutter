import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/user_model.dart';

import 'services/user_service.dart';
import 'services/stage_service.dart';
import 'services/ad_reward_service.dart';

import 'providers/stage_progress_provider.dart';

import 'controllers/audio_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/skin_controller.dart';

import 'screens/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_layout.dart';

import 'l10n/app_localizations.dart';

import 'firebase_options.dart';


Future<void> main() async {
  debugPrint("🟢 [MAIN] 앱 실행 시작");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("✅ Flutter 바인딩 초기화 완료");
  debugPrint("🟣 Firebase 초기화 중...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("✅ Firebase 초기화 완료");

  debugPrint("🟣 Firestore 스테이지 동기화 시작");
  try {
    await StageService().syncStagesFromFirestore();
    debugPrint("✅ Firestore 스테이지 동기화 성공");
  } catch (e) {
    debugPrint("❌ Firestore 스테이지 동기화 실패: $e");
  }

  debugPrint("🟣 컨트롤러 초기화 시작");
  final audioController = AudioController();
  final themeController = ThemeController();
  final skinController = SkinController();
  await skinController.loadSkins();
  debugPrint("✅ 컨트롤러 초기화 완료");

  debugPrint("🟣 runApp 실행 중...");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => audioController),
        ChangeNotifierProvider(create: (_) => themeController),
        ChangeNotifierProvider(create: (_) => skinController),
      ],
      child: const MyAppWrapper(),
    ),
  );
  debugPrint("✅ runApp 완료 (빌드 대기 중)");

  unawaited(_initializeAsync(audioController, themeController));
}

Future<void> _initializeAsync(
  AudioController audioController,
  ThemeController themeController,
) async {
  debugPrint("🟡 [_initializeAsync] 비동기 초기화 시작");
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
    debugPrint("✅ [_initializeAsync] 비동기 초기화 완료");
  } catch (e, st) {
    debugPrint("❌ 초기화 중 오류 발생: $e\n$st");
  }
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;
        debugPrint("🟣 [MyAppWrapper] FirebaseAuth 상태 감지됨: ${isLoggedIn ? "로그인됨" : "로그아웃"}");
        return MultiProvider(
          providers: [
            StreamProvider<UserModel?>.value(
              value: isLoggedIn
                  ? UserService().streamUserModel()
                  : const Stream.empty(),
              initialData: null,
            ),
            if (isLoggedIn)
              ChangeNotifierProvider(
                create: (_) => StageProgressProvider(user!.uid),
              ),
          ],
          child: MyApp(isLoggedIn: isLoggedIn),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
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
          home: SplashScreenWrapper(isLoggedIn: isLoggedIn),
        );
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  final bool isLoggedIn;
  const SplashScreenWrapper({super.key, required this.isLoggedIn});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _isSplashFinished = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() async {
    debugPrint("🟡 스플래시 타이머 시작");
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isSplashFinished = true);
      debugPrint("✅ 스플래시 타이머 종료, 메인 진입");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSplashFinished) {
      return const SplashScreen();
    } else {
      return widget.isLoggedIn
          ? const MainLayout()
          : const LoginScreen();
    }
  }
}