import 'package:flutter/material.dart';

// 숫자 패드 전용 스타일
final numberButtonStyle = ElevatedButton.styleFrom(
  // 모양(border radius)
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  // padding: 세로형 직사각형 버튼 크기 (세로 크게, 가로 작게)
  padding: const EdgeInsets.all(4),
  backgroundColor: Colors.blue[300],
  foregroundColor: Colors.black,
);

// 기능 버튼 전용 스타일
final actionButtonStyle = ElevatedButton.styleFrom(
  // 모양(border radius)
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  // padding: 세로형 직사각형 버튼 크기 조절
  padding: const EdgeInsets.all(8),
  backgroundColor: Colors.grey[600],
  foregroundColor: Colors.white,
);