import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // 불필요한 import 제거
import 'package:sudoku_flutter/screens/game/game_screen.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import '../widgets/difficulty_card.dart';
import '../widgets/sound_settings.dart';
import '../widgets/theme_selector.dart';
import '../controllers/audio_controller.dart';
import '../controllers/theme_controller.dart';


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

  // UI 개선: 헤더 부분을 별도의 메서드로 분리하고 스타일링 강화
  Widget _buildAppHeader(BuildContext context, dynamic colors) {
    // SoundSettingsWidget에서 사용된 액센트 컬러를 가져옵니다.
    final Color accentColor = colors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.home_header_instruction, // 앱 이름이나 메인 제목
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ThemeSelectorWidget(),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.card.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.textSecondary.withOpacity(0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.palette_outlined,
                color: colors.textPrimary,
                size: 22,
              ),
            ),
          ),
          Consumer<AudioController>(
            builder: (context, audioController, _) {
              final sfxEnabled = audioController.sfxEnabled; // SFX 상태를 사용하여 아이콘 표시
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const SoundSettingsWidget(),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.card.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.textSecondary.withOpacity(0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    sfxEnabled ? Icons.volume_up : Icons.volume_off,
                    color: colors.textPrimary,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  // 테마 팔레트의 기본색을 약간 어둡게 만들어 hover 효과에 사용
  Color _hover(Color base, [double amount = .06]) {
    final hsl = HSLColor.fromColor(base);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final colors = themeController.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildAppHeader(context, colors),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.home_difficulty_title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DifficultyCard(
                      color: colors.primary,
                      hoverColor: _hover(colors.primary),
                      title: AppLocalizations.of(context)!.difficulty_easy_title,
                      subtitle: AppLocalizations.of(context)!.difficulty_easy_subtitle,
                      onTap: () => _startGame("easy"),
                    ),
                    const SizedBox(height: 24),
                    DifficultyCard(
                      color: colors.secondary,
                      hoverColor: _hover(colors.secondary),
                      title: AppLocalizations.of(context)!.difficulty_normal_title,
                      subtitle: AppLocalizations.of(context)!.difficulty_normal_subtitle,
                      onTap: () => _startGame("normal"),
                    ),
                    const SizedBox(height: 24),
                    DifficultyCard(
                      color: colors.error,
                      hoverColor: _hover(colors.error),
                      title: AppLocalizations.of(context)!.difficulty_hard_title,
                      subtitle: AppLocalizations.of(context)!.difficulty_hard_subtitle,
                      onTap: () => _startGame("hard"),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
