import 'package:flutter/material.dart';
import '../../../controllers/stage_controller.dart';

/// 🎮 StageButtonBar
/// 힌트 / 저장 / 되돌리기 등 기능 버튼
class StageButtonBar extends StatelessWidget {
  final StageController controller;

  const StageButtonBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(Icons.lightbulb_outline, "힌트", controller.useHint),
          _buildButton(Icons.save_alt, "저장", controller.saveProgress),
          _buildButton(Icons.restart_alt, "초기화", () {
            controller.stopTimer();
            controller
              ..elapsed = Duration.zero
              ..hintsUsed = 0
              ..wrongAttempts = 0
              ..cleared = false;
            controller.notifyListeners();
          }),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black12),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 14)),
    );
  }
}