import 'package:flutter/material.dart';

/// 난이도 선택 카드 위젯
class DifficultyCard extends StatefulWidget {
  final String title;        // 난이도 이름 (쉬움, 보통, 어려움)
  final String subtitle;     // 설명 텍스트
  final Color color;         // 카드 배경색
  final Color hoverColor;    // hover 시 카드 배경색
  final VoidCallback onTap;  // 클릭 시 실행할 함수

  const DifficultyCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.hoverColor,
    required this.onTap,
  });

  @override
  State<DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<DifficultyCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 400), // 카드 최대 가로폭 제한
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _isHovering ? widget.hoverColor : widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.extension, size: 36, color: Colors.black87), // 퍼즐 아이콘
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}