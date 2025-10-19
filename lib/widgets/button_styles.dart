import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

// 숫자 패드 전용 스타일
ButtonStyle numberButtonStyle(BuildContext context) {
  final colors = context.watch<ThemeController>().colors;
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(4),
    backgroundColor: colors.primary,
    foregroundColor: colors.textPrimary,
  );
}

// 기능 버튼 전용 스타일
ButtonStyle actionButtonStyle(BuildContext context) {
  final colors = context.watch<ThemeController>().colors;
  return ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(8),
    backgroundColor: colors.secondary,
    foregroundColor: colors.textPrimary,
  );
}