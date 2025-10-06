import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_flutter/screens/game/game_screen.dart';
import 'package:sudoku_flutter/l10n/app_localizations.dart';
import '../controllers/theme_controller.dart';
import '../services/mission_service.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _reload = 0;

  /// 💡 현재 표시 중인 연도/월을 저장 (초기값은 로컬 기기의 현재 날짜)
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime.now();
  }

  Future<void> _startGame(String difficulty, DateTime missionDate) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty, missionDate: missionDate),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _reload++;
    });
  }

  /// 💡 이전달 / 다음달 이동
  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset, 1);
    });
  }

  Widget _buildLegend(BuildContext context, colors) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.card.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(loc.mission_legend_available, style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.success.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.yellow,
                size: 16,
                shadows: [
                  Shadow(blurRadius: 2.0, color: Colors.black45, offset: Offset(1.0, 1.0))
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(loc.mission_legend_cleared, style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.card.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(loc.mission_legend_unreleased, style: TextStyle(color: colors.textPrimary)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    final now = DateTime.now();

    final year = _visibleMonth.year;
    final month = _visibleMonth.month;
    final today = now.day;

    int daysInMonth(int year, int month) {
      final beginningNextMonth =
          (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
      return beginningNextMonth.subtract(const Duration(days: 1)).day;
    }

    final totalDays = daysInMonth(year, month);
    final firstDayWeekday = DateTime(year, month, 1).weekday;
    final startPadding = (firstDayWeekday == 7) ? 0 : firstDayWeekday;
    final weekdayLabels = [
      AppLocalizations.of(context)!.mission_weekday_sun,
      AppLocalizations.of(context)!.mission_weekday_mon,
      AppLocalizations.of(context)!.mission_weekday_tue,
      AppLocalizations.of(context)!.mission_weekday_wed,
      AppLocalizations.of(context)!.mission_weekday_thu,
      AppLocalizations.of(context)!.mission_weekday_fri,
      AppLocalizations.of(context)!.mission_weekday_sat,
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _changeMonth(-1),
              icon: Icon(Icons.chevron_left, color: colors.textPrimary),
            ),
            Text(
              AppLocalizations.of(context)!
                  .mission_app_bar_month_format(month.toString(), year.toString()),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () => _changeMonth(1),
              icon: Icon(Icons.chevron_right, color: colors.textPrimary),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: colors.appBar,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  color: colors.appBar,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white10, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<DateTime>>(
                      key: ValueKey(
                          'mission_reload_${_reload}_${_visibleMonth.year}_${_visibleMonth.month}'),
                      future: MissionService.getClearedDatesInMonth(
                          DateTime(year, month)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                color: colors.accent,
                              ),
                            ),
                          );
                        }

                        final clearedDates = snapshot.data ?? [];

                        return Column(
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Text(
                                    weekdayLabels[index],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: index == 0
                                          ? Colors.redAccent
                                          : colors.textPrimary,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(
                                height: 12,
                                thickness: 1,
                                color: Colors.white12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: startPadding + totalDays,
                              itemBuilder: (context, index) {
                                if (index < startPadding) {
                                  return const SizedBox.shrink();
                                }

                                final day = index - startPadding + 1;
                                final missionDate = DateTime(year, month, day);
                                final isToday = (year == now.year &&
                                    month == now.month &&
                                    day == today);
                                final isPastOrToday =
                                    missionDate.isBefore(DateTime.now()) ||
                                        isToday;
                                final isCleared = clearedDates.any(
                                    (d) => d.year == year && d.month == month && d.day == day);

                                return GestureDetector(
                                  onTap: () async {
                                    if (!isCleared && isPastOrToday) {
                                      final loc = AppLocalizations.of(context)!;
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: colors.card,
                                          title: Text(
                                            loc.mission_dialog_title,
                                            style: TextStyle(
                                                color: colors.textPrimary,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          content: Text(
                                            loc.mission_dialog_date_info_format(
                                                day.toString(),
                                                month.toString(),
                                                year.toString()) +
                                                '\n' +
                                                loc.mission_dialog_difficulty_random +
                                                '\n' +
                                                loc.mission_dialog_challenge_question,
                                            style: TextStyle(
                                                color: colors.textPrimary),
                                            textAlign: TextAlign.center,
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(),
                                                  child: Text(
                                                    loc.mission_dialog_cancel,
                                                    style: TextStyle(
                                                        color: colors.textPrimary),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        colors.accent,
                                                    foregroundColor:
                                                        Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    final difficulties = [
                                                      "easy",
                                                      "normal",
                                                      "hard"
                                                    ];
                                                    difficulties.shuffle();
                                                    final randomDifficulty =
                                                        difficulties.first;
                                                    _startGame(randomDifficulty,
                                                        missionDate);
                                                  },
                                                  child: Text(loc.mission_dialog_start),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? colors.accent.withOpacity(0.8)
                                          : isCleared
                                              ? colors.success
                                                  .withOpacity(0.3)
                                              : isPastOrToday
                                                  ? colors.card
                                                      .withOpacity(0.8)
                                                  : colors.card
                                                      .withOpacity(0.3),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isToday
                                            ? colors.accent
                                            : isCleared
                                                ? colors.success
                                                : Colors.white10,
                                        width: isToday ? 3.0 : 1.0,
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: isToday
                                                ? Colors.black
                                                : isPastOrToday
                                                    ? colors.textPrimary
                                                    : Colors.white38,
                                          ),
                                        ),
                                        if (isCleared)
                                          const Positioned(
                                            top: 3,
                                            child: Icon(Icons.star,
                                                color: Colors.yellow,
                                                size: 22,
                                                shadows: [
                                                  Shadow(
                                                      blurRadius: 4.0,
                                                      color: Colors.black45,
                                                      offset:
                                                          Offset(1.0, 1.0))
                                                ]),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLegend(context, colors),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}