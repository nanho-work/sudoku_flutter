import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppFooter({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,          // 푸터 배경색
        selectedItemColor: Colors.blueAccent,   // 선택된 아이콘 색
        unselectedItemColor: Colors.grey,       // 선택 안 된 아이콘 색
        items: const [
            BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '미션',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '가이드',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '정보',
            ),
            
        ],
        );
  }
}