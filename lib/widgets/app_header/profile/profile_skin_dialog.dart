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

class ProfileSkinDialog extends StatelessWidget {
  const ProfileSkinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final skinCtrl = context.watch<SkinController>();
    final catalog = skinCtrl.catalog;
    final state = skinCtrl.state;
    if (state == null) return const Center(child: CircularProgressIndicator());

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
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
            const Text('캐릭터 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    final skinCtrl = context.watch<SkinController>();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final unlocked = isUnlocked(item.id);
          final isSelected = selectedId == item.id;

          final bgPath = skinCtrl.localBgPathById(item.id);
          final charPath = skinCtrl.localImagePathById(item.id);

          Widget bgWidget;
          if (bgPath != null && File(bgPath).existsSync()) {
            bgWidget = item.bgUrl.contains('.json')
                ? Lottie.file(File(bgPath), fit: BoxFit.fill, repeat: true)
                : Image.file(File(bgPath), fit: BoxFit.fill);
          } else {
            bgWidget = item.bgUrl.contains('.json')
                ? Lottie.network(item.bgUrl, fit: BoxFit.fill, repeat: true)
                : CachedNetworkImage(imageUrl: item.bgUrl, fit: BoxFit.fill);
          }

          Widget charWidget;
          if (charPath != null && File(charPath).existsSync()) {
            charWidget = item.imageUrl.contains('.json')
                ? Lottie.file(File(charPath), fit: BoxFit.cover, repeat: true)
                : Image.file(File(charPath), fit: BoxFit.cover);
          } else {
            charWidget = item.imageUrl.contains('.json')
                ? Lottie.network(item.imageUrl, fit: BoxFit.cover, repeat: true)
                : CachedNetworkImage(imageUrl: item.imageUrl, fit: BoxFit.cover);
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
                          child: SizedBox(height: 80, width: double.infinity, child: charWidget),
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
                      child: const Text('착용중',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}