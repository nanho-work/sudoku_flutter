import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/user_model.dart';
import '../../../controllers/skin_controller.dart';
import '../../../services/auth_service.dart';
import '../../../screens/login/components/nickname_dialog.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    final skinCtrl = context.watch<SkinController>();
    final skin = skinCtrl.selectedChar;
    final auth = AuthService();

    if (user == null || user.uid.isEmpty) return const SizedBox.shrink();
    if (skin == null) return const SizedBox.shrink();

    final localPath = skinCtrl.localImagePathById(skin.id);

    Widget avatarWidget;
    if (localPath != null && File(localPath).existsSync()) {
      avatarWidget = skin.imageUrl.contains('.json')
          ? Lottie.file(File(localPath), width: 80, height: 80, repeat: true)
          : Image.file(File(localPath), width: 80, height: 80, fit: BoxFit.cover);
    } else {
      avatarWidget = skin.imageUrl.contains('.json')
          ? Lottie.network(skin.imageUrl, width: 80, height: 80, repeat: true)
          : CachedNetworkImage(imageUrl: skin.imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    }

    return Row(
      children: [
        Expanded(flex: 3, child: Center(child: avatarWidget)),
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
                  Text(user.loginType == 'google' ? 'Google 계정' : '게스트 계정',
                      style: const TextStyle(fontSize: 14)),
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