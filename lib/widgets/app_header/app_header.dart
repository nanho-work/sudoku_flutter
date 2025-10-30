import 'package:flutter/material.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import 'profile/profile_section.dart';
import 'gold_display.dart';
import 'setting_dialog.dart';

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
      
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: ProfileSection()),
            const Expanded(child: GoldDisplay()),
            const Expanded(child: SizedBox()), // 빈 섹션
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
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
      ),
    );
  }
}