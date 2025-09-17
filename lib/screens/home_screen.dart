import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../widgets/difficulty_card.dart'; // 새로 만든 파일 import

/// 홈 스크린 (난이도 선택 / 게임 시작 버튼)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final today = now.day;

    // Get the number of days in the current month
    int daysInMonth(int year, int month) {
      final beginningNextMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);
      return beginningNextMonth.subtract(const Duration(days: 1)).day;
    }

    final totalDays = daysInMonth(year, month);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/koofy1.png', height: 48),
            const SizedBox(width: 8),
            const Text(
              "모두의 즐거움! Koofy",
              style: TextStyle(
                fontSize: 24,         // 글자 크기
                fontWeight: FontWeight.bold, // 굵게
                color: Colors.black,  // 글자 색 (AppBar 색상 대비해서 선택)
              ),
            ),
          ],
        ),
        centerTitle: true, // 타이틀을 가운데 정렬 (선택 사항)
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "난이도 선택",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),


                // 쉬움 카드
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
    );
  }
}