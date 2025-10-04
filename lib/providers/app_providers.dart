import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audio_controller.dart';

/// 앱 전체에서 사용할 Provider들을 등록하는 중앙 관리 파일
class AppProviders {
  static MultiProvider register({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioController()),
        // ⚡ 추후에 다른 Provider 추가 시 여기만 수정
        // ChangeNotifierProvider(create: (_) => ThemeController()),
        // ChangeNotifierProvider(create: (_) => UserController()),
      ],
      child: child,
    );
  }
}