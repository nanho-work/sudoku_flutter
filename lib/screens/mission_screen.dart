import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/mission_service.dart';

/// 미션 스크린 (일일 미션)
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  Future<void> _startGame(String difficulty) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final today = now.day;

    // Get the number of days in the current month
    int daysInMonth(int year, int month) {
      final beginningNextMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);
      return beginningNextMonth.subtract(const Duration(days: 1)).day;
    }

    final totalDays = daysInMonth(year, month);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/koofy1.png', height: 48),
            const SizedBox(width: 8),
            const Text(
              "모두의 즐거움! Koofy",
              style: TextStyle(
                fontSize: 24,         // 글자 크기
                fontWeight: FontWeight.bold, // 굵게
                color: Colors.black,  // 글자 색 (AppBar 색상 대비해서 선택)
              ),
            ),
          ],
        ),
        centerTitle: true, // 타이틀을 가운데 정렬 (선택 사항)
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<DateTime>>(
                      future: MissionService.getClearedDatesInMonth(DateTime(year, month)),
                      builder: (context, snapshot) {
                        final clearedDates = snapshot.data ?? [];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$year년 $month월 일일미션",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                                childAspectRatio: 1,
                              ),
                              itemCount: totalDays,
                              itemBuilder: (context, index) {
                                final day = index + 1;
                                final isToday = day == today;
                                final isPastOrToday = day <= today;
                                final isCleared = clearedDates.any((d) => d.day == day);

                                return GestureDetector(
                                  onTap: () async {
                                    if (!isCleared && isPastOrToday) {
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("오늘의 미션"),
                                          content: Text("$year년 $month월 $day일 미션을 시작하시겠습니까?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("취소"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                _startGame("easy");
                                              },
                                              child: const Text("시작"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? Colors.blue[300]
                                          : isCleared
                                              ? Colors.green[200]
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: isToday
                                          ? Border.all(color: Colors.blueAccent, width: 2)
                                          : null,
                                    ),
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            '$day',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isPastOrToday ? Colors.black : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        if (isCleared)
                                          Positioned(
                                            right: 2,
                                            top: 2,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0.8, end: 1.2),
                                              duration: const Duration(seconds: 1),
                                              curve: Curves.easeInOut,
                                              builder: (context, scale, child) {
                                                return Transform.scale(
                                                  scale: scale,
                                                  child: child,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.workspace_premium, // 왕관 느낌 아이콘
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                            ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}