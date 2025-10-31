// lib/screens/login/components/login_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/audio_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../main_layout.dart';
import 'nickname_dialog.dart';
import 'login_buttons.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final AuthService _authService = AuthService();
  bool _isBusy = false;

  Future<void> _showLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Future<void> _hideLoading() async {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isBusy) return;
    _isBusy = true;

    final audio = context.read<AudioController>();
    audio.playSfx('login_touch.mp3');
    await _showLoading();

    try {
      final user = await _authService.signInWithGoogle();
      await _hideLoading();

      if (user == null) return;

      // 로그인 다이얼로그 닫기
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // 닉네임 체크
      final hasNickname = await UserService().isNicknameRegistered(user.uid);
      if (!hasNickname && mounted) {
        final ok = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => NicknameDialog(user: user, isInitialSetup: true),
        );
        if (ok != true) return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } catch (e) {
      await _hideLoading();
      print('❌ Google 로그인 오류: $e');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _handleGuestLogin() async {
    if (_isBusy) return;
    _isBusy = true;

    final audio = context.read<AudioController>();
    audio.playSfx('login_touch.mp3');
    await _showLoading();

    try {
      final user = await _authService.signInAsGuest();
      await _hideLoading();

      if (user == null) return;
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    } catch (e) {
      await _hideLoading();
      print('❌ 게스트 로그인 오류: $e');
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/koofy_logo.png', height: 100),
              const SizedBox(height: 20),
              LoginButtons(
                onGooglePressed: _handleGoogleLogin,
                onGuestPressed: _handleGuestLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}