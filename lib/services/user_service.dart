// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<UserModel> initializeUserData(User user, {required String loginType}) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      final newUser = UserModel(
        uid: user.uid,
        nickname: user.displayName ?? '사용자',
        email: user.email ?? '',
        loginType: loginType,
      );
      await docRef.set(newUser.toMap());
      return newUser;
    }

    return UserModel.fromMap(snapshot.data()!);
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUserData(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Future<UserModel?> getUserModel(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    if (!snapshot.exists) return null;
    return UserModel.fromMap(snapshot.data()!);
  }
}