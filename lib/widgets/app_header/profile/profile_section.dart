import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/user_model.dart';
import 'profile_skin_dialog.dart'; // 다이얼로그 import
import 'profile_header.dart';
import 'profile_footer.dart';

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
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: Colors.transparent, // ✅ 완전 투명으로 설정
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/profile_section_title_bg.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(                     
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfileHeader(user: context.read<UserModel>()),
                            const SizedBox(height: 16),
                            const ProfileSkinDialog(),
                            const SizedBox(height: 16),
                            const ProfileFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.height * 0.028, // 화면 높이의 3%
                backgroundColor: Colors.transparent,
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
          ),
        ],
      ),
    );
  }
}