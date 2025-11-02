import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/stage_model.dart';
import '../../../models/user_model.dart';
import '../../../controllers/stage_controller.dart';
import '../../../services/ad_banner_service.dart';
import '../../../controllers/theme_controller.dart';
import 'stage_board.dart';
import 'stage_number_pad.dart';
import 'stage_header.dart';
import 'stage_button_bar.dart';
import 'stage_clear_dialog.dart';
import '../../../services/stage_service.dart';

/// 🎮 StagePlayScreen (기존 구조 유지)
class StagePlayScreen extends StatefulWidget {
  final StageModel stage;
  final UserModel? user;

  const StagePlayScreen({
    super.key,
    required this.stage,
    this.user,
  });

  @override
  State<StagePlayScreen> createState() => _StagePlayScreenState();
}

class _StagePlayScreenState extends State<StagePlayScreen> {
  bool _isBannerReady = false;
  bool _showingDialog = false;

  @override
  void initState() {
    super.initState();
    AdBannerService.loadGameBanner(
      onLoaded: () => setState(() => _isBannerReady = true),
      onFailed: (_) => setState(() => _isBannerReady = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final uid = widget.user?.uid ?? "guest";

    return ChangeNotifierProvider(
      create: (_) => StageController(stage: widget.stage, uid: uid),
      child: Consumer<StageController>(
        builder: (context, controller, _) {
          // ✅ 클리어 시 보상 팝업
          if (controller.isCleared && !_showingDialog) {
            _showingDialog = true;
            showStageClearDialog(
              context: context,
              stage: widget.stage,
              user: widget.user,
              controller: controller,
            ).then((_) => _showingDialog = false);
          }

          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Column(
                children: [
                  // 광고 영역
                  _isBannerReady
                      ? AdBannerService.gameBannerWidget()
                      : Container(
                          height: 50,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text("광고 로딩 중..."),
                        ),

                  // 상단 스테이지 헤더
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: StageHeader(controller: controller),
                  ),

                  // 메인 퍼즐 보드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: StageBoard(
                              board: controller.board,
                              shape: controller.shape,
                              selectedRow: controller.selectedRow,
                              selectedCol: controller.selectedCol,
                              onCellTap: controller.selectCell,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 숫자패드가 gridSize만큼만 노출
                          StageNumberPad(
                            onNumberInput: controller.onNumberInput,
                            maxNumber: controller.stage.gridSize,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 하단 버튼바: 튜토리얼(2x2)에서는 숨김
                  const SizedBox(height: 8),
                  if (controller.stage.gridSize > 2)
                    StageButtonBar(controller: controller),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}