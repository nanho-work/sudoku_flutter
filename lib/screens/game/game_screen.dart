import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ad_banner_service.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/audio_controller.dart';
import '../../services/audio_service.dart';
import '../../controllers/theme_controller.dart';
import 'components/game_header.dart';
import 'components/game_board.dart';
import 'components/game_buttons.dart';
import 'components/game_overlay.dart';
import 'components/number_pad.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final DateTime? missionDate;

  const GameScreen({
    Key? key,
    required this.difficulty,
    this.missionDate,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AudioController _audio;
  bool _isBannerReady = false;

  @override
  void initState() {
    super.initState();
    _audio = context.read<AudioController>();

    // 첫 프레임 이후에 BGM 시작 + 배너 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.playGameBgm();

      AdBannerService.loadBannerAd(
        onLoaded: () {
          if (!mounted) return;
          setState(() => _isBannerReady = true);
        },
        onFailed: (error) {
          if (!mounted) return;
          setState(() => _isBannerReady = false);
        },
      );
    });
  }

  @override
  void dispose() {
    // ⚠️ 프레임 락 시간에 notifyListeners가 발생하면 예외가 나므로,
    // 다음 프레임으로 넘겨 안전하게 정지한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _audio.stopGameBgm();
      } catch (e, st) {
      }
    });

    AdBannerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;

    return ChangeNotifierProvider(
      create: (_) => GameController(widget.difficulty, widget.missionDate),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: null,
            body: SafeArea(
              child: Container(
                color: colors.background,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        if (_isBannerReady) AdBannerService.bannerWidget(),

                        const GameHeader(),
                        const GameBoard(),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Consumer<GameController>(
                                builder: (context, controller, _) => NumberPad(
                                  onNumberInput: (number) {
                                    controller.onNumberInput(
                                      number,
                                      (correct) => _audio.playSfx(
                                        correct ? SoundFiles.success : SoundFiles.fail,
                                      ),
                                      (msg) => ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      ),
                                      context,
                                    );
                                  },
                                  numberCounts: controller.numberCounts,
                                ),
                              ),
                              const GameButtonBar(),
                            ],
                          ),
                        ),
                        const GameOverlay(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}