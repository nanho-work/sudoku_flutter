import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controllers/skin_controller.dart';
import '../../../models/skin_model.dart';
import '../../../services/skin_purchase_service.dart';
import 'skin_card.dart';

class SkinList extends StatelessWidget {
  const SkinList({super.key});

  @override
  Widget build(BuildContext context) {
    final skinCtrl = context.watch<SkinController>();
    final state = skinCtrl.state;
    if (state == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final catalog = skinCtrl.catalog;
    final owned = catalog.where((e) => skinCtrl.isUnlocked(e.id)).toList();
    final unowned = catalog.where((e) => !skinCtrl.isUnlocked(e.id)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '보유중',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          _buildGrid(context, skinCtrl, owned, state.selectedCharId),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '미보유',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          _buildGrid(context, skinCtrl, unowned, state.selectedCharId),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, SkinController ctrl, List<SkinItem> list, String selectedId) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 100 / 140,
      ),
      itemBuilder: (_, i) {
        final item = list[i];
        final unlocked = ctrl.isUnlocked(item.id);
        final selected = selectedId == item.id;
        return SkinCard(
          skinCtrl: ctrl,
          item: item,
          unlocked: unlocked,
          isSelected: selected,
          onTap: () async {
            final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

            // 보유 스킨 → 착용 전 확인 다이얼로그
            if (unlocked) {
              final confirmed = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text("착용하시겠습니까?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("아니오"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("예"),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ctrl.select(uid, charId: item.id);

                // 착용 완료 안내 팝업
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    title: const Text("착용되었습니다"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
              }
              return;
            }

            // 미보유 + 비용 있음 → 구매 시도 (확인 후 구매, 자동 착용 없음)
            if (item.unlockCost > 0) {
              // 1차 확인: 구매 여부
              final confirmPurchase = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => AlertDialog(
                  title: const Text("구매하시겠습니까?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("아니오"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("예"),
                    ),
                  ],
                ),
              );

              if (confirmPurchase != true) {
                return;
              }

              final result = await SkinPurchaseService.purchaseSkin(
                userId: uid,
                skinId: item.id,
                cost: item.unlockCost,
              );

              if (result == PurchaseResult.success) {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    title: const Text("구매가 완료되었습니다"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}