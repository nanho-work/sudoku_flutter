import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/user_model.dart';
import 'profile_skin_dialog.dart';
import 'profile_header.dart';
import 'profile_footer.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final skinCtrl = context.watch<SkinController>();
    final selectedChar = skinCtrl.selectedChar;
    if (selectedChar == null) return const SizedBox.shrink();

    final localPath = skinCtrl.localImagePathById(selectedChar.id);

    Widget avatarWidget;
    if (localPath != null && File(localPath).existsSync()) {
      avatarWidget = selectedChar.imageUrl.contains('.json')
          ? Lottie.file(File(localPath), fit: BoxFit.cover, repeat: true)
          : Image.file(File(localPath), fit: BoxFit.cover);
    } else {
      avatarWidget = selectedChar.imageUrl.contains('.json')
          ? Lottie.network(selectedChar.imageUrl, fit: BoxFit.cover, repeat: true)
          : CachedNetworkImage(imageUrl: selectedChar.imageUrl, fit: BoxFit.cover);
    }

    return Container(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile_section_title_bg.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileHeader(),
                      SizedBox(height: 16),
                      ProfileSkinDialog(),
                      SizedBox(height: 16),
                      ProfileFooter(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.height * 0.028,
          backgroundColor: Colors.transparent,
          child: ClipOval(child: avatarWidget),
        ),
      ),
    );
  }
}