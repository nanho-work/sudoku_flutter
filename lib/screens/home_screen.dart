import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // 불필요한 import 제거
import 'package:sudoku_flutter/screens/game/game_screen.dart';
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
            "가나다가나다", // 앱 이름이나 메인 제목
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 28),
            color: colors.textPrimary,
            tooltip: '테마 변경',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ThemeSelectorWidget(),
              );
            },
          ),
          Consumer<AudioController>(
            builder: (context, audioController, _) {
              final sfxEnabled = audioController.sfxEnabled; // SFX 상태를 사용하여 아이콘 표시
              return IconButton(
                icon: Icon(
                  sfxEnabled ? Icons.volume_up : Icons.volume_off,
                  size: 28,
                  // 활성화 시 액센트 컬러, 비활성화 시 회색 톤 사용
                  color: colors.textPrimary,
                ),
                tooltip: '사운드 설정',
                onPressed: () {
                  // audioController.playSfx(SoundFiles.click); // 필요 시 SFX 재생
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    // SoundSettingsWidget을 다크 테마로 감싸지 않아도, 내부에서 Theme.dark()를 사용하므로 문제 없음
                    builder: (_) => const SoundSettingsWidget(),
                  );
                },
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
        child: Column(
          children: [
            const SizedBox(height: 16),
            // --- 1. 개선된 App Header ---
            _buildAppHeader(context, colors),
            const SizedBox(height: 32),

            // --- 2. 난이도 선택 타이틀 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "난이도를 선택하세요",
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

            // --- 3. 난이도 카드 목록 ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // 상단 정렬
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 난이도 카드 색상 및 쉐도우 개선 (다크 테마에 어울리게 팔레트 색상 사용)
                    DifficultyCard(
                      color: colors.primary,
                      hoverColor: _hover(colors.primary),
                      title: "쉬움 (Easy)",
                      subtitle: "처음 도전하는 분께 추천!",
                      onTap: () => _startGame("easy"),
                    ),
                    const SizedBox(height: 24), // 간격 증가
                    DifficultyCard(
                      color: colors.secondary,
                      hoverColor: _hover(colors.secondary),
                      title: "보통 (Normal)",
                      subtitle: "적당한 난이도로 두뇌 훈련",
                      onTap: () => _startGame("normal"),
                    ),
                    const SizedBox(height: 24), // 간격 증가
                    DifficultyCard(
                      color: colors.error,
                      hoverColor: _hover(colors.error),
                      title: "어려움 (Hard)",
                      subtitle: "퍼즐 마스터에 도전하세요!",
                      onTap: () => _startGame("hard"),
                    ),
                    const SizedBox(height: 40), // 하단 여백 추가
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
