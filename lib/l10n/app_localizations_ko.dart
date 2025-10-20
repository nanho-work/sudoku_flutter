// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get guide_title_main => '게임 방법';

  @override
  String get guide_title_goal => '🎯 게임 목표';

  @override
  String get guide_desc_goal_1 => '9x9 스도쿠 판을 완성하는 것이 목표입니다.';

  @override
  String get guide_desc_goal_2 => '빈 칸을 채울 때는 같은 숫자가 같은 행, 같은 열, 그리고 3x3 작은 박스 안에 중복되지 않도록 배치해야 합니다.';

  @override
  String get guide_desc_goal_3 => '모든 칸을 올바르게 채우면 게임이 완료됩니다!';

  @override
  String get guide_title_rules => '📘 규칙 설명';

  @override
  String get guide_rule_row_title => '1. 행 규칙';

  @override
  String get guide_rule_row_desc => '각 가로줄(행)에는 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.';

  @override
  String get guide_rule_col_title => '2. 열 규칙';

  @override
  String get guide_rule_col_desc => '각 세로줄(열)에도 1부터 9까지 숫자가 한 번씩만 들어가야 합니다.';

  @override
  String get guide_rule_box_title => '3. 3x3 박스 규칙';

  @override
  String get guide_rule_box_desc => '9개의 작은 3x3 박스마다 1부터 9까지 숫자가 중복 없이 배치되어야 합니다.';

  @override
  String get guide_title_control => '⚙️ 조작 방법';

  @override
  String get guide_desc_control_1 => '숫자를 입력하려면 빈 칸을 탭한 후 하단 숫자 패드를 사용하세요.';

  @override
  String get guide_desc_control_2 => '오류가 있을 경우 자동으로 표시되며, 힌트를 통해 도움을 받을 수 있습니다.';

  @override
  String get guide_desc_control_3 => '길게 눌러 숫자를 지우거나, 스와이프 동작으로 빠르게 이동할 수 있습니다.';

  @override
  String get guide_title_error => '🚫 오류 표시 안내';

  @override
  String get guide_desc_error_1 => '잘못된 숫자를 입력하면 빨간색으로 표시되어 즉시 알 수 있습니다.';

  @override
  String get guide_desc_error_2 => '오류 표시 기능은 설정에서 켜고 끌 수 있습니다.';

  @override
  String get guide_desc_error_3 => '오류가 많을 경우 힌트 사용이 제한될 수 있으니 주의하세요.';

  @override
  String get guide_title_stats => '📊 통계 안내';

  @override
  String get guide_desc_stats_1 => '게임 완료 후 통계 화면에서 플레이 시간, 정답률, 힌트 사용 횟수 등을 확인할 수 있습니다.';

  @override
  String get guide_desc_stats_2 => '통계는 난이도별로 분류되어 자신의 실력을 체계적으로 관리할 수 있습니다.';

  @override
  String get guide_title_difficulty => '난이도 안내';

  @override
  String get guide_desc_difficulty_1 => '쉬움, 보통, 어려움 난이도로 선택 가능합니다.';

  @override
  String get guide_desc_difficulty_2 => '난이도가 높아질수록 초기에 채워진 숫자의 개수가 줄어듭니다.';

  @override
  String get guide_desc_difficulty_3 => '💡 힌트 사용 횟수나 시간 제한은 난이도별로 달라질 수 있습니다.';

  @override
  String get guide_title_mission => '🗓️ 미션 안내';

  @override
  String get guide_desc_mission_1 => '일일 미션 달력을 통해 매일 새로운 퍼즐에 도전할 수 있습니다.';

  @override
  String get guide_desc_mission_2 => '미션을 완료하고 특별한 보상을 받아보세요!';

  @override
  String get guide_desc_mission_3 => '🎁 보상: 미션을 완료하면 특별 테마나 프로필 아이콘을 해제할 수 있습니다.';

  @override
  String get home_header_instruction => '아이콘 클릭 후 설정 ☞';

  @override
  String get home_difficulty_title => '난이도를 선택하세요';

  @override
  String get difficulty_easy => '쉬움';

  @override
  String get difficulty_easy_subtitle => '처음 도전하는 분께 추천!';

  @override
  String get difficulty_normal => '보통';

  @override
  String get difficulty_normal_subtitle => '적당한 난이도로 두뇌 훈련';

  @override
  String get difficulty_hard => '어려움';

  @override
  String get difficulty_hard_subtitle => '퍼즐 마스터에 도전하세요!';

  @override
  String get difficulty_extreme => '지옥';

  @override
  String get difficulty_extreme_subtitle => '힌트와 채우기 금지, 단 3개의 하트만!';

  @override
  String get info_app_bar_title => '앱 정보';

  @override
  String get info_app_name => '모두의 즐거움! Koofy';

  @override
  String get info_section_legal => '법적 고지';

  @override
  String get info_row_version_title => '앱 버전';

  @override
  String get info_row_developer_title => '개발자';

  @override
  String get info_row_email_title => '문의 이메일';

  @override
  String get info_link_privacy => '개인정보 처리방침';

  @override
  String get info_link_terms => '이용 약관';

  @override
  String mission_app_bar_month_format(Object month, Object year) {
    return '$year년 $month월 미션';
  }

  @override
  String get mission_legend_available => '도전 가능';

  @override
  String get mission_legend_cleared => '도전 성공';

  @override
  String get mission_legend_unreleased => '미공개';

  @override
  String get mission_weekday_sun => '일';

  @override
  String get mission_weekday_mon => '월';

  @override
  String get mission_weekday_tue => '화';

  @override
  String get mission_weekday_wed => '수';

  @override
  String get mission_weekday_thu => '목';

  @override
  String get mission_weekday_fri => '금';

  @override
  String get mission_weekday_sat => '토';

  @override
  String get mission_dialog_title => '일일 미션 시작';

  @override
  String mission_dialog_date_info_format(Object day, Object month, Object year) {
    return '$year년 $month월 $day일 미션!';
  }

  @override
  String get mission_dialog_difficulty_random => '난이도 : 랜덤';

  @override
  String get mission_dialog_challenge_question => '도전하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get mission_dialog_start => '시작';

  @override
  String get overlay_game_over_title => '게임 오버';

  @override
  String get overlay_game_over_content => '하트를 모두 소진했습니다.';

  @override
  String get overlay_dialog_confirm => '확인';

  @override
  String get overlay_complete_title => '축하합니다!';

  @override
  String overlay_complete_content_format(Object time) {
    return '퍼즐을 완성했습니다 🎉\n시간: $time';
  }

  @override
  String get new_game => '새 게임';

  @override
  String get home => '홈';

  @override
  String get footer_label_mission => '미션';

  @override
  String get footer_label_guide => '가이드';

  @override
  String get footer_label_info => '정보';

  @override
  String get header_loading => '광고 로드 중';

  @override
  String get theme => '테마 선택';

  @override
  String get game_header_level => '난이도';

  @override
  String get game_header_time => '시간';

  @override
  String get game_button_hint => '힌트';

  @override
  String get game_button_note => '메모';

  @override
  String get game_button_auto_fill => '채우기';

  @override
  String get sound_title_main => '사운드 설정';

  @override
  String get sound_button_close_tooltip => '닫기';

  @override
  String get sound_section_bgm_title => '배경음악';

  @override
  String get sound_section_sfx_title => '효과음';

  @override
  String get sound_label_volume => '볼륨';

  @override
  String sound_label_percent(Object percent) {
    return '$percent%';
  }

  @override
  String get sound_switch_on => '켜짐';

  @override
  String get sound_switch_off => '꺼짐';

  @override
  String get game_error_invalid_number => '잘못된 숫자입니다!';

  @override
  String get game_error_no_hints => '힌트가 모두 소진되었습니다';

  @override
  String get game_autofill_none => '자동 채우기할 수 있는 칸이 없습니다.';

  @override
  String get dialog_confirm_exit_title => '홈으로 돌아가시겠습니까?';

  @override
  String get dialog_confirm_exit_content => '현재 게임이 종료됩니다.';

  @override
  String get exit => '종료';
}
