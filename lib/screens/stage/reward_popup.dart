import 'package:flutter/material.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../models/stage_progress_model.dart';
import '../../services/reward_service.dart';
import '../../services/stage_service.dart';

/// 🎁 스테이지 클리어 시 보상 지급 팝업
class RewardPopup extends StatefulWidget {
  final StageModel stage;
  final UserModel? user; // ✅ 게스트 보호
  final Map<String, bool> stars;
  final VoidCallback onClose;

  const RewardPopup({
    super.key,
    required this.stage,
    required this.user,
    required this.stars,
    required this.onClose,
  });

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup> {
  bool _applying = false;

  @override
  Widget build(BuildContext context) {
    final reward = RewardService().calculateReward(widget.stage, widget.stars);
    final canApply = widget.user != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('🎉 스테이지 클리어'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('획득 보상', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text('💰 Gold: +${reward['gold']}'),
          Text('💎 Gems: +${reward['gems']}'),
          Text('⭐ Exp: +${reward['exp']}'),
          if (!canApply) ...[
            const SizedBox(height: 12),
            const Text(
              '로그인 정보를 찾지 못해 보상을 지급할 수 없습니다.',
              style: TextStyle(fontSize: 12, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _applying
              ? null
              : () async {
                  if (_applying) return;
                  setState(() => _applying = true);

                  try {
                    if (canApply) {
                      // ① 유저 보상 반영
                      await RewardService().applyReward(widget.user!, reward);

                      // ② 스테이지 진행 저장
                      final progress = StageProgressModel(
                        stageId: widget.stage.id,
                        cleared: true,
                        stars: Map<String, bool>.from(widget.stars),
                        rewardsClaimed: Map<String, bool>.from(widget.stars),
                        lastPlayed: DateTime.now(),
                      );
                      await StageService().saveProgress(widget.user!.uid, progress);
                    }
                  } catch (e) {
                    debugPrint('RewardPopup error: $e');
                  } finally {
                    if (mounted) setState(() => _applying = false);
                    widget.onClose();
                  }
                },
          child: Text(_applying ? '지급 중...' : '확인'),
        ),
      ],
    );
  }
}