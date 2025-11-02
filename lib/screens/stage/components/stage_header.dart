import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/stage_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../l10n/app_localizations.dart';

/// 🧩 StageHeader (리뉴얼)
/// 스테이지 이름, 경과 시간, 힌트/오답 현황, 뒤로가기 버튼 포함
class StageHeader extends StatelessWidget {
  final StageController controller;
  const StageHeader({super.key, required this.controller});

  double _calculateHorizontalPadding(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double maxGameWidth = 600.0;
    const double kBoardHorizontalPadding = 20.0;
    if (screenWidth > maxGameWidth) {
      final double externalPadding = (screenWidth - maxGameWidth) / 2;
      return externalPadding + kBoardHorizontalPadding;
    }
    return kBoardHorizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final loc = AppLocalizations.of(context)!;
    final elapsed = controller.elapsedSeconds;
    final timeLimit = controller.stage.rewards['time_limit'];
    final remain = (timeLimit != null && timeLimit > 0)
        ? (timeLimit - elapsed).clamp(0, timeLimit)
        : null;

    final double width = MediaQuery.of(context).size.width;
    final double scale = (width / 400).clamp(0.8, 1.2);
    final double iconSize = 18 * scale;
    final double fontSize = 14 * scale;
    final double paddingH = 16 * scale;
    final double paddingV = 6 * scale;

    final textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: colors.textMain,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 좌측: 뒤로가기 + 스테이지 이름
          Expanded(
            flex: 3,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      size: iconSize, color: Colors.black87),
                  onPressed: () => _showExitDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      controller.stage.name,
                      style: TextStyle(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: colors.textMain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 중앙: 힌트 / 오답
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb_outline,
                    size: iconSize, color: Colors.orange),
                SizedBox(width: 2 * scale),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("힌트: ${controller.hintsUsed}",
                        style: textStyle, overflow: TextOverflow.ellipsis),
                  ),
                ),
                SizedBox(width: 8 * scale),
                Icon(Icons.close, size: iconSize, color: Colors.redAccent),
                SizedBox(width: 2 * scale),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text("오답: ${controller.wrongAttempts}",
                        style: textStyle, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 우측: 타이머
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  remain != null ? "⏱ ${remain}s" : "⏱ ${elapsed}s",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: controller.timeOver ? Colors.red : colors.textMain,
                    fontWeight:
                        controller.timeOver ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(loc.dialog_confirm_exit_title),
          content: Text(loc.dialog_confirm_exit_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text(loc.exit),
            ),
          ],
        );
      },
    );
  }
}