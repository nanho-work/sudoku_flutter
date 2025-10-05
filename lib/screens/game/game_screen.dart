import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 💡 광고 관련 import 추가
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_banner_service.dart'; 
import '../../controllers/game_controller.dart';
import '../../controllers/audio_controller.dart';
import '../../services/audio_service.dart';
import 'components/game_header.dart';
import 'components/game_board.dart';
import 'components/game_buttons.dart';
import 'components/game_overlay.dart';
import 'components/number_pad.dart';

/// 게임 전체 화면
class GameScreen extends StatefulWidget {
  final String difficulty;
  final DateTime? missionDate;

  const GameScreen({Key? key, required this.difficulty, this.missionDate})
      : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AudioController audioController;
  // 💡 배너 로딩 상태 변수 추가
  bool _isBannerReady = false; 

  @override
  void initState() {
    super.initState();
    audioController = context.read<AudioController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController.playGameBgm();
      AdBannerService.loadBannerAd(
        onLoaded: () {
          if (mounted) {
            setState(() {
              _isBannerReady = true;
            });
          }
        },
        onFailed: (error) {
          debugPrint("GameScreen Ad loading failed: $error");
          if (mounted) {
            setState(() {
              _isBannerReady = false;
            });
          }
        },
      );
    });
  }

  @override
  void dispose() {
    audioController.stopGameBgm();
    // 💡 배너 리소스 정리 추가
    AdBannerService.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameController(widget.difficulty, widget.missionDate),
      child: Scaffold(
        // 💡 AppBar 제거
        appBar: null,
        
        body: SafeArea(
          // 💡 [핵심 수정]: 전체 게임 영역에 최대 너비(600px) 제한 적용
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0), // 최대 너비 제한
              child: Column(
                children: [
                  // 💡 AppBar 바로 아래, body의 최상단에 배너 광고 삽입
                  if (_isBannerReady)
                    AdBannerService.bannerWidget(),

                  const GameHeader(),
                  
                  // GameBoard는 여전히 중앙 상단에 배치 (자체 크기 계산)
                  const GameBoard(), 
                  
                  // 💡 NumberPad와 GameButtonBar 영역: 남은 공간 전체를 사용
                  Expanded(
                    child: Column(
                      // 💡 핵심 UX 개선: 스크롤 제거 및 남은 공간을 균등하게 분배
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 💡 NumberPad의 maxHeight 제약은 더 이상 필요하지 않으므로 제거하거나 유지할 수 있으나,
                        // UX 통일을 위해 maxWidth 제약이 더 중요함. 일단 maxHeight 제약은 제거함.
                        Consumer<GameController>(
                          builder: (context, controller, _) => NumberPad(
                            onNumberInput: (number) {
                              controller.onNumberInput(
                                number,
                                (correct) => audioController.playSfx(
                                  correct
                                      ? SoundFiles.success
                                      : SoundFiles.fail,
                                ),
                                (msg) => ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                ),
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
  }
}
