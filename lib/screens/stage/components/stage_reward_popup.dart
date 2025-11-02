import 'package:flutter/material.dart';
import '../../../models/stage_model.dart';
import '../../../models/user_model.dart';
import '../../../controllers/stage_controller.dart';

/// 🏆 StageRewardPopup
/// 클리어 후 보상 팝업 (조건 평가 기반)
class StageRewardPopup extends StatelessWidget {
  final StageModel stage;
  final UserModel? user;
  final StageController controller;
  final VoidCallback onClose;
  final VoidCallback onNext;

  const StageRewardPopup({
    super.key,
    required this.stage,
    this.user,
    required this.controller,
    required this.onClose,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final results = controller.evaluateConditions();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Text(
            "${stage.name}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text("클리어 성공!", style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(thickness: 1),
          ...results.entries.map((e) {
            return Row(
              children: [
                Icon(
                  e.value ? Icons.star : Icons.star_border,
                  color: e.value ? Colors.amber : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(_conditionLabel(e.key),
                    style: const TextStyle(fontSize: 14)),
              ],
            );
          }),
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                "+${stage.rewards['gold'] ?? 0} 골드",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.diamond, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 4),
              Text(
                "+${stage.rewards['gem'] ?? 0} 젬",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onClose, child: const Text("닫기")),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("다음 스테이지"),
        ),
      ],
    );
  }

  String _conditionLabel(String key) {
    switch (key) {
      case "1":
        return "노힌트 클리어";
      case "2":
        return "무오답 클리어";
      case "3":
        return "시간 내 클리어";
      default:
        return "보너스 조건";
    }
  }
}