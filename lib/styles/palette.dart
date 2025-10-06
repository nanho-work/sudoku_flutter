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
  Color get primary; // 기본 주요 색상 (앱 포인트 컬러)
  Color get secondary; // 보조 색상
  Color get accent; // 강조 색상 (특정 포인트)
  Color get success; // 성공 상태 표시 색상
  Color get error; // 오류 상태 표시 색상
  Color get textPrimary; // 기본 텍스트 색상
  Color get textSecondary; // 보조 텍스트 색상

  Color get appBar; // 앱바 배경색
  Color get card; // 카드 컴포넌트 배경색
  Color get placeholder; // 플레이스홀더(비활성 텍스트) 색상
  Color get highlight; // 강조 또는 하이라이트 색상
  Color get cleared; // 클리어된 셀 배경색
  Color get splashBackground; // 스플래시 화면 배경색
  Color get gradientStart; // 그라디언트 시작 색상
  Color get gradientEnd; // 그라디언트 끝 색상
  Color get bottomBarBackground; // 하단 바 배경색
  Color get bottomItemSelected; // 하단바 선택된 아이템 색상
  Color get bottomItemUnselected; // 하단바 선택되지 않은 아이템 색상
  Color get cellSelected; // 선택된 셀 색상
  Color get cellInvalid; // 잘못된 셀 색상
  Color get cellHighlighted; // 하이라이트된 셀 색상
  Color get cellDefault; // 기본 셀 배경색
}

/// 🎨 Light Theme (라이트 테마)
class LightAppColors implements AppColorPalette {
  const LightAppColors();
  @override final Color background = const Color(0xFFFFF8E1); // 파스텔 노랑
  @override final Color surface = const Color(0xFFFFF3E0); // 연한 주황
  @override final Color primary = const Color(0xFFA5D6A7); // 파스텔 초록
  @override final Color secondary = const Color(0xFF90CAF9); // 파스텔 파랑
  @override final Color accent = const Color(0xFFF48FB1); // 파스텔 분홍
  @override final Color success = const Color(0xFF81C784); // 부드러운 초록
  @override final Color error = const Color(0xFFE57373); // 부드러운 빨강
  @override final Color textPrimary = const Color(0xFF37474F); // 진한 회색
  @override final Color textSecondary = const Color(0xFF607D8B); // 중간 회색

  @override final Color appBar = const Color(0xFFFFF3E0); // 앱바 배경
  @override final Color card = const Color(0xFFFFF9C4); // 카드 배경
  @override final Color placeholder = const Color(0xFFBDBDBD); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFFFF59D); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFE0F2F1); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFFFF8E1); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFFFFDE7); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFFFF8E1); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFFFF3E0); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFA5D6A7); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFFBDBDBD); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFA5D6A7); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFFFCDD2); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFFFF59D); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

/// 🌙 Dark Theme (다크 테마)
class DarkAppColors implements AppColorPalette {
  const DarkAppColors();
  @override final Color background = const Color(0xFF1E272E); // 진한 네이비 그레이
  @override final Color surface = const Color(0xFF2F3640); // 어두운 서피스
  @override final Color primary = const Color(0xFF81C784); // 파스텔 초록
  @override final Color secondary = const Color(0xFF64B5F6); // 파스텔 블루
  @override final Color accent = const Color(0xFFF06292); // 파스텔 핑크
  @override final Color success = const Color(0xFF66BB6A); // 부드러운 초록
  @override final Color error = const Color(0xFFEF5350); // 부드러운 레드
  @override final Color textPrimary = const Color(0xFFECEFF1); // 거의 흰색
  @override final Color textSecondary = const Color(0xFFB0BEC5); // 밝은 회색

  @override final Color appBar = const Color(0xFF2F3640); // 앱바 배경
  @override final Color card = const Color(0xFF3E4A59); // 카드 배경
  @override final Color placeholder = const Color(0xFF78909C); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFF455A64); // 하이라이트 색상
  @override final Color cleared = const Color(0xFF263238); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFF1E272E); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFF263238); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFF1E272E); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFF2F3640); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFF81C784); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFF546E7A); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFF81C784); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFEF9A9A); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFF455A64); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFF37474F); // 기본 셀 배경
}

/// 💖 Pink Theme (핑크 파스텔 테마)
class PinkAppColors implements AppColorPalette {
  const PinkAppColors();
  @override final Color background = const Color(0xFFFFEBEE); // 파스텔 핑크
  @override final Color surface = const Color(0xFFF8BBD0); // 연한 파스텔 핑크
  @override final Color primary = const Color(0xFFF48FB1); // 메인 파스텔 핑크
  @override final Color secondary = const Color(0xFFCE93D8); // 파스텔 라일락
  @override final Color accent = const Color(0xFFFFCDD2); // 밝은 파스텔 핑크
  @override final Color success = const Color(0xFFA5D6A7); // 부드러운 파스텔 초록
  @override final Color error = const Color(0xFFE57373); // 부드러운 파스텔 레드
  @override final Color textPrimary = const Color(0xFF6D4C41); // 진한 브라운
  @override final Color textSecondary = const Color(0xFF8D6E63); // 연한 브라운

  @override final Color appBar = const Color(0xFFF8BBD0); // 앱바 배경
  @override final Color card = const Color(0xFFFFCDD2); // 카드 배경
  @override final Color placeholder = const Color(0xFFD8BFD8); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFFFE0EB); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFFCE4EC); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFFFEBEE); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFFFF0F3); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFFFE0EB); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFF8BBD0); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFF48FB1); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFFE1BEE7); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFF48FB1); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFFFCDD2); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFFFE0EB); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFF8F8); // 기본 셀 배경
}

/// 💙 Blue Theme (블루 파스텔 테마)
class BlueAppColors implements AppColorPalette {
  const BlueAppColors();
  @override final Color background = const Color(0xFFE3F2FD); // 파스텔 블루
  @override final Color surface = const Color(0xFFBBDEFB); // 연한 파스텔 블루
  @override final Color primary = const Color(0xFF90CAF9); // 메인 파스텔 블루
  @override final Color secondary = const Color(0xFF80DEEA); // 파스텔 아쿠아
  @override final Color accent = const Color(0xFFB3E5FC); // 밝은 파스텔 스카이
  @override final Color success = const Color(0xFFA5D6A7); // 부드러운 파스텔 초록
  @override final Color error = const Color(0xFFEF9A9A); // 부드러운 파스텔 레드
  @override final Color textPrimary = const Color(0xFF263238); // 진한 블루그레이
  @override final Color textSecondary = const Color(0xFF607D8B); // 중간 블루그레이

  @override final Color appBar = const Color(0xFFBBDEFB); // 앱바 배경
  @override final Color card = const Color(0xFFB3E5FC); // 카드 배경
  @override final Color placeholder = const Color(0xFF81D4FA); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFE1F5FE); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFE0F7FA); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFE3F2FD); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFB3E5FC); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFE1F5FE); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFBBDEFB); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFF90CAF9); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFF81D4FA); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFF90CAF9); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFEF9A9A); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFE1F5FE); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

/// 💚 Green Theme (그린 파스텔 테마)
class GreenAppColors implements AppColorPalette {
  const GreenAppColors();
  @override final Color background = const Color(0xFFE8F5E9); // 파스텔 그린 (앱의 백그라운드)
  @override final Color surface = const Color(0xFFC8E6C9); // 연한 파스텔 그린 (카드 및 버튼 배경)
  @override final Color primary = const Color(0xFFA5D6A7); // 메인 파스텔 그린 (주요 버튼 및 포인트 컬러)
  @override final Color secondary = const Color(0xFFB2DFDB); // 파스텔 민트 (보조 포인트 컬러)
  @override final Color accent = const Color(0xFFDCE775); // 밝은 파스텔 라임 (하이라이트 및 강조 효과)
  @override final Color success = const Color(0xFF81C784); // 부드러운 파스텔 초록 (성공 상태 표시)
  @override final Color error = const Color(0xFFE57373); // 부드러운 파스텔 레드 (오류 상태 표시)
  @override final Color textPrimary = const Color(0xFF33691E); // 진한 그린 (주 텍스트 색상)
  @override final Color textSecondary = const Color(0xFF689F38); // 중간 그린 (보조 텍스트 색상)

  @override final Color appBar = const Color(0xFFC8E6C9); // 앱바 배경
  @override final Color card = const Color(0xFFDCE775); // 카드 배경
  @override final Color placeholder = const Color(0xFF9CCC65); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFE6EE9C); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFF1F8E9); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFE8F5E9); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFC8E6C9); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFE6EE9C); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFC8E6C9); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFA5D6A7); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFF81C784); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFA5D6A7); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFE57373); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFE6EE9C); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

/// 💛 Yellow Theme (옐로우 파스텔 테마)
class YellowAppColors implements AppColorPalette {
  const YellowAppColors();
  @override final Color background = const Color(0xFFFFFDE7); // 크림 옐로우 (배경)
  @override final Color surface = const Color(0xFFFFF9C4); // 연한 레몬 (카드)
  @override final Color primary = const Color(0xFFFFF176); // 메인 옐로우 (버튼)
  @override final Color secondary = const Color(0xFFFFD54F); // 파스텔 골드 (보조)
  @override final Color accent = const Color(0xFFFFECB3); // 베이지 톤 (하이라이트)
  @override final Color success = const Color(0xFF81C784); // 부드러운 초록 (성공)
  @override final Color error = const Color(0xFFE57373); // 파스텔 레드 (에러)
  @override final Color textPrimary = const Color(0xFF5D4037); // 다크 브라운 (텍스트)
  @override final Color textSecondary = const Color(0xFF8D6E63); // 중간 브라운

  @override final Color appBar = const Color(0xFFFFF9C4); // 앱바 배경
  @override final Color card = const Color(0xFFFFECB3); // 카드 배경
  @override final Color placeholder = const Color(0xFFFFF59D); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFFFF176); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFFFFDE7); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFFFFDE7); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFFFF9C4); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFFFECB3); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFFFF9C4); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFFFF176); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFFFFECB3); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFFFF176); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFE57373); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFFFF59D); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

/// 💜 Purple Theme (퍼플 파스텔 테마)
class PurpleAppColors implements AppColorPalette {
  const PurpleAppColors();
  @override final Color background = const Color(0xFFF3E5F5); // 라벤더 (배경)
  @override final Color surface = const Color(0xFFE1BEE7); // 연보라 (서피스)
  @override final Color primary = const Color(0xFFBA68C8); // 메인 퍼플 (버튼)
  @override final Color secondary = const Color(0xFFCE93D8); // 라일락 (보조)
  @override final Color accent = const Color(0xFFD1C4E9); // 밝은 보라 (하이라이트)
  @override final Color success = const Color(0xFF81C784); // 부드러운 초록 (성공)
  @override final Color error = const Color(0xFFE57373); // 부드러운 레드 (에러)
  @override final Color textPrimary = const Color(0xFF4A148C); // 진한 퍼플 (텍스트)
  @override final Color textSecondary = const Color(0xFF7B1FA2); // 중간 퍼플

  @override final Color appBar = const Color(0xFFE1BEE7); // 앱바 배경
  @override final Color card = const Color(0xFFD1C4E9); // 카드 배경
  @override final Color placeholder = const Color(0xFFB39DDB); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFEDE7F6); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFF3E5F5); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFF3E5F5); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFE1BEE7); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFD1C4E9); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFE1BEE7); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFBA68C8); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFFCE93D8); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFBA68C8); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFE57373); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFEDE7F6); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

/// ⚪ Gray Theme (그레이 파스텔 테마)
class GrayAppColors implements AppColorPalette {
  const GrayAppColors();
  @override final Color background = const Color(0xFFF5F5F5); // 밝은 회색 (배경)
  @override final Color surface = const Color(0xFFE0E0E0); // 카드, 서피스
  @override final Color primary = const Color(0xFFBDBDBD); // 메인 회색
  @override final Color secondary = const Color(0xFF9E9E9E); // 중간 회색
  @override final Color accent = const Color(0xFFEEEEEE); // 밝은 강조색
  @override final Color success = const Color(0xFFA5D6A7); // 초록 (성공)
  @override final Color error = const Color(0xFFE57373); // 레드 (에러)
  @override final Color textPrimary = const Color(0xFF212121); // 진한 회색 (텍스트)
  @override final Color textSecondary = const Color(0xFF616161); // 중간 회색

  @override final Color appBar = const Color(0xFFE0E0E0); // 앱바 배경
  @override final Color card = const Color(0xFFEEEEEE); // 카드 배경
  @override final Color placeholder = const Color(0xFFBDBDBD); // 플레이스홀더 텍스트
  @override final Color highlight = const Color(0xFFF5F5F5); // 하이라이트 색상
  @override final Color cleared = const Color(0xFFFFFFFF); // 클리어된 셀 배경
  @override final Color splashBackground = const Color(0xFFF5F5F5); // 스플래시 배경
  @override final Color gradientStart = const Color(0xFFE0E0E0); // 그라디언트 시작
  @override final Color gradientEnd = const Color(0xFFEEEEEE); // 그라디언트 끝
  @override final Color bottomBarBackground = const Color(0xFFE0E0E0); // 하단 바 배경
  @override final Color bottomItemSelected = const Color(0xFFBDBDBD); // 하단 선택된 아이템
  @override final Color bottomItemUnselected = const Color(0xFF9E9E9E); // 하단 선택 안된 아이템
  @override final Color cellSelected = const Color(0xFFBDBDBD); // 셀 선택 시 색상
  @override final Color cellInvalid = const Color(0xFFE57373); // 셀 오류 표시
  @override final Color cellHighlighted = const Color(0xFFF5F5F5); // 셀 하이라이트
  @override final Color cellDefault = const Color(0xFFFFFFFF); // 기본 셀 배경
}

