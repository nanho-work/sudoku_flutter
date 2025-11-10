import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';
import '../../../services/skin_purchase_service.dart';
import '../../../services/skin_local_cache.dart';

class ProfileSkinDialog extends StatefulWidget {
  const ProfileSkinDialog({super.key});

  @override
  State<ProfileSkinDialog> createState() => _ProfileSkinDialogState();
}

class _ProfileSkinDialogState extends State<ProfileSkinDialog>
    with AutomaticKeepAliveClientMixin {
  late SkinController skinCtrl;
  late String userId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    skinCtrl = context.read<SkinController>();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final skinCtrl = context.read<SkinController>();

    return Selector<SkinController, SkinState?>(
      selector: (_, ctrl) => ctrl.state,
      builder: (context, state, _) {
        if (state == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final catalog = skinCtrl.catalog;
        final charSkins = catalog.where((e) => e.type == 'char').toList();

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '캐릭터 선택',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _SkinRow(
                  items: charSkins,
                  selectedId: state.selectedCharId,
                  onSelect: (id) => skinCtrl.select(userId, charId: id),
                  isUnlocked: (id) => skinCtrl.isUnlocked(id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkinRow extends StatelessWidget {
  final List<SkinItem> items;
  final String selectedId;
  final Function(String) onSelect;
  final bool Function(String) isUnlocked;

  const _SkinRow({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final skinCtrl = context.read<SkinController>();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildSkinItem(context, skinCtrl, item);
        },
      ),
    );
  }

  Widget _buildSkinItem(
      BuildContext context, SkinController skinCtrl, SkinItem item) {
    final unlocked = isUnlocked(item.id);
    final isSelected = selectedId == item.id;

    final charUrl = item.imageUrl;
    final bgUrl = item.bgUrl ?? '';

    final charPath = skinCtrl.localImagePathById(item.id);
    final bgPath = item.bgUrl != null ? skinCtrl.localBgPathByUrl(item.bgUrl!) : null;

    debugPrint('🧩 [DIALOG][SKIN DEBUG] Item: ${item.id}');
    debugPrint('  - imageUrl: $charUrl');
    debugPrint('  - bgUrl   : $bgUrl');
    debugPrint('  - charPath: $charPath');
    debugPrint('  - bgPath  : $bgPath');

    // BG 위젯
    Widget bgWidget;
    final isJsonBg = bgUrl.toLowerCase().contains('.json');

    if (isJsonBg) {
      final comp = skinCtrl.getComposition(bgUrl);
      if (comp != null) {
        debugPrint('🎞 [DIALOG] BG Lottie(composition): $bgUrl');
        bgWidget = Lottie(composition: comp, fit: BoxFit.fill, repeat: true);
      } else if (bgPath != null && File(bgPath).existsSync()) {
        debugPrint('🟢 [DIALOG] BG Lottie.file(local): $bgPath');
        bgWidget = Lottie.file(
          File(bgPath),
          fit: BoxFit.fill,
          repeat: true,
        );
      } else {
        debugPrint('🟡 [DIALOG] BG Lottie.network: $bgUrl');
        bgWidget = Lottie.network(
          bgUrl,
          fit: BoxFit.fill,
          repeat: true,
        );
      }
    } else {
      if (bgPath != null && File(bgPath).existsSync()) {
        debugPrint('🟢 [DIALOG] BG Image.file(local): $bgPath');
        bgWidget = Image.file(
          File(bgPath),
          fit: BoxFit.fill,
        );
      } else {
        debugPrint('🟡 [DIALOG] BG CachedNetworkImage: $bgUrl');
        bgWidget = CachedNetworkImage(
          imageUrl: bgUrl,
          fit: BoxFit.fill,
        );
      }
    }

    // CHAR 위젯
    Widget charWidget;
    final isJsonChar = charUrl.toLowerCase().contains('.json');

    if (isJsonChar) {
      final comp = skinCtrl.getComposition(charUrl);
      if (comp != null) {
        debugPrint('🎞 [DIALOG][CHAR] Lottie(composition): $charUrl');
        charWidget = Lottie(
          composition: comp,
          fit: BoxFit.cover,
          repeat: true,
        );
      } else if (charPath != null && File(charPath).existsSync()) {
        debugPrint('🟢 [DIALOG][CHAR] Lottie.file(local): $charPath');
        charWidget = Lottie.file(
          File(charPath),
          fit: BoxFit.cover,
          repeat: true,
        );
      } else {
        debugPrint('🟡 [DIALOG][CHAR] Lottie.network: $charUrl');
        charWidget = Lottie.network(
          charUrl,
          fit: BoxFit.cover,
          repeat: true,
        );
      }
    } else {
      if (charPath != null && File(charPath).existsSync()) {
        debugPrint('🟢 [DIALOG][CHAR] Image.file(local): $charPath');
        charWidget = Image.file(
          File(charPath),
          fit: BoxFit.cover,
        );
      } else {
        debugPrint('🟡 [DIALOG][CHAR] CachedNetworkImage: $charUrl');
        charWidget = CachedNetworkImage(
          imageUrl: charUrl,
          fit: BoxFit.cover,
        );
      }
    }

    return GestureDetector(
      onTap: () async {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;

        if (unlocked) {
          onSelect(item.id);
        } else if (item.unlockCost > 0) {
          final result = await SkinPurchaseService.purchaseSkin(
            userId: uid,
            skinId: item.id,
            cost: item.unlockCost,
          );
          if (result == PurchaseResult.success) {
            await context.read<SkinController>().setUnlocked(uid, item.id, true);
            onSelect(item.id);
          }
        }
      },
      child: Stack(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.transparent,
                width: 3,
              ),
            ),
            child: Stack(
              children: [
                bgWidget,
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: charWidget,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!unlocked)
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          if (isSelected)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '착용중',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}