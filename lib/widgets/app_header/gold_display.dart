import 'package:flutter/material.dart';

class GoldDisplay extends StatelessWidget {
  const GoldDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: Colors.amber, size: 12),
          SizedBox(width: 4),
          Text(
            'Gold: 9999',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}