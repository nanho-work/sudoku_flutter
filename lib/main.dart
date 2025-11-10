import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'dart:async' show unawaited;
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
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ 전역 컨트롤러 초기화
  final audioController = AudioController();
  final themeController = ThemeController();
  final skinController = SkinController();
  await skinController.loadSkins();

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
        debugPrint("⚠️ Google Mobile Ads 초기화 실패 (무시됨): $e");
      }
    }
    await audioController.init();
    await themeController.loadTheme();
  } catch (e, st) {
    debugPrint("❌ 초기화 오류: $e\n$st");
  }
}

class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});
  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  bool _initialized = false;
  List<String> _stageIds = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isLoggedIn = user != null;

        if (isLoggedIn && !_initialized) {
          return FutureBuilder(
            future: _preloadStages(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  home: Scaffold(body: Center(child: CircularProgressIndicator())),
                );
              }

              _initialized = true;
              return MultiProvider(
                providers: [
                  StreamProvider<UserModel?>.value(
                    value: UserService().streamUserModel(),
                    initialData: null,
                  ),
                  ChangeNotifierProvider(
                    create: (_) => StageProgressProvider(user!.uid)..init(_stageIds),
                  ),
                ],
                child: _buildApp(true),
              );
            },
          );
        }

        return _buildApp(isLoggedIn && _initialized);
      },
    );
  }

  Future<void> _preloadStages() async {
    await StageService().syncStagesFromFirestore();
    final stages = await StageService().loadStages();
    _stageIds = stages.map((s) => s.id).toList();
  }

  Widget _buildApp(bool isLoggedIn) => MyApp(isLoggedIn: isLoggedIn);
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

class SplashScreenWrapper extends StatelessWidget {
  final bool isLoggedIn;
  const SplashScreenWrapper({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}