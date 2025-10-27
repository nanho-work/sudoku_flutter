import 'package:flutter/material.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import 'profile_section.dart';
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header_line.png'),
          fit: BoxFit.cover,
        ),
      ),
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
                    showDialog(
                      context: context,
                      builder: (_) => const SettingsDialog(),
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