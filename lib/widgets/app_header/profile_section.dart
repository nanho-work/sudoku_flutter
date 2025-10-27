import 'package:flutter/material.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/profile_bg.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가로 가운데 정렬
            children: const [
            CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}