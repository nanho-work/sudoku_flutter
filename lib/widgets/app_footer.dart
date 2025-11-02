import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import '../controllers/audio_controller.dart';
import '../services/audio_service.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required String assetPath,
    required String labelKey,
  }) {
    final colors = context.read<ThemeController>().colors;
    final loc = AppLocalizations.of(context)!;
    final localizedLabel = {
      'home': loc.home,
      'mission': loc.footer_label_mission,
      'stage': '스테이지',
      'guide': loc.footer_label_guide,
      'ranking': '랭킹',
    }[labelKey] ?? labelKey;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(assetPath, width: 60, height: 60),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.background.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              localizedLabel,
              style: TextStyle(fontSize: 12, color: colors.textMain),
            ),
          ),
        ],
      ),
      label: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        final colors = themeController.colors;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 12,
          selectedItemColor: colors.cellSelected, // ✅ 선택 색상 개선
          unselectedItemColor: colors.bottomItemUnselected,
          onTap: (index) async {
            final audioController =
                Provider.of<AudioController>(context, listen: false);
            await audioController.playSfx(SoundFiles.menuTab);
            onTap(index);
          },
          items: [
            _buildNavItem(
              context,
              assetPath: 'assets/images/home.png',
              labelKey: 'home',
            ),
            _buildNavItem(
              context,
              assetPath: 'assets/images/mission.png',
              labelKey: 'mission',
            ),
            _buildNavItem(
              context,
              assetPath: 'assets/images/stage.png', // ✅ 신규 스테이지 아이콘
              labelKey: 'stage',
            ),
            _buildNavItem(
              context,
              assetPath: 'assets/images/guide.png',
              labelKey: 'guide',
            ),
            _buildNavItem(
              context,
              assetPath: 'assets/images/ranking.png',
              labelKey: 'ranking',
            ),
          ],
        );
      },
    );
  }
}