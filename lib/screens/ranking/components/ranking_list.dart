import 'package:flutter/material.dart';
import '../../../models/ranking_model.dart';

class RankingList extends StatelessWidget {
  final List<RankingRecord> rankings;
  const RankingList({super.key, required this.rankings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final rank = index + 4;
        final record = rankings[index];
        return ListTile(
          leading: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          title: Text(record.nickname),
          trailing: Text('${record.clearTime.toStringAsFixed(2)}초'),
        );
      },
    );
  }
}