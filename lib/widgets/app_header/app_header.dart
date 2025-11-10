import 'package:flutter/material.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import 'profile/profile_section.dart';
import 'gold_display.dart';
import 'setting_dialog.dart';
import 'gem_display.dart';
import 'exp_display.dart'; // ✅ 경험치 표시 위젯 추가

/// 앱의 최상단 헤더 (상단 메뉴)
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(top: 6),
      color: Colors.white.withOpacity(0.7),
      child: Row(
        children: [
          const Expanded(flex: 2, child: ProfileSection()),
          const Expanded(flex: 2, child: GoldDisplay()),
          const Expanded(flex: 2, child: GemDisplay()),
          const Expanded(flex: 2, child: ExpDisplay()),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.black54, size: 32),
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Settings",
                    barrierColor: Colors.black54,
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const SettingsDialog(),
                    transitionBuilder: (context, animation, secondaryAnimation, child) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1.0, 0.0), // 오른쪽에서 슬라이드 인
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}