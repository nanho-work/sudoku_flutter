import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../main_layout.dart';

class NicknameDialog extends StatefulWidget {
  final UserModel user;
  final bool isInitialSetup;
  const NicknameDialog({super.key, required this.user, this.isInitialSetup = false});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

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
          onPressed: _isSaving
              ? null
              : () async {
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
                    context.read<UserModel>().updateNickname(nickname);
                    if (!mounted) return;
                    Navigator.of(context, rootNavigator: false).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('닉네임 등록이 완료되었습니다')),
                    );
                    if (widget.isInitialSetup) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('닉네임 등록 실패: $e')),
                    );
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
      ],
    );
  }
}