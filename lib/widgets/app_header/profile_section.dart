import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: const [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 14, color: Colors.white),
          ),
          SizedBox(width: 4),
          Text(
            '프로필',
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}