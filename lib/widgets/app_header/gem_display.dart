import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';

class GemDisplay extends StatelessWidget {
  const GemDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserModel?>();
    final gems = userModel?.gems ?? 0;

    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/gem.png', // 💎 젬 아이콘 이미지 추가 필요
              height: 28,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 7,
            child: Text(
              '$gems',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}