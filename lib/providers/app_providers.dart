import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_controller.dart';
import '../controllers/theme_controller.dart';

/// 앱 전체 Provider 등록용 유틸
/// (실제 초기화는 main.dart에서 수행 후 전달됨)
class AppProviders {
  static MultiProvider register({
    required Widget child,
    required AudioController audioController,
    required ThemeController themeController,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioController>.value(value: audioController),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: child,
    );
  }
}