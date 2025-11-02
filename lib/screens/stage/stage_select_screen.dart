import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/stage_model.dart';
import '../../models/user_model.dart';
import '../../providers/stage_progress_provider.dart';
import '../../services/stage_service.dart';
import '../../services/user_service.dart';
import 'components/stage_play_screen.dart';

class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({super.key});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  late Future<List<StageModel>> _stagesFuture;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _stagesFuture = StageService().loadStages();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final u = await UserService().getUserModel(uid);
    if (mounted) setState(() => _currentUser = u);
  }

  /// ✅ 스테이지 목록이 로드된 후 진행상태 갱신
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<StageProgressProvider>();
    _stagesFuture.then((stages) {
      provider.loadProgress(stages.map((s) => s.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<StageProgressProvider?>();
    final progressMap = progressProvider?.progressMap ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('스테이지 선택')),
      body: FutureBuilder<List<StageModel>>(
        future: _stagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("스테이지 데이터를 불러올 수 없습니다."));
          }

          final stages = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final progress = progressMap[stage.id];
              final cleared = progress?.cleared ?? false;
              final starsCount =
                  progress?.stars.values.where((v) => v).length ?? 0;

              final locked = StageService().isLocked(stage, progressMap);

              return GestureDetector(
                onTap: locked
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StagePlayScreen(stage: stage, user: _currentUser),
                          ),
                        ).then((_) {
                          // ✅ 돌아올 때 진행상태 다시 로드
                          final provider =
                              context.read<StageProgressProvider>();
                          provider.loadProgress(
                              stages.map((s) => s.id).toList());
                          setState(() {});
                        });
                      },
                child: Card(
                  elevation: 3,
                  color: locked
                      ? Colors.grey.shade300
                      : (cleared
                          ? Colors.lightGreen.shade100
                          : Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (locked)
                        Icon(Icons.lock,
                            size: 36, color: Colors.grey.shade600)
                      else
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(stage.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(stage.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (i) {
                                  final filled = i < starsCount;
                                  return Icon(
                                    filled ? Icons.star : Icons.star_border,
                                    color:
                                        filled ? Colors.amber : Colors.grey,
                                    size: 18,
                                  );
                                }),
                              ),
                              if (cleared)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('클리어 완료',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.green)),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}