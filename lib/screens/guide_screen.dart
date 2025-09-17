


import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게임 방법'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _GuideCard(
              title: '게임 목표',
              body: '9x9 스도쿠 판을 완성하는 것이 목표입니다. '
                    '빈 칸을 채울 때는 같은 숫자가 같은 행, 같은 열, '
                    '그리고 3x3 작은 박스 안에 중복되지 않도록 배치해야 합니다. '
                    '모든 칸을 올바르게 채우면 게임이 완료됩니다!',
            ),
            SizedBox(height: 16),
            _GuideCard(
              title: '규칙 설명',
              body: '스도쿠의 핵심 규칙은 세 가지입니다.\n'
                    '1. 행 규칙: 각 가로줄(행)에는 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.\n'
                    '2. 열 규칙: 각 세로줄(열)에도 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.\n'
                    '3. 3x3 박스 규칙: 9개의 작은 3x3 박스마다 1부터 9까지 숫자가 중복 없이 배치되어야 합니다.\n\n'
                    '이 세 가지 규칙을 동시에 만족시키며 모든 칸을 채워야 퍼즐이 완성됩니다.',
            ),
            SizedBox(height: 16),
            _GuideCard(
              title: '난이도 안내',
              body: '쉬움, 보통, 어려움 난이도로 선택 가능합니다.',
            ),
            SizedBox(height: 16),
            _GuideCard(
              title: '미션 안내',
              body: '일일 미션 달력을 통해 매일 도전할 수 있습니다.',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  final String body;
  const _GuideCard({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}