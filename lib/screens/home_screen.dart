import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../widgets/difficulty_card.dart'; // 새로 만든 파일 import

/// 홈 스크린 (난이도 선택 / 게임 시작 버튼)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Koofy 스도쿠",
            style: TextStyle(
            fontSize: 24,         // 글자 크기
            fontWeight: FontWeight.bold, // 굵게
            color: Colors.black,  // 글자 색 (AppBar 색상 대비해서 선택)
            ),
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
                const Text(
                  "게임을 시작할 난이도를 선택하세요",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // 쉬움 카드
                DifficultyCard(
                  color: Colors.green[200]!,
                  hoverColor: Colors.green[300]!,
                  title: "쉬움",
                  subtitle: "처음 도전하는 분께 추천!",
                  onTap: () => _startGame(context, "easy"),
                ),

                const SizedBox(height: 16),

                DifficultyCard(
                  color: Colors.orange[200]!,
                  hoverColor: Colors.orange[300]!,
                  title: "보통",
                  subtitle: "적당한 난이도로 두뇌훈련",
                  onTap: () => _startGame(context, "normal"),
                ),

                const SizedBox(height: 16),

                DifficultyCard(
                  color: Colors.red[200]!,
                  hoverColor: Colors.red[300]!,
                  title: "어려움",
                  subtitle: "퍼즐 마스터 도전!",
                  onTap: () => _startGame(context, "hard"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}