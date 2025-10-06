import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/theme_controller.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return Scaffold(
      backgroundColor: colors.background, // 💡 다크 배경색 적용
      appBar: AppBar(
        title: const Text('게임 방법'),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0, // AppBar의 그림자 제거
        foregroundColor: colors.textPrimary, // 뒤로가기 버튼 색상
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GuideCard(
              title: '🎯 게임 목표',
              body: '9x9 스도쿠 판을 완성하는 것이 목표입니다. '
                    '빈 칸을 채울 때는 같은 숫자가 같은 행, 같은 열, '
                    '그리고 3x3 작은 박스 안에 중복되지 않도록 배치해야 합니다. '
                    '모든 칸을 올바르게 채우면 게임이 완료됩니다!',
            ),
            const SizedBox(height: 16),
            // 💡 규칙 설명을 시각화하여 UX 개선
            _GuideCard(
              title: '📘 규칙 설명',
              // body 텍스트 대신 children 위젯을 사용하여 규칙을 아이콘과 함께 표시합니다.
              children: [
                _buildRuleItem(
                  context,
                  icon: Icons.horizontal_rule_rounded,
                  title: '1. 행 규칙',
                  description: '각 가로줄(행)에는 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.',
                  color: colors.textPrimary,
                  tooltip: '행 규칙 아이콘',
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.vertical_align_center_rounded,
                  title: '2. 열 규칙',
                  description: '각 세로줄(열)에도 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.',
                  color: colors.textPrimary,
                  tooltip: '열 규칙 아이콘',
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.grid_on,
                  title: '3. 3x3 박스 규칙',
                  description: '9개의 작은 3x3 박스마다 1부터 9까지 숫자가 중복 없이 배치되어야 합니다.',
                  color: colors.textPrimary,
                  tooltip: '3x3 박스 규칙 아이콘',
                ),
                const SizedBox(height: 16),
                // 💡 규칙을 설명하는 이미지 자리 (Placeholder)
               
              ],
            ),
            const SizedBox(height: 16),
            _GuideCard(
              title: '⚙️ 조작 방법',
              body: '숫자를 입력하려면 빈 칸을 탭한 후 하단 숫자 패드를 사용하세요. '
                    '오류가 있을 경우 자동으로 표시되며, 힌트를 통해 도움을 받을 수 있습니다. '
                    '\n\n길게 눌러 숫자를 지우거나, 스와이프 동작으로 빠르게 이동할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            _GuideCard(
              title: '🚫 오류 표시 안내',
              body: '잘못된 숫자를 입력하면 빨간색으로 표시되어 즉시 알 수 있습니다. '
                    '오류 표시 기능은 설정에서 켜고 끌 수 있습니다. '
                    '\n\n오류가 많을 경우 힌트 사용이 제한될 수 있으니 주의하세요.',
            ),
            const SizedBox(height: 16),
            _GuideCard(
              title: '📊 통계 안내',
              body: '게임 완료 후 통계 화면에서 플레이 시간, 정답률, 힌트 사용 횟수 등을 확인할 수 있습니다. '
                    '통계는 난이도별로 분류되어 자신의 실력을 체계적으로 관리할 수 있습니다.',
            ),
            const SizedBox(height: 16),
            _GuideCard(
              title: '난이도 안내',
              body: '쉬움, 보통, 어려움 난이도로 선택 가능합니다. '
                    '난이도가 높아질수록 초기에 채워진 숫자의 개수가 줄어듭니다.'
                    '\n\n💡 힌트 사용 횟수나 시간 제한은 난이도별로 달라질 수 있습니다.',
            ),
            const SizedBox(height: 16),
            _GuideCard(
              title: '🗓️ 미션 안내',
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
    required String tooltip,
  }) {
    final colors = context.watch<ThemeController>().colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: tooltip,
            child: Icon(icon, color: color, size: 28),
          ),
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
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.left,
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
    final colors = context.watch<ThemeController>().colors;
    return Card(
      // 💡 다크 테마 카드 배경색 적용 및 투명도 조절
      color: colors.card.withOpacity(0.95), 
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colors.textPrimary, // 💡 흰색 텍스트
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            // body가 있으면 body를 표시하거나, children이 있으면 children을 표시
            if (body != null)
              Text(
                body!,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textSecondary, 
                ),
                textAlign: TextAlign.left,
              ),
            if (children != null)
              ...children!, // 💡 children 위젯 리스트를 펼쳐서 표시
          ],
        ),
      ),
    );
  }
}
