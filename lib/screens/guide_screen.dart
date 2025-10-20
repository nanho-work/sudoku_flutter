import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import '../controllers/theme_controller.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final loc = AppLocalizations.of(context)!; // 🌐 다국어 객체

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GuideCard(
              title: loc.guide_title_goal,
              body: "${loc.guide_desc_goal_1} ${loc.guide_desc_goal_2} ${loc.guide_desc_goal_3}",
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_rules,
              children: [
                _buildRuleItem(
                  context,
                  icon: Icons.horizontal_rule_rounded,
                  title: loc.guide_rule_row_title,
                  description: loc.guide_rule_row_desc,
                  color: colors.textMain,
                  tooltip: loc.guide_rule_row_title,
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.vertical_align_center_rounded,
                  title: loc.guide_rule_col_title,
                  description: loc.guide_rule_col_desc,
                  color: colors.textMain,
                  tooltip: loc.guide_rule_col_title,
                ),
                _buildRuleItem(
                  context,
                  icon: Icons.grid_on,
                  title: loc.guide_rule_box_title,
                  description: loc.guide_rule_box_desc,
                  color: colors.textMain,
                  tooltip: loc.guide_rule_box_title,
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_control,
              body:
                  "${loc.guide_desc_control_1} ${loc.guide_desc_control_2}\n\n${loc.guide_desc_control_3}",
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_error,
              body:
                  "${loc.guide_desc_error_1} ${loc.guide_desc_error_2}\n\n${loc.guide_desc_error_3}",
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_stats,
              body: "${loc.guide_desc_stats_1} ${loc.guide_desc_stats_2}",
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_difficulty,
              body:
                  "${loc.guide_desc_difficulty_1} ${loc.guide_desc_difficulty_2}\n\n${loc.guide_desc_difficulty_3}",
            ),
            const SizedBox(height: 16),

            _GuideCard(
              title: loc.guide_title_mission,
              body:
                  "${loc.guide_desc_mission_1} ${loc.guide_desc_mission_2}\n\n${loc.guide_desc_mission_3}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(
    BuildContext context, {
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
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textSub,
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
  final String? body;
  final List<Widget>? children;

  const _GuideCard({
    Key? key,
    required this.title,
    this.body,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return Card(
      color: colors.card.withOpacity(0.95),
      elevation: 4,
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
                color: colors.textMain,
              ),
            ),
            const SizedBox(height: 8),
            if (body != null)
              Text(
                body!,
                style: TextStyle(
                  fontSize: 16,
                  color: colors.textSub,
                ),
              ),
            if (children != null) ...children!,
          ],
        ),
      ),
    );
  }
}