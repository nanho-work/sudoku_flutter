import 'package:flutter/material.dart';
import '../../../../models/stage_model.dart';

class StarRewardWidget extends StatelessWidget {
  final Map<String, bool> stars;
  final Map<String, bool> rewardsClaimed;
  final Map<String, dynamic> rewards;
  final StageModel stageModel;
  final void Function(String starKey)? onClaim;

  const StarRewardWidget({
    super.key,
    required this.stars,
    required this.rewardsClaimed,
    required this.rewards,
    required this.stageModel,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final starKeys = stars.keys.toList();
    final conditions = stageModel.conditions ?? {};
    final conditionTexts = [
      '힌트 없이 클리어 (힌트 ≤ ${conditions["max_hints"]})',
      '시간 제한 내 클리어 (${conditions["time_limit"]}초)',
      '무오류 클리어 (오답 ≤ ${conditions["max_wrong_attempts"]})',
    ];

    final Map<String, String> rewardNameMap = {
      'gold': '골드',
      'gem': '보석',
      'exp': '포인트',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(starKeys.length, (i) {
        final key = starKeys[i];
        final rewardKey = rewards.keys.elementAt(i);
        final rewardValue = rewards[rewardKey];
        final achieved = stars[key] ?? false;
        final claimed = rewardsClaimed[key] ?? false;
        final rewardName = rewardNameMap[rewardKey] ?? rewardKey;
        final rewardDescription = '${conditionTexts[i]}\n→ $rewardName +$rewardValue';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Tooltip(
            message: !achieved
                ? '보상 미달성'
                : claimed
                    ? '보상 수령 완료'
                    : '보상 수령 가능!',
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: !achieved || claimed
                  ? null
                  : () {
                      final tooltip = Tooltip(
                        message: '보상이 수령됩니다!',
                        child: const SizedBox.shrink(),
                      );
                      final dynamic tooltipState = tooltip.createState();
                      tooltipState.ensureTooltipVisible();
                      onClaim?.call(key);
                    },
              child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          achieved ? Icons.star : Icons.star_border,
                          color: Colors.black.withOpacity(0.5),
                          size: 42,
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: claimed ? 1.0 : 1.1,
                          child: Icon(
                            achieved ? Icons.star : Icons.star_border,
                            color: !achieved
                                ? Colors.grey
                                : claimed
                                    ? Colors.amber.withOpacity(0.8)
                                    : Colors.amberAccent,
                            size: 38,
                          ),
                        ),
                        if (achieved && !claimed)
                          const Positioned(
                            right: -2,
                            top: -2,
                            child: Icon(
                              Icons.priority_high_rounded,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rewardDescription
                          .split('\n')
                          .map((line) => Container(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: Colors.white.withOpacity(0.7),
                                child: Text(
                                  line,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !achieved
                                        ? Colors.black
                                        : claimed
                                            ? Colors.black
                                            : Colors.amberAccent,
                                    fontWeight: !achieved
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}