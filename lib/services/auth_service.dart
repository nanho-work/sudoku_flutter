// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  String? get currentUid => _auth.currentUser?.uid;

  // =======================================================
  // 🔹 Google 로그인 (일반 로그인 시 빠르게 처리)
  // =======================================================
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      return await _userService.initializeUserData(user, loginType: 'google');
    } catch (e) {
      print('❌ Google 로그인 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 게스트 로그인
  // =======================================================
  Future<UserModel?> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user == null) return null;

      return await _userService.initializeUserData(user, loginType: 'guest');
    } catch (e) {
      print('❌ 게스트 로그인 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 게스트 → 구글 계정 전환 (disconnect 포함)
  // =======================================================
  Future<UserModel?> linkGuestToGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return null;

    try {
      // 1. Get guest UID and its user data
      final guestUid = user.uid;
      final guestUserData = await _userService.getUserModel(guestUid);

      // 2. Disconnect and sign out GoogleSignIn
      final gsi = GoogleSignIn(scopes: ['email', 'profile']);
      try { await gsi.disconnect(); } catch (_) {}
      await gsi.signOut();

      // 3. Sign in with Google
      final googleUser = await gsi.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final newUser = userCredential.user;
      if (newUser == null) return null;

      // 5. Initialize user data for new user
      await _userService.initializeUserData(newUser, loginType: 'google');

      // 6. Merge key data fields from guest user to new user
      if (guestUserData != null) {
        await _userService.updateUserData(newUser.uid, {
          'gold': guestUserData.gold,
          'nickname': newUser.displayName ?? '사용자',
          'email': newUser.email ?? 'unknown@koofy.games',
          'last_login': DateTime.now(),
        });
      }

      // 7. Optionally delete old guest Firestore data
      await _userService.deleteUserData(guestUid);

      // 8. Return migrated UserModel for new user
      return await _userService.getUserModel(newUser.uid);
    } catch (e) {
      print('❌ 게스트 → 구글 연동 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 로그아웃
  // =======================================================
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
    }
  }

  // =======================================================
  // 🔹 회원 탈퇴
  // =======================================================
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _userService.deleteUserData(user.uid);
      await user.delete();
      print('✅ 회원 탈퇴 완료');
    } catch (e) {
      print('❌ 회원 탈퇴 실패: $e');
    }
  }
}