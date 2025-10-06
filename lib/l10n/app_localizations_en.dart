// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get guide_title_main => 'How to Play';

  @override
  String get guide_title_goal => '🎯 Game Goal';

  @override
  String get guide_desc_goal_1 => 'The goal is to complete a 9x9 Sudoku board.';

  @override
  String get guide_desc_goal_2 => 'Fill in blank cells so that no number repeats in any row, column, or 3x3 box.';

  @override
  String get guide_desc_goal_3 => 'Once all cells are filled correctly, you win!';

  @override
  String get guide_title_rules => '📘 Game Rules';

  @override
  String get guide_rule_row_title => '1. Row Rule';

  @override
  String get guide_rule_row_desc => 'Each row must contain the numbers 1–9 without repetition.';

  @override
  String get guide_rule_col_title => '2. Column Rule';

  @override
  String get guide_rule_col_desc => 'Each column must also contain the numbers 1–9 without repetition.';

  @override
  String get guide_rule_box_title => '3. 3x3 Box Rule';

  @override
  String get guide_rule_box_desc => 'Each of the nine 3x3 boxes must include the numbers 1–9 without duplicates.';

  @override
  String get guide_title_control => '⚙️ Controls';

  @override
  String get guide_desc_control_1 => 'Tap a blank cell and use the number pad below to enter numbers.';

  @override
  String get guide_desc_control_2 => 'Errors are shown automatically, and you can use hints for help.';

  @override
  String get guide_desc_control_3 => 'Long-press to erase a number or swipe to move quickly.';

  @override
  String get guide_title_error => '🚫 Error Display';

  @override
  String get guide_desc_error_1 => 'Wrong numbers are highlighted in red immediately.';

  @override
  String get guide_desc_error_2 => 'You can toggle error display on or off in the settings.';

  @override
  String get guide_desc_error_3 => 'Be careful—too many errors may limit hint usage.';

  @override
  String get guide_title_stats => '📊 Statistics';

  @override
  String get guide_desc_stats_1 => 'After completing a puzzle, view your play time, accuracy, and hint usage.';

  @override
  String get guide_desc_stats_2 => 'Statistics are categorized by difficulty so you can track your progress.';

  @override
  String get guide_title_difficulty => 'Difficulty Levels';

  @override
  String get guide_desc_difficulty_1 => 'You can choose among Easy, Normal, and Hard levels.';

  @override
  String get guide_desc_difficulty_2 => 'Higher levels have fewer pre-filled numbers.';

  @override
  String get guide_desc_difficulty_3 => '💡 Hint limits and time constraints may vary by difficulty.';

  @override
  String get guide_title_mission => '🗓️ Daily Mission';

  @override
  String get guide_desc_mission_1 => 'Challenge yourself with a new puzzle every day on the mission calendar.';

  @override
  String get guide_desc_mission_2 => 'Complete missions to earn special rewards!';

  @override
  String get guide_desc_mission_3 => '🎁 Rewards: Unlock exclusive themes or profile icons by completing missions.';

  @override
  String get home_header_instruction => 'Tap the icon to open settings ☞';

  @override
  String get home_difficulty_title => 'Select Difficulty';

  @override
  String get difficulty_easy_title => 'Easy';

  @override
  String get difficulty_easy_subtitle => 'Recommended for beginners!';

  @override
  String get difficulty_normal_title => 'Normal';

  @override
  String get difficulty_normal_subtitle => 'Train your brain at a balanced level';

  @override
  String get difficulty_hard_title => 'Hard';

  @override
  String get difficulty_hard_subtitle => 'Challenge yourself like a puzzle master!';

  @override
  String get info_app_bar_title => 'App Info';

  @override
  String get info_app_name => 'Everyone’s Fun! Koofy';

  @override
  String get info_section_legal => 'Legal Notice';

  @override
  String get info_row_version_title => 'App Version';

  @override
  String get info_row_developer_title => 'Developer';

  @override
  String get info_row_email_title => 'Contact Email';

  @override
  String get info_link_privacy => 'Privacy Policy';

  @override
  String get info_link_terms => 'Terms of Service';

  @override
  String mission_app_bar_month_format(Object month, Object year) {
    return 'Missions for $month, $year';
  }

  @override
  String get mission_legend_available => 'Available';

  @override
  String get mission_legend_cleared => 'Cleared';

  @override
  String get mission_legend_unreleased => 'Unreleased';

  @override
  String get mission_weekday_sun => 'Sun';

  @override
  String get mission_weekday_mon => 'Mon';

  @override
  String get mission_weekday_tue => 'Tue';

  @override
  String get mission_weekday_wed => 'Wed';

  @override
  String get mission_weekday_thu => 'Thu';

  @override
  String get mission_weekday_fri => 'Fri';

  @override
  String get mission_weekday_sat => 'Sat';

  @override
  String get mission_dialog_title => 'Start Daily Mission';

  @override
  String mission_dialog_date_info_format(Object day, Object month, Object year) {
    return 'Mission on $month/$day/$year!';
  }

  @override
  String get mission_dialog_difficulty_random => 'Difficulty: Random';

  @override
  String get mission_dialog_challenge_question => 'Do you want to start the challenge?';

  @override
  String get mission_dialog_cancel => 'Cancel';

  @override
  String get mission_dialog_start => 'Start';

  @override
  String get overlay_game_over_title => 'Game Over';

  @override
  String get overlay_game_over_content => 'You’ve run out of hearts.';

  @override
  String get overlay_dialog_confirm => 'OK';

  @override
  String get overlay_complete_title => 'Congratulations!';

  @override
  String overlay_complete_content_format(Object time) {
    return 'Puzzle completed 🎉\nTime: $time';
  }

  @override
  String get overlay_dialog_home => 'Home';

  @override
  String get overlay_dialog_new_game => 'New Game';

  @override
  String get footer_label_home => 'Home';

  @override
  String get footer_label_mission => 'Mission';

  @override
  String get footer_label_guide => 'Guide';

  @override
  String get footer_label_info => 'Info';

  @override
  String get header_loading => 'Loading ads...';

  @override
  String get theme => 'Select Theme';

  @override
  String get game_header_level => 'Difficulty';

  @override
  String get game_header_time => 'Time';

  @override
  String get game_button_new_game => 'New Game';

  @override
  String get game_button_hint => 'Hint';

  @override
  String get game_button_note => 'Note';

  @override
  String get game_button_auto_fill => 'Auto Fill';

  @override
  String get sound_title_main => 'Sound Settings';

  @override
  String get sound_button_close_tooltip => 'Close';

  @override
  String get sound_section_bgm_title => 'Background Music';

  @override
  String get sound_section_sfx_title => 'Sound Effects';

  @override
  String get sound_label_volume => 'Volume';

  @override
  String sound_label_percent(Object percent) {
    return '$percent%';
  }

  @override
  String get sound_switch_on => 'On';

  @override
  String get sound_switch_off => 'Off';

  @override
  String get difficulty_easy => 'Easy';

  @override
  String get difficulty_normal => 'Normal';

  @override
  String get difficulty_hard => 'Hard';

  @override
  String get game_error_invalid_number => 'Invalid number!';

  @override
  String get game_error_no_hints => 'No hints remaining.';

  @override
  String get game_autofill_none => 'No cells available for auto-fill.';
}
