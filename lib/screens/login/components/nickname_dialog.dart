import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class NicknameDialog extends StatefulWidget {
  final UserModel user;
  final bool isInitialSetup; // 최초 로그인 온보딩 시 true
  const NicknameDialog({super.key, required this.user, this.isInitialSetup = false});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _save() async {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await UserService().updateNickname(widget.user.uid, nickname);

      // ChangeNotifier 적용된 UserModel이면 즉시 반영
      try {
        final maybeUser = context.read<UserModel?>();
        if (maybeUser != null) {
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          if (maybeUser.nickname != nickname) {
            // UserModel이 ChangeNotifier가 아니라면 이 부분은 무시됨
            // 사용 중인 구현에서 updateNickname(nickname) 메서드가 있으면 호출
            // (방어적 반영)
            // (없어도 Firestore stream으로 곧 반영됨)
            // @ts-ignore-like
          }
        }
      } catch (_) {}

      if (!mounted) return;
      // 성공 플래그 true 반환. 외부에서 전환 여부 결정
      Navigator.of(context, rootNavigator: true).pop(true);

      // 온보딩에서 메인으로 자동 전환이 필요하면 외부에서 처리.
      // 여기서는 화면 전환을 하지 않아 경합을 차단.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임 등록 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('닉네임 등록'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '닉네임을 입력하세요',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('저장'),
        ),
      ],
    );
  }
}