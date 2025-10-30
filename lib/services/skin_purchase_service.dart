import 'package:cloud_firestore/cloud_firestore.dart';

enum PurchaseResult { success, insufficientFunds, alreadyOwned, error }

class SkinPurchaseService {
  static Future<PurchaseResult> purchaseSkin({
    required String userId,
    required String skinId,
    required int cost,
  }) async {
    final db = FirebaseFirestore.instance;

    final userRef = db.collection('users').doc(userId);
    final stateRef =
        db.collection('users').doc(userId).collection('skins_state').doc('state');

    PurchaseResult result = PurchaseResult.error;

    try {
      await db.runTransaction((txn) async {
        // 🔹 1. 유저 정보 조회
        final userSnap = await txn.get(userRef);
        if (!userSnap.exists) throw Exception('User not found');
        final gold = ((userSnap.data()?['gold'] ?? 0) as num).toInt();

        // 🔹 2. 스킨 상태 조회
        final stateSnap = await txn.get(stateRef);
        if (!stateSnap.exists) throw Exception('skins_state/state not initialized');
        final data = stateSnap.data()!;
        final List unlocked = (data['unlockedIds'] ?? []) as List;

        // 🔹 3. 이미 소유한 스킨인지 확인
        if (unlocked.contains(skinId)) {
          result = PurchaseResult.alreadyOwned;
          throw Exception('already owned');
        }

        // 🔹 4. 잔액 확인
        if (gold < cost) {
          result = PurchaseResult.insufficientFunds;
          throw Exception('insufficient funds');
        }

        // 🔹 5. 골드 차감 및 스킨 언락 업데이트
        txn.update(userRef, {'gold': FieldValue.increment(-cost)});
        txn.update(stateRef, {
          'unlockedIds': FieldValue.arrayUnion([skinId]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        result = PurchaseResult.success;
      });
    } catch (e) {
      print('❌ purchaseSkin transaction error: $e');
    } finally {
      // 🔹 6. 구매 로그 기록
      await userRef.collection('purchase_logs').add({
        'skinId': skinId,
        'cost': cost,
        'status': result.name,
        'ts': FieldValue.serverTimestamp(),
      });
    }

    return result;
  }
}