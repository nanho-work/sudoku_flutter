import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/audio_controller.dart';
import 'components/login_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AudioController audioController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioController = Provider.of<AudioController>(context, listen: false);
      audioController.startMainBgm();
      _showLoginDialog();
    });
  }

  void _showLoginDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Login Dialog',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const LoginDialog(),
      transitionBuilder: (context, animation1, animation2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          const Center(),
        ],
      ),
    );
  }
}