import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';

class GoldDisplay extends StatelessWidget {
  const GoldDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<UserModel?>();
    final gold = userModel?.gold ?? 0;

    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              'assets/images/gold.png',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 7,
            child: Text(
              '$gold',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}