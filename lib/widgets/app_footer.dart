import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        final colors = themeController.colors;
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: colors.background,
          selectedItemColor: colors.bottomItemUnselected,
          unselectedItemColor: colors.cellSelected,
          elevation: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: AppLocalizations.of(context)!.footer_label_mission,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: AppLocalizations.of(context)!.footer_label_guide,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: AppLocalizations.of(context)!.footer_label_info,
            ),
          ],
        );
      },
    );
  }
}
