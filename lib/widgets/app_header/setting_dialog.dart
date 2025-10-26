import 'package:flutter/material.dart';
import 'package:sudoku_flutter/widgets/sound_settings.dart';
import 'package:sudoku_flutter/widgets/theme_selector.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5DC), // 🔹 베이지톤 배경색으로 변경
          borderRadius: BorderRadius.zero,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '설정',
                style: TextStyle(color: Colors.black87, fontSize: 16), // 어두운 텍스트로 조정
              ),
              const SizedBox(height: 16),

              // --- 테마 변경 ---
              const Text('• 테마 변경', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              const ThemeSelectorWidget(),
              const SizedBox(height: 20),

              // --- 사운드 조절 ---
              const Text('• 사운드 조절', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              const SoundSettingsWidget(),
              const SizedBox(height: 20),

              // --- 계정 관련 ---
              const Text('• 계정', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그아웃 기능 준비 중')),
                  );
                },
                child: const Text('로그아웃', style: TextStyle(color: Colors.redAccent)),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('탈퇴 기능 준비 중')),
                  );
                },
                child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent)),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('닫기', style: TextStyle(color: Colors.black87)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}