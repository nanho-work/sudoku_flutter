import 'package:firebase_auth/firebase_auth.dart';
import '../providers/stage_progress_provider.dart';

class AppProviders {
  static MultiProvider register({
    required Widget child,
    required AudioController audioController,
    required ThemeController themeController,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioController>.value(value: audioController),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<StageProgressProvider>(
          create: (_) => StageProgressProvider(uid),
        ),
      ],
      child: child,
    );
  }
}