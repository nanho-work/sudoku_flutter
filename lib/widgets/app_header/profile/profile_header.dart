import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/skin_controller.dart';
import '../../../screens/login/components/nickname_dialog.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    final skin = context.watch<SkinController>().selectedChar;
    final auth = AuthService();

    if (user == null || user.uid.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: skin != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: skin.imageUrl.startsWith('http')
                        ? NetworkImage(skin.imageUrl)
                        : AssetImage(skin.imageUrl) as ImageProvider,
                    backgroundColor: Colors.transparent,
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      user.nickname.isNotEmpty ? user.nickname : '닉네임 미등록',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (_) => NicknameDialog(user: user),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text(
                    user.loginType == 'google' ? 'Google 계정' : '게스트 계정',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (user.loginType == 'guest')
                    IconButton(
                      icon: const Icon(Icons.switch_account),
                      tooltip: 'Google 계정으로 전환',
                      onPressed: () async {
                        final linked = await auth.linkGuestToGoogle();
                        if (linked != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Google 계정으로 전환 완료')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}