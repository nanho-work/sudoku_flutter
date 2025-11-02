import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// UserService
/// Firestore의 'users' 컬렉션을 관리.
/// - 유저 생성, 수정, 삭제, 닉네임 관리 포함.
class UserService {
  final _db = FirebaseFirestore.instance;

  // 🔹 [1] 유저 초기화 (최초 로그인 시 데이터 생성)
  Future<UserModel> initializeUserData(User user, {required String loginType}) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

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
      return newUser;
    } else {
      final data = snapshot.data()!;
      final updateData = <String, dynamic>{};

      if (!data.containsKey('gold')) updateData['gold'] = 300;
      if (!data.containsKey('gems')) updateData['gems'] = 10;
      if (!data.containsKey('exp')) updateData['exp'] = 0;

      if (updateData.isNotEmpty) {
        await docRef.update(updateData);
        final latest = await docRef.get(); // ✅ 최신 스냅샷 반영
        return UserModel.fromMap(latest.data()!);
      }
      return UserModel.fromMap(data);
    }
  }

  // 🔹 [2] 유저 정보 수정 및 삭제
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // 🔹 [3] 닉네임 등록 및 변경
  Future<void> updateNickname(String uid, String newNickname) async {
    final cleanNickname = newNickname.trim();
    if (cleanNickname.isEmpty) throw Exception('닉네임을 입력해주세요.');
    if (!RegExp(r'^[a-zA-Z0-9가-힣]{2,12}$').hasMatch(cleanNickname)) {
      throw Exception('닉네임은 2~12자의 한글, 영문, 숫자만 가능합니다.');
    }

    final lowerNick = cleanNickname.toLowerCase();
    final userRef = _db.collection('users').doc(uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) throw Exception('유저 정보가 없습니다.');
    final userData = userSnap.data()!;
    final loginType = userData['loginType'] ?? userData['login_type'];
    if (loginType != 'google') {
      throw Exception('게스트 계정은 닉네임 변경이 불가능합니다.');
    }

    final nickRef = _db.collection('nicknames').doc(lowerNick);
    final oldNickname = (userData['nickname'] ?? '').toString().toLowerCase();

    await _db.runTransaction((txn) async {
      final nickDoc = await txn.get(nickRef);
      if (nickDoc.exists) throw Exception('이미 사용 중인 닉네임입니다.');
      if (oldNickname.isNotEmpty) txn.delete(_db.collection('nicknames').doc(oldNickname));
      txn.set(nickRef, {'uid': uid});
      txn.update(userRef, {
        'nickname': cleanNickname,
        'nicknameLower': lowerNick,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // 🔹 [4] 유저 데이터 조회
  Future<UserModel?> getUserModel(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(snapshot.data()!);
  }

  // 🔹 [5] 닉네임 등록 여부 확인
  Future<bool> isNicknameRegistered(String uid) async {
    final query = await _db.collection('nicknames').where('uid', isEqualTo: uid).limit(1).get();
    return query.docs.isNotEmpty;
  }

  // 🔹 [6] 실시간 유저 데이터 구독
  Stream<UserModel?> streamUserModel() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.collection('users').doc(uid).snapshots().map(
        (doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }
}