# sudoku_flutter

## 📂 폴더 및 파일 기능

- **lib/main.dart** : 앱 시작점, MaterialApp 설정
- **lib/screens/home_screen.dart** : 난이도 선택 화면, 퍼즐 시작 버튼
- **lib/screens/game_screen.dart** : 스도쿠 보드 & 플레이 화면
- **lib/widgets/sudoku_board.dart** : 9×9 스도쿠 보드 UI
- **lib/widgets/number_pad.dart** : 숫자 입력 패드 (1~9)
- **lib/services/sudoku_generator.dart** : 퍼즐 생성 (MVP 단계에서는 미리 정의된 퍼즐 사용)
- **lib/services/sudoku_solver.dart** : 퍼즐 풀이 및 검증 로직
- **pubspec.yaml** : Flutter 앱 메타데이터 및 의존성 관리

---

## 📂 프로젝트 구조

```
sudoku_flutter/
 ┣ lib/
 ┃ ┣ main.dart              # 앱 시작점
 ┃ ┣ screens/
 ┃ ┃ ┣ home_screen.dart     # 난이도 선택, 퍼즐 시작
 ┃ ┃ ┗ game_screen.dart     # 스도쿠 보드 & 플레이 화면
 ┃ ┣ widgets/
 ┃ ┃ ┣ sudoku_board.dart    # 9×9 보드 UI
 ┃ ┃ ┗ number_pad.dart      # 숫자 입력 UI
 ┃ ┗ services/
 ┃    ┣ sudoku_generator.dart  # 퍼즐 생성 (MVP는 미리 정의된 퍼즐)
 ┃    ┗ sudoku_solver.dart     # 퍼즐 풀이/검증
 ┗ pubspec.yaml
```