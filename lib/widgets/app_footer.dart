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
    const Color darkSurfaceColor = Color(0xFF263238); 
    const Color accentColor = Colors.lightBlueAccent;

    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        // 💡 UI 개선: 다크 테마 배경색 적용
        backgroundColor: darkSurfaceColor,          
        // 💡 UI 개선: 통일된 액센트 컬러 적용
        selectedItemColor: accentColor,   
        // 💡 UI 개선: 선택 안 된 아이콘 색상 조정
        unselectedItemColor: Colors.white54,       
        elevation: 12, // 깊이감 추가
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
