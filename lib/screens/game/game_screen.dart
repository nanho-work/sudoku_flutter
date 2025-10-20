import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ad_banner_service.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/audio_controller.dart';
import '../../services/audio_service.dart';
import '../../controllers/theme_controller.dart';
import 'components/game_header.dart';
import 'components/game_buttons.dart';
import 'components/game_overlay.dart';
import 'components/number_pad.dart';
import '../../widgets/sudoku_board.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audio.playGameBgm();

      AdBannerService.loadGameBanner(
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _audio.stopGameBgm();
      } catch (_) {}
    });

    AdBannerService.disposeGameBanner();
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
            body: SafeArea(
              child: Container(
                color: colors.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (_isBannerReady)
                      AdBannerService.gameBannerWidget()
                    else
                      Container(
                        height: AdSize.banner.height.toDouble(),
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Text(
                          "광고 로딩 중...",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),

                    const GameHeader(),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Consumer<GameController>(
                        builder: (context, controller, _) => SudokuBoard(
                          board: controller.board,
                          notes: controller.notes,
                          onCellTap: controller.onCellTap,
                          selectedRow: controller.selectedRow,
                          selectedCol: controller.selectedCol,
                          invalidRow: controller.invalidRow,
                          invalidCol: controller.invalidCol,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

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
                                duration: const Duration(milliseconds: 500),
                              ),
                            ),
                            context,
                          );
                        },
                        numberCounts: controller.numberCounts,
                      ),
                    ),

                    const SizedBox(height: 18),
                    const GameButtonBar(),
                    const GameOverlay(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}