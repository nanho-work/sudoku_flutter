import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/user_model.dart';
import '../../../models/skin_model.dart';
import '../../../controllers/skin_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/skin_local_cache.dart';
import '../../../screens/login/components/nickname_dialog.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    final auth = AuthService();
    if (user == null || user.uid.isEmpty) return const SizedBox.shrink();

    return Selector<SkinController, SkinItem?>(
      selector: (_, ctrl) => ctrl.selectedChar,
      builder: (context, skin, _) {
        if (skin == null) return const SizedBox.shrink();
        final skinCtrl = context.read<SkinController>();
        final composition = skinCtrl.getComposition(skin.imageUrl);
        final cachedPath = skinCtrl.localImagePathById(skin.id);

        debugPrint('🧩 [HEADER] selectedChar=${skin.id}');
        debugPrint('  - imageUrl: ${skin.imageUrl}');
        debugPrint('  - cachedPath: $cachedPath');
        debugPrint('  - hasComposition: ${composition != null}');

        Widget avatar;
        if (composition != null) {
          debugPrint('📦 [HEADER] Using cached composition for ${skin.id}');
          avatar = Lottie(
            composition: composition,
            width: 80,
            height: 80,
            repeat: true,
          );
        } else if (cachedPath != null && File(cachedPath).existsSync()) {
          if (skin.imageUrl.toLowerCase().contains('.json')) {
            debugPrint('🟢 [HEADER] Using local Lottie file: $cachedPath');
            avatar = Lottie.file(
              File(cachedPath),
              width: 80,
              height: 80,
              repeat: true,
            );
          } else {
            debugPrint('🟢 [HEADER] Using local image file: $cachedPath');
            avatar = Image.file(
              File(cachedPath),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            );
          }
        } else {
          final isJson = skin.imageUrl.toLowerCase().contains('.json');
          if (isJson) {
            debugPrint('🟡 [HEADER] Using network Lottie: ${skin.imageUrl}');
            avatar = Lottie.network(
              skin.imageUrl,
              width: 80,
              height: 80,
              repeat: true,
            );
          } else {
            debugPrint('🟡 [HEADER] Using network image: ${skin.imageUrl}');
            avatar = CachedNetworkImage(
              imageUrl: skin.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            );
          }
        }

        return Row(
          children: [
            Expanded(flex: 3, child: Center(child: avatar)),
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.nickname.isNotEmpty
                              ? user.nickname
                              : '닉네임 미등록',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                        user.loginType == 'google'
                            ? 'Google 계정'
                            : '게스트 계정',
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
                                const SnackBar(
                                  content: Text('Google 계정으로 전환 완료'),
                                ),
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
      },
    );
  }
}