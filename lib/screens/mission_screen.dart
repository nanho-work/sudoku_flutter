import 'package:flutter/material.dart';
import 'package:sudoku_flutter/screens/game/game_screen.dart';
import '../services/mission_service.dart';

/// 미션 스크린 (일일 미션) - 다크 테마 적용
class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  // UI 갱신을 강제로 트리거하기 위한 변수 (FutureBuilder의 key로 사용)
  int _reload = 0;
  
  // GameScreen으로 이동하고 돌아올 때까지 기다린 후, UI를 강제 갱신합니다.
  Future<void> _startGame(String difficulty, DateTime missionDate) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty, missionDate: missionDate),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 300));
    // GameScreen에서 돌아오면 상태를 갱신하여 FutureBuilder를 강제로 다시 실행합니다.
    setState(() { 
      _reload++; 
      // print("[MissionScreen] UI force reload triggered: $_reload");
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBackgroundColor = Color(0xFF1E272E); 
    const Color darkAppBarColor = Color(0xFF263238);
    const Color darkCardColor = Color(0xFF37474F); // 캘린더 배경색
    const Color accentColor = Colors.lightBlueAccent;
    const Color clearedColor = Colors.greenAccent;

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final today = now.day;

    // 해당 월의 총 일수 계산
    int daysInMonth(int year, int month) {
      final beginningNextMonth = (month < 12)
          ? DateTime(year, month + 1, 1)
          : DateTime(year + 1, 1, 1);
      return beginningNextMonth.subtract(const Duration(days: 1)).day;
    }

    final totalDays = daysInMonth(year, month);
    
    // 1일의 요일 (Dart: 1=월, 7=일)을 기준으로 달력 그리드 시작 전 빈칸 수 계산
    final firstDayWeekday = DateTime(year, month, 1).weekday;
    // 캘린더를 일요일부터 시작한다고 가정하고 빈칸 수를 조정합니다. (일요일: 0, 월요일: 1, ...)
    final startPadding = (firstDayWeekday == 7) ? 0 : firstDayWeekday; 
    
    // 요일 레이블 (일요일부터 시작)
    const List<String> weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];

    return Scaffold(
      backgroundColor: darkBackgroundColor, // 💡 배경색 통일
      appBar: AppBar(
        title: Text(
          "$year년 $month월 일일미션", 
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: darkAppBarColor, // 💡 AppBar 색상 통일
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 💡 Card UI 개선
                Card(
                  color: darkCardColor, // 💡 캘린더 카드 배경색
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.white10, width: 1), // 테두리 추가
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<DateTime>>(
                      // ⭐️ key를 사용하여 GameScreen에서 돌아왔을 때 Future를 강제로 다시 실행합니다.
                      key: ValueKey('mission_reloa $_reload}_${DateTime.now().millisecondsSinceEpoch}'),
                      future: MissionService.getClearedDatesInMonth(DateTime(year, month)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(color: accentColor), // 💡 로딩 색상 변경
                            ),
                          );
                        }
                        
                        final clearedDates = snapshot.data ?? [];
                        
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. 요일 헤더 (일요일 시작)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                      // 💡 텍스트 색상 변경 (일요일은 강조, 나머지는 흰색)
                                      color: index == 0 ? Colors.redAccent : Colors.white, 
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 12, thickness: 1, color: Colors.white12), // 💡 Divider 색상 조정
                            // 2. 날짜 그리드 (빈칸 포함)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: startPadding + totalDays,
                              itemBuilder: (context, index) {
                                // 요일 시작을 위한 빈칸 처리
                                if (index < startPadding) {
                                  return const SizedBox.shrink(); 
                                }

                                final day = index - startPadding + 1;
                                final missionDate = DateTime(year, month, day);
                                
                                final isToday = day == today;
                                final isPastOrToday = day <= today;
                                // ⭐️ 클리어 여부 확인: MissionService에서 가져온 날짜 목록에 현재 날짜가 있는지 확인
                                final isCleared = clearedDates.any((d) => d.day == day);

                                return GestureDetector(
                                  onTap: () async {
                                    if (!isCleared && isPastOrToday) {
                                      // 💡 AlertDialog UI 개선 (다크 테마에 맞게)
                                      await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor: darkCardColor,
                                          title: const Text("일일 미션 시작", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          content: Text(
                                            "$year년 $month월 $day일 미션을 시작하시겠습니까? 난이도는 무작위로 결정됩니다.",
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("취소", style: TextStyle(color: Colors.grey)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: accentColor,
                                                foregroundColor: Colors.black,
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();

                                                final difficulties = ["easy", "normal", "hard"];
                                                difficulties.shuffle();
                                                final randomDifficulty = difficulties.first;

                                                _startGame(randomDifficulty, missionDate);
                                              },
                                              child: const Text("시작"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? accentColor.withOpacity(0.8) // 💡 오늘 날짜 강조
                                          : isCleared
                                              ? clearedColor.withOpacity(0.3) // 💡 클리어 날짜
                                              : isPastOrToday
                                                  ? darkCardColor.withOpacity(0.8) // 💡 클리어하지 않은 과거/오늘 날짜 (어두운 카드 색상 기반)
                                                  : darkCardColor.withOpacity(0.3), // 미래 날짜 (더 연하게)
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isToday ? accentColor : isCleared ? clearedColor : Colors.white10,
                                        width: isToday ? 3.0 : 1.0,
                                      ),
                                      boxShadow: [
                                        if (isCleared)
                                          BoxShadow(
                                            color: clearedColor.withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        if (isToday)
                                          BoxShadow(
                                            color: accentColor.withOpacity(0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          '$day',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            // 💡 텍스트 색상 조정
                                            color: isToday ? Colors.black : isPastOrToday ? Colors.white : Colors.white38,
                                          ),
                                        ),
                                        if (isCleared)
                                          // 클리어 확인 아이콘
                                          Positioned(
                                            right: 2,
                                            top: 2,
                                            child: Icon(
                                                Icons.check_circle, 
                                                color: clearedColor,
                                                size: 22, // 아이콘 크기 키우기
                                                shadows: const [
                                                  Shadow(
                                                    blurRadius: 4.0,
                                                    color: Colors.black45,
                                                    offset: Offset(1.0, 1.0)
                                                  )
                                                ],
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
                // 캘린더 아래 여백
                const SizedBox(height: 50), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
