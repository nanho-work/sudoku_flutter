import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';
import '../../../services/skin_purchase_service.dart';
import 'dart:async';

class ProfileSkinDialog extends StatelessWidget {
  const ProfileSkinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final skinCtrl = context.watch<SkinController>();
    final catalog = skinCtrl.catalog;
    final state = skinCtrl.state;

    // 캐시 즉시 로드 구조이므로 로딩 스피너 제거 가능
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
            const Text('캐릭터 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(message,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), entry.remove);
  }

  @override
  Widget build(BuildContext context) {
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

          return GestureDetector(
            onTap: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                _showToast(context, '로그인 후 이용 가능합니다.');
                return;
              }

              if (unlocked) {
                onSelect(item.id);
              } else if (item.unlockCost > 0) {
                final result = await SkinPurchaseService.purchaseSkin(
                  userId: uid,
                  skinId: item.id,
                  cost: item.unlockCost,
                );

                switch (result) {
                  case PurchaseResult.success:
                    _showToast(context, '스킨이 구매되었습니다.');
                    await context.read<SkinController>().setUnlocked(uid, item.id, true);
                    unawaited(context.read<SkinController>().loadAll(uid));
                    onSelect(item.id);
                    break;
                  case PurchaseResult.insufficientFunds:
                    _showToast(context, '골드가 부족합니다.');
                    break;
                  case PurchaseResult.alreadyOwned:
                    _showToast(context, '이미 소유 중인 스킨입니다.');
                    break;
                  case PurchaseResult.error:
                    _showToast(context, '구매 중 오류가 발생했습니다.');
                    break;
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
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(item.bgUrl),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(item.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!unlocked &&
                    item.unlockCost > 0 &&
                    item.unlockType != 'default')
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.unlockCost} 골드',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
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