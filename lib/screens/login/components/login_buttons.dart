import 'package:flutter/material.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onGuestPressed;

  const LoginButtons({
    super.key,
    required this.onGooglePressed,
    required this.onGuestPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: onGooglePressed,
              child: Image.asset('assets/images/google_login.png', width: 80, height: 80),
            ),
            const SizedBox(height: 8),
            const Text('Google', style: TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(width: 30),
        Column(
          children: [
            GestureDetector(
              onTap: onGuestPressed,
              child: Image.asset('assets/images/guest_login.png', width: 80, height: 80),
            ),
            const SizedBox(height: 8),
            const Text('Guest', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }
}