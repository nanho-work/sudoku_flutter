import 'package:flutter/material.dart';
import '../../../models/stage_model.dart';
import '../../../models/stage_progress_model.dart';
import '../../../models/user_model.dart';
import 'stage_card.dart';

class StagePageView extends StatefulWidget {
  final List<StageModel> stages;
  final Map<String, StageProgressModel> progressMap;
  final UserModel? currentUser;
  final int initialPage;

  const StagePageView({
    super.key,
    required this.stages,
    required this.progressMap,
    this.currentUser,
    this.initialPage = 0,
  });

  @override
  State<StagePageView> createState() => _StagePageViewState();
}

class _StagePageViewState extends State<StagePageView> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage);
    _currentIndex = widget.initialPage;
  }

  bool _isLocked(StageModel stage, int index) {
    // 이미 클리어된 건 무조건 오픈
    final p = widget.progressMap[stage.id];
    if (p?.cleared == true) return false;

    // 첫 스테이지는 항상 오픈
    if (index == 0) return false;

    // unlock_condition이 명시된 경우
    final unlockId = stage.unlockCondition;
    if (unlockId != null && unlockId.isNotEmpty) {
      final up = widget.progressMap[unlockId];
      return !(up?.cleared ?? false);
    }

    // ✅ 이전 스테이지 중 하나라도 미클리어면 잠금
    for (int i = 0; i < index; i++) {
      final prevId = widget.stages[i].id;
      final prevCleared = widget.progressMap[prevId]?.cleared ?? false;
      if (!prevCleared) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.stages.length;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex > 0)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              )
            else
              const SizedBox(width: 12),
            Text("${_currentIndex + 1} / $total"),
            if (_currentIndex < total - 1)
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              )
            else
              const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: total,
            itemBuilder: (context, index) {
              final stage = widget.stages[index];
              final progress = widget.progressMap[stage.id];
              final locked = _isLocked(stage, index);

              return Stack(
                children: [
                  if (locked)
                    Positioned.fill(
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      heightFactor: 0.75,
                      child: StageCard(
                        stage: stage,
                        progress: progress,
                        locked: locked,
                        currentUser: widget.currentUser,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}