import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';
import 'profile_skin_dialog.dart';
import 'profile_header.dart';
import 'profile_footer.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SkinController, SkinItem?>(
      selector: (_, ctrl) => ctrl.selectedChar,
      builder: (context, skin, _) {
        if (skin == null) return const SizedBox.shrink();

        final skinCtrl = context.read<SkinController>();
        final composition = skinCtrl.getComposition(skin.imageUrl);
        final localPath = skinCtrl.localImagePathById(skin.id);

        debugPrint('🧩 [SECTION] selectedChar=${skin.id}');
        debugPrint('  - imageUrl: ${skin.imageUrl}');
        if (localPath != null) {
          debugPrint('  - localPath found: $localPath');
        } else {
          debugPrint('  - localPath missing');
        }
        debugPrint('  - hasComposition: ${composition != null}');

        Widget avatar;
        if (composition != null) {
          debugPrint('📦 [SECTION] Using cached composition for ${skin.id}');
          avatar = Lottie(
            composition: composition,
            fit: BoxFit.cover,
            repeat: true,
          );
        } else if (localPath != null && File(localPath).existsSync()) {
          if (skin.imageUrl.toLowerCase().contains('.json')) {
            debugPrint('🟢 [SECTION] Using local Lottie file: $localPath');
            avatar = Lottie.file(
              File(localPath),
              fit: BoxFit.cover,
              repeat: true,
            );
          } else {
            debugPrint('🟢 [SECTION] Using local image file: $localPath');
            avatar = Image.file(
              File(localPath),
              fit: BoxFit.cover,
            );
          }
        } else {
          final isJson = skin.imageUrl.toLowerCase().contains('.json');
          if (isJson) {
            debugPrint(
                '🟡 [SECTION] Using network Lottie: ${skin.imageUrl}');
            avatar = Lottie.network(
              skin.imageUrl,
              fit: BoxFit.cover,
              repeat: true,
            );
          } else {
            debugPrint(
                '🟡 [SECTION] Using network image: ${skin.imageUrl}');
            avatar = CachedNetworkImage(
              imageUrl: skin.imageUrl,
              fit: BoxFit.cover,
            );
          }
        }

        return Container(
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.height * 0.028,
            backgroundColor: Colors.transparent,
            child: ClipOval(child: avatar),
          ),
        );
      },
    );
  }
}