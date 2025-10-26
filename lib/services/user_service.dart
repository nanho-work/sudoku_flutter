// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// UserService
/// - Firestore의 'users' 컬렉션을 관리.
/// - 유저 생성, 수정, 삭제, 닉네임 중복검사 및 변경 처리 담당.
class UserService {
  final _db = FirebaseFirestore.instance;

  // 🔹 [1] 유저 초기화 (최초 로그인 시 데이터 생성)
  Future<UserModel> initializeUserData(User user, {required String loginType}) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        nickname: '', // 구글 displayName 무시 → 강제로 닉네임 등록 유도
        email: user.email ?? '',
        loginType: loginType,
      );
      await docRef.set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromMap(snapshot.data()!);
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
    // 1️⃣ 입력 검증
    final cleanNickname = newNickname.trim();
    if (cleanNickname.isEmpty) {
      throw Exception('닉네임을 입력해주세요.');
    }

    // 닉네임 형식 제한 (한글, 영문, 숫자만, 2~12자)
    if (!RegExp(r'^[a-zA-Z0-9가-힣]{2,12}$').hasMatch(cleanNickname)) {
      throw Exception('닉네임은 2~12자의 한글, 영문, 숫자만 가능합니다.');
    }

    // 대소문자 통일
    final lowerNick = cleanNickname.toLowerCase();

    // 2️⃣ 유저 정보 조회
    final userRef = _db.collection('users').doc(uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) throw Exception('유저 정보가 없습니다.');
    final userData = userSnap.data()!;
    final loginType = userData['loginType'] ?? userData['login_type'];
    if (loginType != 'google') {
      throw Exception('게스트 계정은 닉네임 변경이 불가능합니다.');
    }

    // 3️⃣ Firestore 트랜잭션 (중복 검사 + 등록 + 기존 닉네임 삭제)
    final nickRef = _db.collection('nicknames').doc(lowerNick);
    final oldNickname = (userData['nickname'] ?? '').toString().toLowerCase();

    await _db.runTransaction((txn) async {
      // 3-1. 중복 닉네임 확인
      final nickDoc = await txn.get(nickRef);
      if (nickDoc.exists) {
        throw Exception('이미 사용 중인 닉네임입니다.');
      }

      // 3-2. 기존 닉네임이 있으면 제거
      if (oldNickname.isNotEmpty) {
        final oldRef = _db.collection('nicknames').doc(oldNickname);
        txn.delete(oldRef);
      }

      // 3-3. 새 닉네임 등록 (uid 매핑)
      txn.set(nickRef, {'uid': uid});

      // 3-4. 유저 문서 업데이트
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
    final query = await _db
        .collection('nicknames')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }
}