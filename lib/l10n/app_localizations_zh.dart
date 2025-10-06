// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get guide_title_main => '玩法说明';

  @override
  String get guide_title_goal => '🎯 游戏目标';

  @override
  String get guide_desc_goal_1 => '目标是完成一个9x9的数独棋盘。';

  @override
  String get guide_desc_goal_2 => '在空格中填写数字，确保同一行、列和3x3宫内的数字不重复。';

  @override
  String get guide_desc_goal_3 => '当所有格子正确填写后，游戏胜利！';

  @override
  String get guide_title_rules => '📘 规则说明';

  @override
  String get guide_rule_row_title => '1. 行规则';

  @override
  String get guide_rule_row_desc => '每一行必须包含1到9的数字且不能重复。';

  @override
  String get guide_rule_col_title => '2. 列规则';

  @override
  String get guide_rule_col_desc => '每一列也必须包含1到9的数字且不能重复。';

  @override
  String get guide_rule_box_title => '3. 3x3 宫格规则';

  @override
  String get guide_rule_box_desc => '每个3x3宫格都必须包含1到9的数字且不能重复。';

  @override
  String get guide_title_control => '⚙️ 操作方式';

  @override
  String get guide_desc_control_1 => '点击空白格并使用下方数字键盘输入数字。';

  @override
  String get guide_desc_control_2 => '错误会自动显示，你也可以使用提示功能获得帮助。';

  @override
  String get guide_desc_control_3 => '长按可以删除数字，滑动可以快速移动。';

  @override
  String get guide_title_error => '🚫 错误显示';

  @override
  String get guide_desc_error_1 => '输入错误的数字会立即以红色显示。';

  @override
  String get guide_desc_error_2 => '可以在设置中开启或关闭错误显示功能。';

  @override
  String get guide_desc_error_3 => '错误太多时，提示功能可能会受到限制。';

  @override
  String get guide_title_stats => '📊 统计信息';

  @override
  String get guide_desc_stats_1 => '完成游戏后，可以查看游戏时间、正确率和提示使用次数。';

  @override
  String get guide_desc_stats_2 => '统计会根据难度分类，方便你了解自己的进步。';

  @override
  String get guide_title_difficulty => '难度说明';

  @override
  String get guide_desc_difficulty_1 => '可以选择简单、普通或困难模式。';

  @override
  String get guide_desc_difficulty_2 => '难度越高，初始数字越少。';

  @override
  String get guide_desc_difficulty_3 => '💡 提示次数和时间限制会根据难度而变化。';

  @override
  String get guide_title_mission => '🗓️ 每日任务';

  @override
  String get guide_desc_mission_1 => '通过每日任务日历，每天挑战新的数独谜题。';

  @override
  String get guide_desc_mission_2 => '完成任务可获得特别奖励！';

  @override
  String get guide_desc_mission_3 => '🎁 奖励：完成任务后可解锁专属主题或头像图标。';

  @override
  String get home_header_instruction => '点击图标进入设置 ☞';

  @override
  String get home_difficulty_title => '请选择难度';

  @override
  String get difficulty_easy_title => '简单 (Easy)';

  @override
  String get difficulty_easy_subtitle => '推荐给初学者！';

  @override
  String get difficulty_normal_title => '普通 (Normal)';

  @override
  String get difficulty_normal_subtitle => '适中难度，锻炼大脑！';

  @override
  String get difficulty_hard_title => '困难 (Hard)';

  @override
  String get difficulty_hard_subtitle => '挑战成为数独大师！';

  @override
  String get info_app_bar_title => '应用信息';

  @override
  String get info_app_name => '大家的乐趣！Koofy';

  @override
  String get info_section_legal => '法律声明';

  @override
  String get info_row_version_title => '应用版本';

  @override
  String get info_row_developer_title => '开发者';

  @override
  String get info_row_email_title => '联系邮箱';

  @override
  String get info_link_privacy => '隐私政策';

  @override
  String get info_link_terms => '使用条款';

  @override
  String mission_app_bar_month_format(Object month, Object year) {
    return '$year年$month月任务';
  }

  @override
  String get mission_legend_available => '可挑战';

  @override
  String get mission_legend_cleared => '已完成';

  @override
  String get mission_legend_unreleased => '未公开';

  @override
  String get mission_weekday_sun => '日';

  @override
  String get mission_weekday_mon => '一';

  @override
  String get mission_weekday_tue => '二';

  @override
  String get mission_weekday_wed => '三';

  @override
  String get mission_weekday_thu => '四';

  @override
  String get mission_weekday_fri => '五';

  @override
  String get mission_weekday_sat => '六';

  @override
  String get mission_dialog_title => '开始每日任务';

  @override
  String mission_dialog_date_info_format(Object day, Object month, Object year) {
    return '$year年$month月$day日任务！';
  }

  @override
  String get mission_dialog_difficulty_random => '难度：随机';

  @override
  String get mission_dialog_challenge_question => '是否开始挑战？';

  @override
  String get mission_dialog_cancel => '取消';

  @override
  String get mission_dialog_start => '开始';

  @override
  String get overlay_game_over_title => '游戏结束';

  @override
  String get overlay_game_over_content => '所有心已用完。';

  @override
  String get overlay_dialog_confirm => '确定';

  @override
  String get overlay_complete_title => '恭喜！';

  @override
  String overlay_complete_content_format(Object time) {
    return '完成拼图 🎉\n时间：$time';
  }

  @override
  String get overlay_dialog_home => '主页';

  @override
  String get overlay_dialog_new_game => '新游戏';

  @override
  String get footer_label_home => '主页';

  @override
  String get footer_label_mission => '任务';

  @override
  String get footer_label_guide => '指南';

  @override
  String get footer_label_info => '信息';

  @override
  String get header_loading => '广告加载中...';

  @override
  String get theme => '选择主题';

  @override
  String get game_header_level => '难度';

  @override
  String get game_header_time => '时间';

  @override
  String get game_button_new_game => '新游戏';

  @override
  String get game_button_hint => '提示';

  @override
  String get game_button_note => '笔记';

  @override
  String get game_button_auto_fill => '自动填充';

  @override
  String get sound_title_main => '声音设置';

  @override
  String get sound_button_close_tooltip => '关闭';

  @override
  String get sound_section_bgm_title => '背景音乐';

  @override
  String get sound_section_sfx_title => '音效';

  @override
  String get sound_label_volume => '音量';

  @override
  String sound_label_percent(Object percent) {
    return '$percent%';
  }

  @override
  String get sound_switch_on => '开';

  @override
  String get sound_switch_off => '关';

  @override
  String get difficulty_easy => '简单';

  @override
  String get difficulty_normal => '普通';

  @override
  String get difficulty_hard => '困难';

  @override
  String get game_error_invalid_number => '数字无效！';

  @override
  String get game_error_no_hints => '提示已全部用完';

  @override
  String get game_autofill_none => '没有可自动填充的格子。';
}
