import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/stage_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/stage_progress_provider.dart';
import '../../../services/stage_service.dart';
import '../../../services/user_service.dart';
import 'components/stage_page_view.dart';

class StageSelectScreen extends StatefulWidget {
  const StageSelectScreen({super.key});

  @override
  State<StageSelectScreen> createState() => _StageSelectScreenState();
}

class _StageSelectScreenState extends State<StageSelectScreen> {
  UserModel? _currentUser;
  late final Future<List<StageModel>> _stagesFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _stagesFuture = StageService().loadStages();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await UserService().getUserModel(uid);
    if (mounted) setState(() => _currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<StageProgressProvider?>();
    if (progressProvider == null || !progressProvider.isLoaded) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final progressMap = progressProvider.progressMap;

    return FutureBuilder<List<StageModel>>(
      future: _stagesFuture, // ✅ 캐시/로컬/Firestore 자동 폴백
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: Text("스테이지 데이터를 불러올 수 없습니다.")),
          );
        }

        final stages = snapshot.data!;
        debugPrint("📋 로컬 스테이지 개수: ${stages.length}");
        debugPrint("📋 로컬 스테이지 ID: ${stages.map((s) => s.id).toList()}");
        debugPrint("📊 progressMap keys: ${progressMap.keys}");

        int startIndex = 0;
        for (int i = 0; i < stages.length; i++) {
          final id = stages[i].id;
          final cleared = progressMap[id]?.cleared ?? false;
          if (!cleared) {
            startIndex = i;
            break;
          }
          if (i == stages.length - 1) startIndex = i;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: StagePageView(
            stages: stages,
            progressMap: progressMap,
            currentUser: _currentUser,
            initialPage: startIndex,
          ),
        );
      },
    );
  }
}