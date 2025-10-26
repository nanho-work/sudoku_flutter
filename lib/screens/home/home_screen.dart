import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_controller.dart';
import 'components/difficulty_section.dart';

/// 홈 스크린 (난이도 선택 / 게임 시작 버튼)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              SizedBox(height: 16),
              SizedBox(height: 32),
              DifficultySection(),
            ],
          ),
        ),
      ),
    );
  }
}