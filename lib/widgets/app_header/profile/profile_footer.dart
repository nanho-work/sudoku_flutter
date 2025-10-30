import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../screens/login/components/login_dialog.dart';

/// 프로필 하단부 - 로그아웃 / 회원탈퇴 버튼
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    Future<void> _confirmAndExecute({
      required String title,
      required String message,
      required Future<void> Function() onConfirm,
    }) async {
      final confirmed = await showDialog<bool>(
        context: context,
        useRootNavigator: false,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await onConfirm();
        if (!context.mounted) return;
        Future.microtask(() {
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
            // ✅ 로그인 다이얼로그 호출 추가
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => LoginDialog(),
            );
          }
        });
      }
    }

    return Column(
      children: [
        const Divider(height: 32, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              onPressed: () => _confirmAndExecute(
                title: '로그아웃',
                message: '정말 로그아웃 하시겠습니까?',
                onConfirm: () async {
                  await auth.signOut();
                },
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade800,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text('회원탈퇴'),
              onPressed: () => _confirmAndExecute(
                title: '회원탈퇴',
                message: '계정을 완전히 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
                onConfirm: () async {
                  await auth.deleteAccount();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}