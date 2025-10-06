import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '미션',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: '가이드',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: '정보',
            ),
          ],
        );
      },
    );
  }
}
