import 'package:cloud_firestore/cloud_firestore.dart';

class GoldService {
  static final _db = FirebaseFirestore.instance;

  /// 🔹 골드 추가
  static Future<bool> addGold(String uid, int amount, {String reason = 'reward'}) async {
    if (amount <= 0) {
      print('⚠️ addGold aborted: amount must be positive');
      return false;
    }

    final ref = _db.collection('users').doc(uid);

    try {
      await _db.runTransaction<void>((txn) async {
        final snap = await txn.get(ref);
        if (!snap.exists) throw Exception('User not found');
        final current = ((snap.data()?['gold'] ?? 0) as num).toInt();
        txn.update(ref, {'gold': current + amount});
      });

      await ref.collection('gold_logs').add({
        'amount': amount,
        'type': reason,
        'ts': FieldValue.serverTimestamp(),
        'status': 'success',
      });

      return true;
    } catch (e) {
      print('❌ addGold error: $e');
      await ref.collection('gold_logs').add({
        'amount': amount,
        'type': reason,
        'ts': FieldValue.serverTimestamp(),
        'status': 'error',
        'error': e.toString(),
      });
      return false;
    }
  }

  /// 🔹 골드 차감 (잔액 부족 시 false 반환)
  static Future<bool> deductGold(String uid, int amount, {String reason = 'purchase'}) async {
    if (amount <= 0) {
      print('⚠️ deductGold aborted: amount must be positive');
      return false;
    }

    final ref = _db.collection('users').doc(uid);

    try {
      bool success = await _db.runTransaction<bool>((txn) async {
        final snap = await txn.get(ref);
        if (!snap.exists) throw Exception('User not found');
        final current = ((snap.data()?['gold'] ?? 0) as num).toInt();
        if (current < amount) return false;

        txn.update(ref, {'gold': current - amount});
        return true;
      });

      await ref.collection('gold_logs').add({
        'amount': -amount,
        'type': reason,
        'ts': FieldValue.serverTimestamp(),
        'status': success ? 'success' : 'insufficient_funds',
      });

      return success;
    } catch (e) {
      print('❌ deductGold error: $e');
      await ref.collection('gold_logs').add({
        'amount': -amount,
        'type': reason,
        'ts': FieldValue.serverTimestamp(),
        'status': 'error',
        'error': e.toString(),
      });
      return false;
    }
  }
}
