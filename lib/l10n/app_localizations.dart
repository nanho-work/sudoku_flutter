import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @guide_title_main.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get guide_title_main;

  /// No description provided for @guide_title_goal.
  ///
  /// In en, this message translates to:
  /// **'🎯 Game Goal'**
  String get guide_title_goal;

  /// No description provided for @guide_desc_goal_1.
  ///
  /// In en, this message translates to:
  /// **'The goal is to complete a 9x9 Sudoku board.'**
  String get guide_desc_goal_1;

  /// No description provided for @guide_desc_goal_2.
  ///
  /// In en, this message translates to:
  /// **'Fill in blank cells so that no number repeats in any row, column, or 3x3 box.'**
  String get guide_desc_goal_2;

  /// No description provided for @guide_desc_goal_3.
  ///
  /// In en, this message translates to:
  /// **'Once all cells are filled correctly, you win!'**
  String get guide_desc_goal_3;

  /// No description provided for @guide_title_rules.
  ///
  /// In en, this message translates to:
  /// **'📘 Game Rules'**
  String get guide_title_rules;

  /// No description provided for @guide_rule_row_title.
  ///
  /// In en, this message translates to:
  /// **'1. Row Rule'**
  String get guide_rule_row_title;

  /// No description provided for @guide_rule_row_desc.
  ///
  /// In en, this message translates to:
  /// **'Each row must contain the numbers 1–9 without repetition.'**
  String get guide_rule_row_desc;

  /// No description provided for @guide_rule_col_title.
  ///
  /// In en, this message translates to:
  /// **'2. Column Rule'**
  String get guide_rule_col_title;

  /// No description provided for @guide_rule_col_desc.
  ///
  /// In en, this message translates to:
  /// **'Each column must also contain the numbers 1–9 without repetition.'**
  String get guide_rule_col_desc;

  /// No description provided for @guide_rule_box_title.
  ///
  /// In en, this message translates to:
  /// **'3. 3x3 Box Rule'**
  String get guide_rule_box_title;

  /// No description provided for @guide_rule_box_desc.
  ///
  /// In en, this message translates to:
  /// **'Each of the nine 3x3 boxes must include the numbers 1–9 without duplicates.'**
  String get guide_rule_box_desc;

  /// No description provided for @guide_title_control.
  ///
  /// In en, this message translates to:
  /// **'⚙️ Controls'**
  String get guide_title_control;

  /// No description provided for @guide_desc_control_1.
  ///
  /// In en, this message translates to:
  /// **'Tap a blank cell and use the number pad below to enter numbers.'**
  String get guide_desc_control_1;

  /// No description provided for @guide_desc_control_2.
  ///
  /// In en, this message translates to:
  /// **'Errors are shown automatically, and you can use hints for help.'**
  String get guide_desc_control_2;

  /// No description provided for @guide_desc_control_3.
  ///
  /// In en, this message translates to:
  /// **'Long-press to erase a number or swipe to move quickly.'**
  String get guide_desc_control_3;

  /// No description provided for @guide_title_error.
  ///
  /// In en, this message translates to:
  /// **'🚫 Error Display'**
  String get guide_title_error;

  /// No description provided for @guide_desc_error_1.
  ///
  /// In en, this message translates to:
  /// **'Wrong numbers are highlighted in red immediately.'**
  String get guide_desc_error_1;

  /// No description provided for @guide_desc_error_2.
  ///
  /// In en, this message translates to:
  /// **'You can toggle error display on or off in the settings.'**
  String get guide_desc_error_2;

  /// No description provided for @guide_desc_error_3.
  ///
  /// In en, this message translates to:
  /// **'Be careful—too many errors may limit hint usage.'**
  String get guide_desc_error_3;

  /// No description provided for @guide_title_stats.
  ///
  /// In en, this message translates to:
  /// **'📊 Statistics'**
  String get guide_title_stats;

  /// No description provided for @guide_desc_stats_1.
  ///
  /// In en, this message translates to:
  /// **'After completing a puzzle, view your play time, accuracy, and hint usage.'**
  String get guide_desc_stats_1;

  /// No description provided for @guide_desc_stats_2.
  ///
  /// In en, this message translates to:
  /// **'Statistics are categorized by difficulty so you can track your progress.'**
  String get guide_desc_stats_2;

  /// No description provided for @guide_title_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Levels'**
  String get guide_title_difficulty;

  /// No description provided for @guide_desc_difficulty_1.
  ///
  /// In en, this message translates to:
  /// **'You can choose among Easy, Normal, and Hard levels.'**
  String get guide_desc_difficulty_1;

  /// No description provided for @guide_desc_difficulty_2.
  ///
  /// In en, this message translates to:
  /// **'Higher levels have fewer pre-filled numbers.'**
  String get guide_desc_difficulty_2;

  /// No description provided for @guide_desc_difficulty_3.
  ///
  /// In en, this message translates to:
  /// **'💡 Hint limits and time constraints may vary by difficulty.'**
  String get guide_desc_difficulty_3;

  /// No description provided for @guide_title_mission.
  ///
  /// In en, this message translates to:
  /// **'🗓️ Daily Mission'**
  String get guide_title_mission;

  /// No description provided for @guide_desc_mission_1.
  ///
  /// In en, this message translates to:
  /// **'Challenge yourself with a new puzzle every day on the mission calendar.'**
  String get guide_desc_mission_1;

  /// No description provided for @guide_desc_mission_2.
  ///
  /// In en, this message translates to:
  /// **'Complete missions to earn special rewards!'**
  String get guide_desc_mission_2;

  /// No description provided for @guide_desc_mission_3.
  ///
  /// In en, this message translates to:
  /// **'🎁 Rewards: Unlock exclusive themes or profile icons by completing missions.'**
  String get guide_desc_mission_3;

  /// No description provided for @home_header_instruction.
  ///
  /// In en, this message translates to:
  /// **'Tap the icon to open settings ☞'**
  String get home_header_instruction;

  /// No description provided for @home_difficulty_title.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get home_difficulty_title;

  /// No description provided for @difficulty_easy_title.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficulty_easy_title;

  /// No description provided for @difficulty_easy_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended for beginners!'**
  String get difficulty_easy_subtitle;

  /// No description provided for @difficulty_normal_title.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get difficulty_normal_title;

  /// No description provided for @difficulty_normal_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Train your brain at a balanced level'**
  String get difficulty_normal_subtitle;

  /// No description provided for @difficulty_hard_title.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficulty_hard_title;

  /// No description provided for @difficulty_hard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Challenge yourself like a puzzle master!'**
  String get difficulty_hard_subtitle;

  /// No description provided for @info_app_bar_title.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get info_app_bar_title;

  /// No description provided for @info_app_name.
  ///
  /// In en, this message translates to:
  /// **'Everyone’s Fun! Koofy'**
  String get info_app_name;

  /// No description provided for @info_section_legal.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get info_section_legal;

  /// No description provided for @info_row_version_title.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get info_row_version_title;

  /// No description provided for @info_row_developer_title.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get info_row_developer_title;

  /// No description provided for @info_row_email_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get info_row_email_title;

  /// No description provided for @info_link_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get info_link_privacy;

  /// No description provided for @info_link_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get info_link_terms;

  /// No description provided for @mission_app_bar_month_format.
  ///
  /// In en, this message translates to:
  /// **'Missions for {month}, {year}'**
  String mission_app_bar_month_format(Object month, Object year);

  /// No description provided for @mission_legend_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get mission_legend_available;

  /// No description provided for @mission_legend_cleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get mission_legend_cleared;

  /// No description provided for @mission_legend_unreleased.
  ///
  /// In en, this message translates to:
  /// **'Unreleased'**
  String get mission_legend_unreleased;

  /// No description provided for @mission_weekday_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get mission_weekday_sun;

  /// No description provided for @mission_weekday_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mission_weekday_mon;

  /// No description provided for @mission_weekday_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get mission_weekday_tue;

  /// No description provided for @mission_weekday_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get mission_weekday_wed;

  /// No description provided for @mission_weekday_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get mission_weekday_thu;

  /// No description provided for @mission_weekday_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get mission_weekday_fri;

  /// No description provided for @mission_weekday_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get mission_weekday_sat;

  /// No description provided for @mission_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Start Daily Mission'**
  String get mission_dialog_title;

  /// No description provided for @mission_dialog_date_info_format.
  ///
  /// In en, this message translates to:
  /// **'Mission on {month}/{day}/{year}!'**
  String mission_dialog_date_info_format(Object day, Object month, Object year);

  /// No description provided for @mission_dialog_difficulty_random.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: Random'**
  String get mission_dialog_difficulty_random;

  /// No description provided for @mission_dialog_challenge_question.
  ///
  /// In en, this message translates to:
  /// **'Do you want to start the challenge?'**
  String get mission_dialog_challenge_question;

  /// No description provided for @mission_dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get mission_dialog_cancel;

  /// No description provided for @mission_dialog_start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mission_dialog_start;

  /// No description provided for @overlay_game_over_title.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get overlay_game_over_title;

  /// No description provided for @overlay_game_over_content.
  ///
  /// In en, this message translates to:
  /// **'You’ve run out of hearts.'**
  String get overlay_game_over_content;

  /// No description provided for @overlay_dialog_confirm.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get overlay_dialog_confirm;

  /// No description provided for @overlay_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get overlay_complete_title;

  /// No description provided for @overlay_complete_content_format.
  ///
  /// In en, this message translates to:
  /// **'Puzzle completed 🎉\nTime: {time}'**
  String overlay_complete_content_format(Object time);

  /// No description provided for @overlay_dialog_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get overlay_dialog_home;

  /// No description provided for @overlay_dialog_new_game.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get overlay_dialog_new_game;

  /// No description provided for @footer_label_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get footer_label_home;

  /// No description provided for @footer_label_mission.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get footer_label_mission;

  /// No description provided for @footer_label_guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get footer_label_guide;

  /// No description provided for @footer_label_info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get footer_label_info;

  /// No description provided for @header_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading ads...'**
  String get header_loading;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get theme;

  /// No description provided for @game_header_level.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get game_header_level;

  /// No description provided for @game_header_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get game_header_time;

  /// No description provided for @game_button_new_game.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get game_button_new_game;

  /// No description provided for @game_button_hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get game_button_hint;

  /// No description provided for @game_button_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get game_button_note;

  /// No description provided for @game_button_auto_fill.
  ///
  /// In en, this message translates to:
  /// **'Auto Fill'**
  String get game_button_auto_fill;

  /// No description provided for @sound_title_main.
  ///
  /// In en, this message translates to:
  /// **'Sound Settings'**
  String get sound_title_main;

  /// No description provided for @sound_button_close_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get sound_button_close_tooltip;

  /// No description provided for @sound_section_bgm_title.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get sound_section_bgm_title;

  /// No description provided for @sound_section_sfx_title.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get sound_section_sfx_title;

  /// No description provided for @sound_label_volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get sound_label_volume;

  /// No description provided for @sound_label_percent.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String sound_label_percent(Object percent);

  /// No description provided for @sound_switch_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get sound_switch_on;

  /// No description provided for @sound_switch_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sound_switch_off;

  /// No description provided for @difficulty_easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficulty_easy;

  /// No description provided for @difficulty_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get difficulty_normal;

  /// No description provided for @difficulty_hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficulty_hard;

  /// No description provided for @game_error_invalid_number.
  ///
  /// In en, this message translates to:
  /// **'Invalid number!'**
  String get game_error_invalid_number;

  /// No description provided for @game_error_no_hints.
  ///
  /// In en, this message translates to:
  /// **'No hints remaining.'**
  String get game_error_no_hints;

  /// No description provided for @game_autofill_none.
  ///
  /// In en, this message translates to:
  /// **'No cells available for auto-fill.'**
  String get game_autofill_none;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
