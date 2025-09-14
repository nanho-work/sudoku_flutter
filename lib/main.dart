import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SudokuApp());
}

/// 앱 구동 파일 (앱 시작점)
class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}