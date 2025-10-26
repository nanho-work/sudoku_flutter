import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final current = themeController.currentTheme;

    final themes = {
      'light': Colors.amber[100],
      'dark': Colors.grey[850],
      'pink': Colors.pink[200],
    };

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: themes.entries.map((entry) {
        final theme = entry.key;
        final color = entry.value!;
        final isSelected = theme == current;

        return GestureDetector(
          onTap: () => themeController.setTheme(theme),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade400,
                width: isSelected ? 3 : 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.black)
                : null,
          ),
        );
      }).toList(),
    );
  }
}