import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../game/game_screen.dart';
import 'difficulty_card.dart';
import '../../../controllers/theme_controller.dart'; // 필요

class DifficultySection extends StatelessWidget {
  const DifficultySection({super.key});

  void _startGame(BuildContext context, String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(difficulty: difficulty)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = context.watch<ThemeController>().colors; // ✅ 팔레트 직접 사용

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            DifficultyCard(
              color: colors.easyCard,
              title: loc.difficulty_easy,
              subtitle: '${loc.difficulty_easy_subtitle}  (+5 골드)',
              icon: Icons.sentiment_satisfied_alt, // 쉬움
              onTap: () => _startGame(context, "easy"),
            ),
            const SizedBox(height: 20),
            DifficultyCard(
              color: colors.normalCard,
              title: loc.difficulty_normal,
              subtitle: '${loc.difficulty_normal_subtitle}  (+10 골드)',
              icon: Icons.lightbulb, // 보통
              onTap: () => _startGame(context, "normal"),
            ),
            const SizedBox(height: 20),
            DifficultyCard(
              color: colors.hardCard,
              title: loc.difficulty_hard,
              subtitle: '${loc.difficulty_hard_subtitle}  (+20 골드)',
              icon: Icons.local_fire_department, // 어려움
              onTap: () => _startGame(context, "hard"),
            ),
            const SizedBox(height: 20),
            DifficultyCard(
              color: colors.extremeCard,
              title: loc.difficulty_extreme,
              subtitle: '${loc.difficulty_extreme_subtitle}  (+30 골드)',
              icon: Icons.dangerous, // 극악
              onTap: () => _startGame(context, "extreme"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}