import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<SkinController, SkinItem?>(
      selector: (_, ctrl) => ctrl.selectedChar,
      builder: (context, skin, _) {
        if (skin == null) return const SizedBox.shrink();

        final skinCtrl = context.read<SkinController>();
        final imageUrl = skin.imageUrl;
        final composition = skinCtrl.getComposition(imageUrl);
        final localPath = skinCtrl.getLocalImagePathSync(imageUrl);

        Widget avatar;

        // 1) Composition 캐싱된 경우 (Lottie)
        if (composition != null) {
          avatar = Lottie(
            composition: composition,
            fit: BoxFit.cover,
            repeat: true,
          );
        }
        // 2) 로컬 파일 존재
        else if (localPath != null && File(localPath).existsSync()) {
          if (imageUrl.toLowerCase().contains('.json')) {
            avatar = Lottie.file(
              File(localPath),
              fit: BoxFit.cover,
              repeat: true,
            );
          } else {
            avatar = Image.file(
              File(localPath),
              fit: BoxFit.cover,
            );
          }
        }
        // 3) 네트워크 Lottie
        else if (imageUrl.toLowerCase().endsWith('.json')) {
          avatar = Lottie.network(
            imageUrl,
            fit: BoxFit.cover,
            repeat: true,
          );
        }
        // 4) 네트워크 이미지
        else {
          avatar = CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
          );
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