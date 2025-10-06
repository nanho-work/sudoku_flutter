import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  // 💡 다크 테마 색상 정의
  static const Color darkBackgroundColor = Color(0xFF1E272E); // 스크린 기본 배경
  static const Color cardColor = Color(0xFF37474F); // 카드 배경 (대비용)
  static const Color lightTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  // 💡 수정: Color 대신 MaterialColor 타입인 Colors.cyan 자체를 사용
  static const MaterialColor accentColor = Colors.cyan; // 규칙 강조용 색상

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackgroundColor, // 💡 다크 배경색 적용
      appBar: AppBar(
        title: const Text('게임 방법'),
        centerTitle: true,
        backgroundColor: darkBackgroundColor,
        elevation: 0, // AppBar의 그림자 제거
        foregroundColor: lightTextColor, // 뒤로가기 버튼 색상
        titleTextStyle: const TextStyle(
          color: lightTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _GuideCard(
              title: '게임 목표',
              body: '9x9 스도쿠 판을 완성하는 것이 목표입니다. '
                    '빈 칸을 채울 때는 같은 숫자가 같은 행, 같은 열, '
                    '그리고 3x3 작은 박스 안에 중복되지 않도록 배치해야 합니다. '
                    '모든 칸을 올바르게 채우면 게임이 완료됩니다!',
            ),
            const SizedBox(height: 16),
            // 💡 규칙 설명을 시각화하여 UX 개선
            _GuideCard(
              title: '규칙 설명',
              // body 텍스트 대신 children 위젯을 사용하여 규칙을 아이콘과 함께 표시합니다.
              children: [
                _buildRuleItem(
                  context,
                  icon: Icons.horizontal_rule_rounded,
                  title: '1. 행 규칙',
                  description: '각 가로줄(행)에는 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.',
                  color: accentColor.shade300,
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.vertical_align_center_rounded,
                  title: '2. 열 규칙',
                  description: '각 세로줄(열)에도 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.',
                  color: accentColor.shade400,
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.grid_on,
                  title: '3. 3x3 박스 규칙',
                  description: '9개의 작은 3x3 박스마다 1부터 9까지 숫자가 중복 없이 배치되어야 합니다.',
                  color: accentColor.shade500,
                ),
                const SizedBox(height: 16),
                // 💡 규칙을 설명하는 이미지 자리 (Placeholder)
                const Text(
                  '👉 아래 이미지를 참고하여 규칙을 시각적으로 확인하세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                // 실제 스도쿠 보드 예시 이미지가 들어갈 공간입니다.
                // 현재는 Placeholder를 사용하지만, 실제 앱에서는 규칙을 표시한 이미지를 여기에 넣습니다.
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: darkBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentColor.shade700, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '규칙 설명 예시 이미지 (행, 열, 박스 강조)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _GuideCard(
              title: '난이도 안내',
              body: '쉬움, 보통, 어려움 난이도로 선택 가능합니다. '
                    '난이도가 높아질수록 초기에 채워진 숫자의 개수가 줄어듭니다.'
                    '\n\n💡 힌트 사용 횟수나 시간 제한은 난이도별로 달라질 수 있습니다.',
            ),
            const SizedBox(height: 16),
            const _GuideCard(
              title: '미션 안내',
              body: '일일 미션 달력을 통해 매일 새로운 퍼즐에 도전할 수 있습니다. '
                    '미션을 완료하고 특별한 보상을 받아보세요!'
                    '\n\n🎁 보상: 미션을 완료하면 특별 테마나 프로필 아이콘을 해제할 수 있습니다.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final String title;
  // 기존 body 대신 children을 사용하도록 변경 (body는 그대로 유지 가능)
  final String? body;
  final List<Widget>? children; 

  const _GuideCard({
    Key? key,
    required this.title,
    this.body,
    this.children, // 💡 자식 위젯 리스트를 받을 수 있도록 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // 💡 다크 테마 카드 배경색 적용
      color: GuideScreen.cardColor, 
      elevation: 4, // 그림자 효과를 높여 입체감 강조
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
                color: GuideScreen.lightTextColor, // 💡 흰색 텍스트
              ),
            ),
            const SizedBox(height: 8),
            // body가 있으면 body를 표시하거나, children이 있으면 children을 표시
            if (body != null)
              Text(
                body!,
                style: TextStyle(
                  fontSize: 16,
                  color: GuideScreen.secondaryTextColor, 
                ),
              ),
            if (children != null)
              ...children!, // 💡 children 위젯 리스트를 펼쳐서 표시
          ],
        ),
      ),
    );
  }
}
