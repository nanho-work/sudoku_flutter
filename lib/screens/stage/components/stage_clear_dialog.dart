import 'package:flutter/material.dart';
import '../../../models/stage_model.dart';
import '../../../models/user_model.dart';
import '../../../controllers/stage_controller.dart';
import '../../../services/stage_service.dart';
import 'stage_reward_popup.dart';
import 'stage_play_screen.dart';

/// 🎉 스테이지 클리어 시 호출되는 다이얼로그 전용 위젯
Future<void> showStageClearDialog({
  required BuildContext context,
  required StageModel stage,
  required UserModel? user,
  required StageController controller,
}) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StageRewardPopup(
      stage: stage,
      user: user,
      controller: controller,
      onNext: () async {
        await controller.saveProgress();
        if (!context.mounted) return;

        final stages = await StageService().loadStages();
        final currentIndex = stages.indexWhere((s) => s.id == stage.id);
        if (currentIndex != -1 && currentIndex + 1 < stages.length) {
          final nextStage = stages[currentIndex + 1];
          Navigator.of(context).pop(); // 팝업 닫기
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => StagePlayScreen(stage: nextStage, user: user),
            ),
          );
        } else {
          Navigator.of(context).pop(); // 마지막 스테이지면 닫기만
        }
      },
      onClose: () async {
        await controller.saveProgress();
        if (!context.mounted) return;
        Navigator.of(context).pop(); // close dialog
        Navigator.of(context).pop(); // close StagePlayScreen
      },
    ),
  );
}