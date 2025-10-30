import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/skin_controller.dart';
import 'profile_skin_dialog.dart'; // 다이얼로그 import

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final skinController = context.watch<SkinController>();
    final selectedChar = skinController.selectedChar;

    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ProfileSkinDialog(),
              );
            },
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.height * 0.028, // 화면 높이의 3%
              backgroundColor: Colors.grey.shade300,
              child: selectedChar != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: selectedChar.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}