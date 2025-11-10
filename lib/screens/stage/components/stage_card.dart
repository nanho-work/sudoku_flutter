import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/stage_model.dart';
import '../../../models/stage_progress_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/stage_progress_provider.dart';
import 'star_reward_widget.dart';
import 'stage_play_screen.dart';

class StageCard extends StatelessWidget {
  final StageModel stage;
  final StageProgressModel? progress;
  final bool locked;
  final UserModel? currentUser;

  const StageCard({
    super.key,
    required this.stage,
    this.progress,
    this.locked = false,
    this.currentUser,
  });

  Widget _buildThumbnail(String thumbnail) {
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
      return Image.network(
        thumbnail,
        height: 160,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        thumbnail,
        height: 80,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleared = progress?.cleared ?? false;
    final stars = progress?.stars ?? {"1": false, "2": false, "3": false};
    final rewards =
        progress?.rewardsClaimed ?? {"1": false, "2": false, "3": false};

    return Card(
      elevation: 0,
      color: Colors.transparent, // ✅ 투명 처리 (배경 중첩 제거)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (locked)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.lock, size: 28, color: Colors.white70),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(stage.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (stage.thumbnail != null && stage.thumbnail!.isNotEmpty)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildThumbnail(stage.thumbnail!),
                        ),
                        if (cleared)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '클리어',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(stage.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StarRewardWidget(
                        stars: stars,
                        rewardsClaimed: rewards,
                        rewards: stage.rewards,
                        stageModel: stage,
                        onClaim: (key) {
                          if (currentUser == null) return;
                          context
                              .read<StageProgressProvider>()
                              .claimReward(stage.id, key, stage, currentUser!);
                        },
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: locked
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StagePlayScreen(stage: stage, user: currentUser),
                                  ),
                                ).then((_) {
                                  context
                                      .read<StageProgressProvider>()
                                      .loadProgress([stage.id]);
                                });
                              },
                        child: const Text('도전'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}