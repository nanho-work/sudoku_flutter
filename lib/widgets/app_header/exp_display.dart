import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';

/// 🔹 사용자 경험치 표시 (누적형)
class ExpDisplay extends StatelessWidget {
  const ExpDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserModel?>();
    final exp = userModel?.exp ?? 0;

    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/point.png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              '$exp',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}