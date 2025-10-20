// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get guide_title_main => '遊び方';

  @override
  String get guide_title_goal => '🎯 ゲームの目的';

  @override
  String get guide_desc_goal_1 => '目標は9x9の数独盤を完成させることです。';

  @override
  String get guide_desc_goal_2 => '空白のマスに数字を入力し、同じ行・列・3x3ボックス内で重複しないようにします。';

  @override
  String get guide_desc_goal_3 => 'すべてのマスを正しく埋めるとクリアです！';

  @override
  String get guide_title_rules => '📘 ルール説明';

  @override
  String get guide_rule_row_title => '1. 行のルール';

  @override
  String get guide_rule_row_desc => '各行には1〜9の数字を重複なく配置します。';

  @override
  String get guide_rule_col_title => '2. 列のルール';

  @override
  String get guide_rule_col_desc => '各列にも1〜9の数字を重複なく配置します。';

  @override
  String get guide_rule_box_title => '3. 3x3ボックスのルール';

  @override
  String get guide_rule_box_desc => '9つの3x3ボックスそれぞれに1〜9の数字を重複なく配置します。';

  @override
  String get guide_title_control => '⚙️ 操作方法';

  @override
  String get guide_desc_control_1 => '空白のマスをタップし、下部の数字パッドで入力します。';

  @override
  String get guide_desc_control_2 => '間違いは自動的に表示され、ヒントを使うこともできます。';

  @override
  String get guide_desc_control_3 => '長押しで削除、スワイプで素早く移動できます。';

  @override
  String get guide_title_error => '🚫 エラー表示';

  @override
  String get guide_desc_error_1 => '間違った数字は赤く表示されます。';

  @override
  String get guide_desc_error_2 => '設定でエラー表示のオン・オフを切り替え可能です。';

  @override
  String get guide_desc_error_3 => 'エラーが多いとヒント使用が制限されます。';

  @override
  String get guide_title_stats => '📊 統計情報';

  @override
  String get guide_desc_stats_1 => 'ゲームクリア後、プレイ時間や正答率、ヒント使用回数を確認できます。';

  @override
  String get guide_desc_stats_2 => '統計は難易度ごとに分類されます。';

  @override
  String get guide_title_difficulty => '難易度';

  @override
  String get guide_desc_difficulty_1 => 'やさしい、ふつう、むずかしいから選べます。';

  @override
  String get guide_desc_difficulty_2 => '難易度が高いほど初期入力の数字が少なくなります。';

  @override
  String get guide_desc_difficulty_3 => '💡 ヒント数や制限時間は難易度によって異なります。';

  @override
  String get guide_title_mission => '🗓️ ミッション案内';

  @override
  String get guide_desc_mission_1 => 'デイリーミッションで毎日新しいパズルに挑戦！';

  @override
  String get guide_desc_mission_2 => 'ミッションをクリアして報酬をゲット！';

  @override
  String get guide_desc_mission_3 => '🎁 報酬：テーマやアイコンをアンロック。';

  @override
  String get home_header_instruction => 'アイコンをクリックして設定へ ☞';

  @override
  String get home_difficulty_title => '難易度を選択してください';

  @override
  String get difficulty_easy => 'かんたん';

  @override
  String get difficulty_easy_subtitle => '初心者におすすめ！';

  @override
  String get difficulty_normal => 'ふつう';

  @override
  String get difficulty_normal_subtitle => 'バランスの取れた難易度';

  @override
  String get difficulty_hard => 'むずかしい';

  @override
  String get difficulty_hard_subtitle => 'パズルマスターに挑戦！';

  @override
  String get difficulty_extreme => '地獄';

  @override
  String get difficulty_extreme_subtitle => 'ヒント・自動入力なし、ハート3つのみ！';

  @override
  String get info_app_bar_title => 'アプリ情報';

  @override
  String get info_app_name => 'みんなの楽しみ！Koofy';

  @override
  String get info_section_legal => '法的告知';

  @override
  String get info_row_version_title => 'アプリバージョン';

  @override
  String get info_row_developer_title => '開発者';

  @override
  String get info_row_email_title => 'お問い合わせ';

  @override
  String get info_link_privacy => 'プライバシーポリシー';

  @override
  String get info_link_terms => '利用規約';

  @override
  String mission_app_bar_month_format(Object month, Object year) {
    return '$year年$month月ミッション';
  }

  @override
  String get mission_legend_available => '挑戦可能';

  @override
  String get mission_legend_cleared => 'クリア済み';

  @override
  String get mission_legend_unreleased => '未公開';

  @override
  String get mission_weekday_sun => '日';

  @override
  String get mission_weekday_mon => '月';

  @override
  String get mission_weekday_tue => '火';

  @override
  String get mission_weekday_wed => '水';

  @override
  String get mission_weekday_thu => '木';

  @override
  String get mission_weekday_fri => '金';

  @override
  String get mission_weekday_sat => '土';

  @override
  String get mission_dialog_title => 'デイリーミッション開始';

  @override
  String mission_dialog_date_info_format(Object day, Object month, Object year) {
    return '$year年$month月$day日ミッション！';
  }

  @override
  String get mission_dialog_difficulty_random => '難易度：ランダム';

  @override
  String get mission_dialog_challenge_question => '挑戦しますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get mission_dialog_start => 'スタート';

  @override
  String get overlay_game_over_title => 'ゲームオーバー';

  @override
  String get overlay_game_over_content => 'ハートがなくなりました。';

  @override
  String get overlay_dialog_confirm => '確認';

  @override
  String get overlay_complete_title => 'おめでとうございます！';

  @override
  String overlay_complete_content_format(Object time) {
    return 'パズルをクリアしました 🎉\n時間：$time';
  }

  @override
  String get new_game => '新しいゲーム';

  @override
  String get home => 'ホーム';

  @override
  String get footer_label_mission => 'ミッション';

  @override
  String get footer_label_guide => 'ガイド';

  @override
  String get footer_label_info => '情報';

  @override
  String get header_loading => '広告読み込み中...';

  @override
  String get theme => 'テーマ選択';

  @override
  String get game_header_level => '難易度';

  @override
  String get game_header_time => '時間';

  @override
  String get game_button_hint => 'ヒント';

  @override
  String get game_button_note => 'メモ';

  @override
  String get game_button_auto_fill => '自動入力';

  @override
  String get sound_title_main => 'サウンド設定';

  @override
  String get sound_button_close_tooltip => '閉じる';

  @override
  String get sound_section_bgm_title => 'BGM';

  @override
  String get sound_section_sfx_title => '効果音';

  @override
  String get sound_label_volume => '音量';

  @override
  String sound_label_percent(Object percent) {
    return '$percent%';
  }

  @override
  String get sound_switch_on => 'オン';

  @override
  String get sound_switch_off => 'オフ';

  @override
  String get game_error_invalid_number => '無効な数字です！';

  @override
  String get game_error_no_hints => 'ヒントがすべてなくなりました';

  @override
  String get game_autofill_none => '自動入力できるマスがありません。';

  @override
  String get dialog_confirm_exit_title => 'ホームに戻りますか？';

  @override
  String get dialog_confirm_exit_content => '現在のゲームが終了します。';

  @override
  String get exit => '終了';
}
