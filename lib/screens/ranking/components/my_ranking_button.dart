import 'package:flutter/material.dart';

class MyRankingButton extends StatelessWidget {
  const MyRankingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.person),
        label: const Text('내 랭킹 보기'),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('내 랭킹 조회 기능 준비 중')),
          );
        },
      ),
    );
  }
}