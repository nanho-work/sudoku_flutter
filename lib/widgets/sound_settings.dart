import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audio_controller.dart';
import '../services/audio_service.dart'; // SoundFiles가 AudioService에 정의되어 있다고 가정합니다.
import '../controllers/theme_controller.dart'; // ThemeController import 추가
import 'package:sudoku_flutter/l10n/app_localizations.dart';

/// 사운드 설정 조정용 팝업 위젯 (UI 개선 버전)
class SoundSettingsWidget extends StatelessWidget {
  const SoundSettingsWidget({
    Key? key,
  }) : super(key: key);

  void _handleClose(BuildContext context) {
    // 팝업을 닫습니다.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // ThemeController에서 색상 테마를 가져옵니다.
    final themeController = Provider.of<ThemeController>(context);
    final colors = themeController.colors;
    final loc = AppLocalizations.of(context)!;

    // AudioController의 상태 변화를 감지합니다.
    final audioController = context.watch<AudioController>();

    final bool bgmEnabled = audioController.bgmEnabled;
    final double bgmVolume = audioController.bgmVolume;
    final bool sfxEnabled = audioController.sfxEnabled;
    final double sfxVolume = audioController.sfxVolume;

    // 다크 테마를 적용하고 액센트 색상을 지정하여 디자인을 개선합니다.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. BGM 설정 ---
        _buildSoundSettingRow(
          context,
          title: loc.sound_section_bgm_title,
          icon: Icons.music_note, // 아이콘 추가
          isEnabled: bgmEnabled,
          volume: bgmVolume,
          onToggle: (enabled) {
            audioController.setBgmEnabled(enabled);
          },
          onVolumeChanged: (volume) {
            audioController.setBgmVolume(volume);
          },
          colors: colors,
        ),
        
        // --- 구분선 추가 ---
        Divider(color: Colors.grey, height: 12, thickness: 0.5),

        // --- 2. SFX 설정 ---
        _buildSoundSettingRow(
          context,
          title: loc.sound_section_sfx_title,
          icon: Icons.volume_up, // 아이콘 추가
          isEnabled: sfxEnabled,
          volume: sfxVolume,
          onToggle: (enabled) {
            audioController.setSfxEnabled(enabled);
          },
          onVolumeChanged: (volume) {
            // SFX 볼륨 조절 시 효과음을 재생하여 즉시 피드백을 제공합니다.
            audioController.setSfxVolume(volume);
            // SoundFiles를 사용할 수 있도록 가정
            // TODO: `SoundFiles.click`이 정의된 파일을 import 해야 합니다.
            // audioController.playSfx(SoundFiles.click); 
          },
          colors: colors,
        ),
      ],
    );
  }

  // BGM/SFX 설정 섹션을 재사용 가능한 위젯으로 분리 (개선된 디자인)
  Widget _buildSoundSettingRow(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isEnabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onVolumeChanged,
    required dynamic colors,
  }) {
    // 테마 색상 및 활성화/비활성화 상태에 따른 색상 정의
    final Color activeColor = colors.accent;
    final Color inactiveColor = colors.placeholder;
    final Color contentColor = isEnabled ? colors.textMain : colors.textSub;
    final Color sliderActiveColor = isEnabled ? activeColor : inactiveColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 제목, 아이콘, 스위치 Row ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: contentColor, size: 16), // 아이콘 크기 조정
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: contentColor,
                  ),
                ),
              ],
            ),
            // 토글 사이즈 조절 
            Transform.scale(
              scale: 0.6,
              child: Switch.adaptive(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: activeColor,
                inactiveTrackColor: colors.textSub,
              ),
            ),
          ],
        ),

        // --- 볼륨 슬라이더 및 퍼센트 표시 Row ---
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                // 슬라이더 디자인 커스터마이징
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6.0,
                  thumbColor: sliderActiveColor,
                  activeTrackColor: sliderActiveColor.withOpacity(0.8),
                  inactiveTrackColor: inactiveColor.withOpacity(0.3),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                ),
                child: Slider(
                  value: volume,
                  onChanged: isEnabled ? onVolumeChanged : null, // 비활성화 시 슬라이더 잠금
                  min: 0.0,
                  max: 1.0,
                ),
              ),
            ),
            // 볼륨 퍼센트 표시 (UX 개선)
            Container(
              width: 50,
              alignment: Alignment.centerRight,
              child: Text(
                '${(volume * 100).toInt()}%',
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  // 숫자의 폭을 일정하게 유지하여 레이아웃이 흔들리는 것을 방지
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
