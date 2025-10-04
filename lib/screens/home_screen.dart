// lib/screens/home_screen.dart (수정된 파일)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // 불필요한 import 제거
import 'package:sudoku_flutter/screens/game/game_screen.dart';
import '../widgets/difficulty_card.dart';
import '../widgets/sound_settings.dart';
import '../controllers/audio_controller.dart';


/// 홈 스크린 (난이도 선택 / 게임 시작 버튼)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  // 기존 배너 관련 멤버 변수 모두 제거
  // BannerAd? _bannerAd;
  // bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    // 기존 배너 로드 로직 제거
  }

  @override
  void dispose() {
    // 기존 배너 dispose 로직 제거 (AppHeader에서 처리)
    super.dispose();
  }

  Future<void> _startGame(String difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 불필요한 날짜/일수 계산 로직은 UI에 사용되지 않으므로 제거하거나 주석 처리하는 것을 고려해 보세요.
    /*
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final today = now.day;
    int daysInMonth(int year, int month) {
      final beginningNextMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);
      return beginningNextMonth.subtract(const Duration(days: 1)).day;
    }
    final totalDays = daysInMonth(year, month);
    */

    return Scaffold(
      // 💡 핵심 수정: AppHeader 위젯을 사용
      
      body: Column(
        children: [
          // 기존 배너 위젯 표시 로직 제거

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "난이도 선택",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Consumer<AudioController>(
                            builder: (context, audioController, _) {
                              final bgmEnabled = audioController.bgmEnabled;
                              return IconButton(
                                icon: Icon(
                                  bgmEnabled ? Icons.volume_up : Icons.volume_off,
                                  size: 28,
                                  color: bgmEnabled ? Colors.black : Colors.grey,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => const SoundSettingsWidget(),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      DifficultyCard(
                        color: Colors.green[200]!,
                        hoverColor: Colors.green[300]!,
                        title: "쉬움",
                        subtitle: "처음 도전하는 분께 추천!",
                        onTap: () => _startGame("easy"),
                      ),
                      const SizedBox(height: 16),
                      DifficultyCard(
                        color: Colors.orange[200]!,
                        hoverColor: Colors.orange[300]!,
                        title: "보통",
                        subtitle: "적당한 난이도로 두뇌훈련",
                        onTap: () => _startGame("normal"),
                      ),
                      const SizedBox(height: 16),
                      DifficultyCard(
                        color: Colors.red[200]!,
                        hoverColor: Colors.red[300]!,
                        title: "어려움",
                        subtitle: "퍼즐 마스터 도전!",
                        onTap: () => _startGame("hard"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}