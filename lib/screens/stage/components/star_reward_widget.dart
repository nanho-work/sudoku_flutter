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
      '힌트 제한 (최대 ${conditions["max_hints"]}회 이하)',
      '시간 제한 ${conditions["time_limit"]}초 안에 클리어',
      '오답 제한 (최대 ${conditions["max_wrong_attempts"]}회 이하)',
    ];

    final Map<String, String> rewardNameMap = {
      'gold': '골드',
      'gem': '보석',
      'exp': '포인트',
    };

    final Map<String, String> rewardIconMap = {
      'gold': 'assets/images/gold.png',
      'gem': 'assets/images/gem.png',
      'exp': 'assets/images/point.png',
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
        final rewardDescription = conditionTexts[i];
        final rewardIcon = rewardIconMap[rewardKey];

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
                      final overlay = Overlay.of(context);
                      final entry = OverlayEntry(
                        builder: (context) => Positioned(
                          top: MediaQuery.of(context).size.height * 0.4,
                          left: MediaQuery.of(context).size.width * 0.3,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '🎁 보상 수령 완료!',
                                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      );
                      overlay.insert(entry);
                      Future.delayed(const Duration(seconds: 1), entry.remove);
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
                          Icons.star,
                          color: achieved
                              ? Colors.black.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.4),
                          size: 42,
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: claimed ? 1.0 : 1.1,
                          child: Icon(
                            Icons.star, // 항상 채워진 별
                            color: achieved
                                ? (claimed
                                    ? Colors.amber.withOpacity(0.8)
                                    : Colors.amberAccent)
                                : Colors.grey.withOpacity(0.7),
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
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            rewardDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: !achieved
                                  ? Colors.black
                                  : claimed
                                      ? Colors.black
                                      : Colors.amberAccent,
                              fontWeight: !achieved ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (rewardIcon != null)
                              Image.asset(
                                rewardIcon,
                                height: 20,
                              ),
                            const SizedBox(width: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              child: Text(
                                '→ $rewardName +$rewardValue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: !achieved
                                      ? Colors.black
                                      : claimed
                                          ? Colors.black
                                          : Colors.amberAccent,
                                  fontWeight: !achieved ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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