import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// UserService
/// Firestore의 'users' 컬렉션을 관리.
/// - 유저 생성, 수정, 삭제, 닉네임 관리 포함.
class UserService {
  final _db = FirebaseFirestore.instance;

  // 🔹 [1] 유저 초기화 (최초 로그인 시 데이터 생성)
  Future<UserModel> initializeUserData(User user, {required String loginType}) async {
    debugPrint('🔹 initializeUserData: Start for uid=${user.uid}');
    final docRef = _db.collection('users').doc(user.uid);
    try {
      final snapshot = await docRef.get();
      debugPrint('🔹 initializeUserData: Fetched user snapshot for uid=${user.uid}, exists=${snapshot.exists}');

      if (!snapshot.exists) {
        final newUser = UserModel(
          uid: user.uid,
          nickname: '',
          email: user.email ?? '',
          loginType: loginType,
          gold: 300,
          gems: 10,
          exp: 0,
        );
        await docRef.set(newUser.toMap());
        debugPrint('✅ initializeUserData: Created new user data for uid=${user.uid}');
        return newUser;
      } else {
        final data = snapshot.data()!;
        final updateData = <String, dynamic>{};

        if (!data.containsKey('gold')) updateData['gold'] = 300;
        if (!data.containsKey('gems')) updateData['gems'] = 10;
        if (!data.containsKey('exp')) updateData['exp'] = 0;

        if (updateData.isNotEmpty) {
          await docRef.update(updateData);
          debugPrint('✅ initializeUserData: Updated missing fields for uid=${user.uid}: $updateData');
          final latest = await docRef.get(); // ✅ 최신 스냅샷 반영
          return UserModel.fromMap(latest.data()!);
        }
        debugPrint('✅ initializeUserData: No update needed for uid=${user.uid}');
        return UserModel.fromMap(data);
      }
    } catch (e, st) {
      debugPrint('❌ initializeUserData: Error for uid=${user.uid} - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // 🔹 [2] 유저 정보 수정 및 삭제
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    debugPrint('🔹 updateUserData: Start update for uid=$uid with data=$data');
    try {
      await _db.collection('users').doc(uid).update(data);
      debugPrint('✅ updateUserData: Successfully updated uid=$uid');
    } catch (e, st) {
      debugPrint('❌ updateUserData: Error updating uid=$uid - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<void> deleteUserData(String uid) async {
    debugPrint('🔹 deleteUserData: Start delete for uid=$uid');
    try {
      await _db.collection('users').doc(uid).delete();
      debugPrint('✅ deleteUserData: Successfully deleted uid=$uid');
    } catch (e, st) {
      debugPrint('❌ deleteUserData: Error deleting uid=$uid - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // 🔹 [3] 닉네임 등록 및 변경
  Future<void> updateNickname(String uid, String newNickname) async {
    debugPrint('🔹 updateNickname: Start for uid=$uid with newNickname="$newNickname"');
    final cleanNickname = newNickname.trim();
    try {
      if (cleanNickname.isEmpty) {
        debugPrint('❌ updateNickname: Nickname is empty');
        throw Exception('닉네임을 입력해주세요.');
      }
      if (!RegExp(r'^[a-zA-Z0-9가-힣]{2,12}$').hasMatch(cleanNickname)) {
        debugPrint('❌ updateNickname: Nickname validation failed for "$cleanNickname"');
        throw Exception('닉네임은 2~12자의 한글, 영문, 숫자만 가능합니다.');
      }
      debugPrint('✅ updateNickname: Nickname validated for "$cleanNickname"');

      final lowerNick = cleanNickname.toLowerCase();
      final userRef = _db.collection('users').doc(uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        debugPrint('❌ updateNickname: User info not found for uid=$uid');
        throw Exception('유저 정보가 없습니다.');
      }
      final userData = userSnap.data()!;
      final loginType = userData['loginType'] ?? userData['login_type'];
      if (loginType != 'google') {
        debugPrint('❌ updateNickname: Nickname change not allowed for guest uid=$uid');
        throw Exception('게스트 계정은 닉네임 변경이 불가능합니다.');
      }

      final nickRef = _db.collection('nicknames').doc(lowerNick);
      final oldNickname = (userData['nickname'] ?? '').toString().toLowerCase();

      debugPrint('🔹 updateNickname: Starting transaction for uid=$uid');
      await _db.runTransaction((txn) async {
        final nickDoc = await txn.get(nickRef);
        if (nickDoc.exists) {
          debugPrint('❌ updateNickname: Nickname "$cleanNickname" already in use');
          throw Exception('이미 사용 중인 닉네임입니다.');
        }
        if (oldNickname.isNotEmpty) {
          txn.delete(_db.collection('nicknames').doc(oldNickname));
          debugPrint('🔹 updateNickname: Deleted old nickname doc "$oldNickname"');
        }
        txn.set(nickRef, {'uid': uid});
        txn.update(userRef, {
          'nickname': cleanNickname,
          'nicknameLower': lowerNick,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      debugPrint('✅ updateNickname: Nickname updated successfully for uid=$uid to "$cleanNickname"');
    } catch (e, st) {
      debugPrint('❌ updateNickname: Error for uid=$uid - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // 🔹 [4] 유저 데이터 조회
  Future<UserModel?> getUserModel(String uid) async {
    debugPrint('🔹 getUserModel: Fetching user data for uid=$uid');
    try {
      final snapshot = await _db.collection('users').doc(uid).get();
      if (!snapshot.exists) {
        debugPrint('🔹 getUserModel: No user data found for uid=$uid');
        return null;
      }
      debugPrint('✅ getUserModel: User data fetched for uid=$uid');
      return UserModel.fromMap(snapshot.data()!);
    } catch (e, st) {
      debugPrint('❌ getUserModel: Error fetching user data for uid=$uid - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // 🔹 [5] 닉네임 등록 여부 확인
  Future<bool> isNicknameRegistered(String uid) async {
    debugPrint('🔹 isNicknameRegistered: Checking nickname registration for uid=$uid');
    try {
      final query = await _db.collection('nicknames').where('uid', isEqualTo: uid).limit(1).get();
      final registered = query.docs.isNotEmpty;
      debugPrint('✅ isNicknameRegistered: Nickname registered=$registered for uid=$uid');
      return registered;
    } catch (e, st) {
      debugPrint('❌ isNicknameRegistered: Error checking nickname for uid=$uid - $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // 🔹 [6] 실시간 유저 데이터 구독
  Stream<UserModel?> streamUserModel() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('🔹 streamUserModel: Starting stream for uid=$uid');
    if (uid == null) {
      debugPrint('🔹 streamUserModel: No current user, returning empty stream');
      return const Stream.empty();
    }
    try {
      return _db.collection('users').doc(uid).snapshots().map(
          (doc) {
            if (doc.exists) {
              debugPrint('🔹 streamUserModel: Received user data snapshot for uid=$uid');
              return UserModel.fromMap(doc.data()!);
            } else {
              debugPrint('🔹 streamUserModel: User data snapshot does not exist for uid=$uid');
              return null;
            }
          });
    } catch (e, st) {
      debugPrint('❌ streamUserModel: Error starting stream for uid=$uid - $e');
      debugPrint('$st');
      return const Stream.empty();
    }
  }
}