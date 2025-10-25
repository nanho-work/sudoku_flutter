import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

// 숫자 패드 전용 스타일
ButtonStyle buttonStyle(BuildContext context) {
  final colors = context.watch<ThemeController>().colors;
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(2),
    backgroundColor: colors.buttonBackground,
    foregroundColor: colors.buttonText,
  );
}
