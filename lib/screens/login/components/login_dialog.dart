import 'package:flutter/material.dart';
import '../../../controllers/audio_controller.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../main_layout.dart';
import 'nickname_dialog.dart';
import 'login_buttons.dart';
import 'package:provider/provider.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final audio = Provider.of<AudioController>(context, listen: false);
    audio.playSfx('login_touch.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final user = await _authService.signInWithGoogle();
    Navigator.of(context, rootNavigator: true).pop(); // close loading

    if (user != null) {
      Navigator.of(context, rootNavigator: true).pop(); // close login dialog

      final hasNickname = await UserService().isNicknameRegistered(user.uid);
      if (!hasNickname) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => NicknameDialog(user: user),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
    }
  }

  Future<void> _handleGuestLogin(BuildContext context) async {
    final audio = Provider.of<AudioController>(context, listen: false);
    audio.playSfx('login_touch.mp3');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final user = await _authService.signInAsGuest();
    Navigator.of(context, rootNavigator: true).pop(); // close loading

    if (user != null) {
      Navigator.of(context, rootNavigator: true).pop(); // close login dialog
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/koofy_logo.png', height: 100),
                const SizedBox(height: 20),
                LoginButtons(
                  onGooglePressed: () => _handleGoogleLogin(context),
                  onGuestPressed: () => _handleGuestLogin(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}