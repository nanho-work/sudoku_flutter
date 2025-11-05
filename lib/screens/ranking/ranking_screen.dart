import 'package:flutter/material.dart';
import '../../../models/ranking_model.dart';
import '../../../services/ranking_service.dart';
import 'components/ranking_header.dart';
import 'components/ranking_top3.dart';
import 'components/ranking_list.dart';
import 'components/my_ranking_button.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  String _difficulty = 'easy';
  String _weekKey = RankingService.currentWeekKey();
  late Stream<List<RankingRecord>> _rankingStream;

  @override
  void initState() {
    super.initState();
    _rankingStream = RankingService.streamTopRankings(_difficulty, weekKey: _weekKey);
  }

  void _updateDifficulty(String newDiff) {
    setState(() {
      _difficulty = newDiff;
      _rankingStream = RankingService.streamTopRankings(_difficulty, weekKey: _weekKey);
    });
  }

  void _updateWeek(String newWeek) {
    setState(() {
      _weekKey = newWeek;
      _rankingStream = RankingService.streamTopRankings(_difficulty, weekKey: _weekKey);
    });
  }

  Future<void> _previousWeek() async {
    final weeks = await RankingService.getCachedWeeks(difficulty: _difficulty);
    if (weeks == null || weeks.isEmpty) return; // safeguard
    final idx = weeks.indexOf(_weekKey);
    if (idx < weeks.length - 1) {
      _updateWeek(weeks[idx + 1]);
    }
  }

  Future<void> _nextWeek() async {
    final weeks = await RankingService.getCachedWeeks(difficulty: _difficulty);
    if (weeks == null || weeks.isEmpty) return; // safeguard
    final idx = weeks.indexOf(_weekKey);
    if (idx > 0) {
      _updateWeek(weeks[idx - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _previousWeek,
            ),
            Text(RankingService.formatWeekLabel(_weekKey)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _nextWeek,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          RankingHeader(
            currentDifficulty: _difficulty,
            onDifficultyChanged: _updateDifficulty,
          ),
          Expanded(
            child: StreamBuilder<List<RankingRecord>>(
              stream: _rankingStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rankings = snapshot.data!;
                if (rankings.isEmpty) {
                  return const Center(child: Text('아직 랭킹 데이터가 없습니다.'));
                }

                final top3 = rankings.take(3).toList();
                final others = rankings.skip(3).toList();

                return Column(
                  children: [
                    RankingTop3(top3: top3),
                    Expanded(child: RankingList(rankings: others)),
                    const MyRankingButton(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}