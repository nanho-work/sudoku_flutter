import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

//==============================================================================
// 1. Color Palette Definitions (AppColorPalette 및 구현 클래스)
//==============================================================================

/// 모든 테마 색상 팔레트가 구현해야 하는 추상 인터페이스
/// 이를 통해 ThemeController의 colors getter가 type-safe하게 됩니다.
abstract class AppColorPalette {
  Color get background; // 전체 배경 색상
  Color get surface; // 주요 영역(카드, 버튼 등)의 배경색
  Color get accent; // accent 색상
  Color get success; // 성공 상태 표시 색상
  Color get textMain; // 메인 텍스트 색상
  Color get textSub; // 서브 텍스트 색상
  Color get card; // 카드 컴포넌트 배경색
  Color get placeholder; // 플레이스홀더(비활성 텍스트) 색상
  Color get highlight; // 강조 또는 하이라이트 색상
  Color get gradientStart; // 그라디언트 시작 색상
  Color get gradientEnd; // 그라디언트 끝 색상

  // 버튼 스타일 
  Color get buttonBackground; // 버튼 배경색
  Color get buttonText; // 버튼 텍스트색
  
  // 하단바
  Color get bottomItemSelected; // 하단바 선택된 아이템 색상
  Color get bottomItemUnselected; // 하단바 선택되지 않은 아이템 색상
  
  // 셀
  Color get cleared; // 클리어된 셀 배경색
  Color get cellSelected; // 선택된 셀 색상
  Color get cellInvalid; // 잘못된 셀 색상
  Color get cellHighlighted; // 하이라이트된 셀 색상
  Color get cellDefault; // 기본 셀 배경색
 
  // 난이도 카드 - 완성
  Color get easyCard;
  Color get normalCard;
  Color get hardCard;
  Color get extremeCard;
}

/// 🎨 Light Theme (라이트 테마, improved pastel-balanced)
class LightAppColors implements AppColorPalette {
  const LightAppColors();

  // 기본 배경 계열
  @override final Color background = const Color(0xFFFFFFFF);
  @override final Color surface = const Color(0xFFF9FAFB);

  // 포인트 및 상태
  @override final Color accent = const Color(0xFFB3E5FC); // soft sky blue
  @override final Color success = const Color(0xFFC8E6C9); // mint green
  @override final Color textMain = const Color(0xFF212121);
  @override final Color textSub = const Color(0xFF616161);

  // 컴포넌트 및 하이라이트
  @override final Color card = const Color(0xFFFFFFFF);
  @override final Color placeholder = const Color(0xFFBDBDBD);
  @override final Color highlight = const Color(0xFFF1F3F4);
  @override final Color cleared = const Color(0xFFE8F5E9);
  @override final Color gradientStart = const Color(0xFFFAFAFA);
  @override final Color gradientEnd = const Color(0xFFFFFFFF);
  @override final Color buttonBackground = const Color(0xFFB3E5FC);
  @override final Color buttonText = const Color(0xFF212121);
  @override final Color bottomItemSelected = const Color(0xFFB3E5FC);
  @override final Color bottomItemUnselected = const Color(0xFFCFD8DC);
  @override final Color cellSelected = const Color(0xFFB3E5FC);
  @override final Color cellInvalid = const Color(0xFFFFCDD2);
  @override final Color cellHighlighted = const Color(0xFFF5F5F5);
  @override final Color cellDefault = const Color(0xFFFFFFFF);

  // 난이도 카드 — 밝은 파스텔 계조
  @override final Color easyCard    = const Color(0xFFFFFBF2); // 거의 흰색, 살짝 따뜻한톤
  @override final Color normalCard  = const Color(0xFFFFF3D6); // 연한 아이보리
  @override final Color hardCard    = const Color(0xFFFFE8B2); // 중간 아이보리
  @override final Color extremeCard = const Color(0xFFFFD180); // 진한 크림톤
}

/// 🌙 Dark Theme (다크 테마, modern, softer style)
class DarkAppColors implements AppColorPalette {
  const DarkAppColors();

  @override final Color background = const Color(0xFF181818);
  @override final Color surface = const Color(0xFF202124);
  @override final Color accent = const Color(0xFF8AB4F8);
  @override final Color success = const Color(0xFF66BB6A);
  @override final Color textMain = const Color(0xFFE0E0E0);
  @override final Color textSub = const Color(0xFFA8ADB3);

  @override final Color card = const Color(0xFF2A2A2A);
  @override final Color placeholder = const Color(0xFF5F6368);
  @override final Color highlight = const Color(0xFF2A2A2A);
  @override final Color cleared = const Color(0xFF1F2A24);
  @override final Color gradientStart = const Color(0xFF181818);
  @override final Color gradientEnd = const Color(0xFF121212);
  @override final Color buttonBackground = const Color(0xFF3C4F70);
  @override final Color buttonText = const Color(0xFFE0E0E0);
  @override final Color bottomItemSelected = const Color(0xFF8AB4F8);
  @override final Color bottomItemUnselected = const Color(0xFF3C4043);

  @override final Color cellSelected = const Color(0xFF3C4F70);
  @override final Color cellInvalid = const Color(0xFFB85C5C);
  @override final Color cellHighlighted = const Color(0xFF2E2E2E);
  @override final Color cellDefault = const Color(0xFF222222);

  @override final Color easyCard = const Color(0xFFBDBDBD); // 밝은 회색
  @override final Color normalCard = const Color(0xFF9E9E9E); // 중간 회색
  @override final Color hardCard = const Color(0xFF757575);   // 짙은 회색
  @override final Color extremeCard = const Color(0xFF616161); // 가장 어두운 회색
}

/// 💖 Pink Theme (핑크 파스텔 테마)
class PinkAppColors implements AppColorPalette {
  const PinkAppColors();
  @override final Color background = const Color(0xFFFFF5F7);
  @override final Color surface = const Color(0xFFFFEBEE);
  @override final Color accent = const Color(0xFFFFC1CC);

  @override final Color success = const Color(0xFFC8E6C9);
  @override final Color textMain = const Color(0xFF5D4037);
  @override final Color textSub = const Color(0xFF8D6E63);

  @override final Color card = const Color(0xFFFFEBEE);
  @override final Color placeholder = const Color(0xFFE1BEE7);
  @override final Color highlight = const Color(0xFFFFE4EC);
  @override final Color cleared = const Color(0xFFFFF0F3);
  @override final Color gradientStart = const Color(0xFFFFF7F9);
  @override final Color gradientEnd = const Color(0xFFFFEBEE);
  @override final Color buttonBackground = const Color(0xFFF8BBD0);
  @override final Color buttonText = const Color(0xFF5D4037);
  @override final Color bottomItemSelected = const Color(0xFFF8BBD0);
  @override final Color bottomItemUnselected = const Color(0xFFE1BEE7);
  @override final Color cellSelected = const Color(0xFFF8BBD0);
  @override final Color cellInvalid = const Color(0xFFFFCDD2);
  @override final Color cellHighlighted = const Color(0xFFFFE4EC);
  @override final Color cellDefault = const Color(0xFFFFF8F8);

  @override final Color easyCard = const Color(0xFFFCE4EC);
  @override final Color normalCard = const Color(0xFFF8BBD0);
  @override final Color hardCard = const Color(0xFFF48FB1);
  @override final Color extremeCard = const Color(0xFFE57373);
}
