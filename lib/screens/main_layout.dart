import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_controller.dart';
import '../controllers/theme_controller.dart';
import 'home/home_screen.dart';
import 'mission_screen.dart';
import 'info_screen.dart';
import 'guide_screen.dart';
import '../widgets/app_footer.dart';
// 💡 AppHeader import 추가
import '../widgets/app_header.dart'; // AppHeader 경로에 맞게 수정해주세요.

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WidgetsBindingObserver {
  late AudioController audio;

  int _currentIndex = 0;

  // HomeScreen에서 AppHeader를 제거했으므로, 다시 HomeScreen을 리스트에 포함합니다.
  final List<Widget> _screens = const [
    HomeScreen(),
    MissionScreen(),
    GuideScreen(),
    InfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    audio = context.read<AudioController>();
    audio.startMainBgm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 앱 라이프사이클 상태 변경 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audio.pauseAll();
    } else if (state == AppLifecycleState.resumed) {
      audio.resumeAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return Scaffold(
      // 💡 핵심 수정: AppHeader를 MainLayout의 AppBar로 설정합니다.
      appBar: const AppHeader(), 
      
      // body는 현재 선택된 화면을 표시합니다.
      body: _screens[_currentIndex],
      
      bottomNavigationBar: AppFooter(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
      backgroundColor: colors.background,
    );
  }
}