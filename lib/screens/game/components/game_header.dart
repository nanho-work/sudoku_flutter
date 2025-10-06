import 'package:sudoku_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/game_controller.dart';

// GameBoard에서 사용되는 명시적인 패딩 값 (40.0은 좌우 20.0씩을 의미)
const double kBoardHorizontalPadding = 20.0;

class GameHeader extends StatelessWidget {
  const GameHeader({Key? key}) : super(key: key);
  
  // 💡 [핵심]: GameBoard와 동일한 좌우 여백을 계산하여 반환
  double _calculateHorizontalPadding(BuildContext context) {
    // GameScreen에서 maxWidth: 600.0 제약을 걸었으므로, 현재 화면 너비를 가져옵니다.
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // GameScreen의 최대 너비 제약 (600.0)을 적용합니다.
    const double maxGameWidth = 600.0;
    
    // 만약 화면 너비가 600.0을 초과하면, 남은 여백을 균등하게 나눠 가집니다.
    if (screenWidth > maxGameWidth) {
      // (전체 화면 너비 - 최대 게임 너비) / 2
      final double externalPadding = (screenWidth - maxGameWidth) / 2;
      return externalPadding + kBoardHorizontalPadding;
    }
    
    // 화면 너비가 600.0 이하일 때는 kBoardHorizontalPadding(20.0)을 유지합니다.
    return kBoardHorizontalPadding;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final loc = AppLocalizations.of(context)!;
    
    // 💡 동적으로 계산된 패딩 값을 사용합니다.
    final double horizontalPadding = _calculateHorizontalPadding(context);

    return Padding(
      // 💡 동적 여백 적용
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 💡 [수정] 뒤로가기 버튼과 난이도 텍스트를 함께 배치
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 💡 뒤로가기 버튼: 클릭 시 이전 화면으로 돌아갑니다. (AppBar 역할 대체)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                // IconButton의 기본 패딩이 Row의 높이를 키우지 않도록 줄입니다.
                padding: EdgeInsets.zero, 
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
              Text(
                "${loc.game_header_level}: ${controller.difficultyLabels[controller.difficulty] ?? controller.difficulty}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // 기존 시간 및 하트 표시 영역
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${loc.game_header_time}: ${controller.formatElapsedTime()}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < controller.hearts ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
