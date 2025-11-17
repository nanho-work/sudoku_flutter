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
            // 이미 보유 → 착용
            if (unlocked) {
              ctrl.select(uid, charId: item.id);
              return;
            }

            // 미보유 + 비용 있음 → 구매 시도
            if (item.unlockCost > 0) {
              final result = await SkinPurchaseService.purchaseSkin(
                userId: uid,
                skinId: item.id,
                cost: item.unlockCost,
              );

              if (result == PurchaseResult.success) {
                await ctrl.setUnlocked(uid, item.id, true);
                ctrl.select(uid, charId: item.id);
              }
            }
          },
        );
      },
    );
  }
}