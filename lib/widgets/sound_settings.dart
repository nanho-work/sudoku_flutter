import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audio_controller.dart';
import '../services/audio_service.dart'; // SoundFiles가 AudioService에 정의되어 있다고 가정합니다.
import '../controllers/theme_controller.dart'; // ThemeController import 추가

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

    // AudioController의 상태 변화를 감지합니다.
    final audioController = context.watch<AudioController>();

    final bool bgmEnabled = audioController.bgmEnabled;
    final double bgmVolume = audioController.bgmVolume;
    final bool sfxEnabled = audioController.sfxEnabled;
    final double sfxVolume = audioController.sfxVolume;

    // 다크 테마를 적용하고 액센트 색상을 지정하여 디자인을 개선합니다.
    return Theme(
      data: ThemeData.dark().copyWith(
        // 활성화된 요소(스위치, 슬라이더)에 사용할 주 색상(액센트) 지정
        colorScheme: ColorScheme.dark(
          primary: colors.accent,
          surface: colors.appBar,
        ),
      ),
      child: Material(
        // Dialog처럼 사용하기 위해 배경을 투명하게 설정합니다.
        color: colors.background.withOpacity(0.8),
        child: Center(
          child: Container(
            width: 340, // 너비를 약간 넓게 조정
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
            // 다크 모드 및 고급스러운 컨테이너 스타일 적용
            decoration: BoxDecoration(
              color: colors.surface, // 짙은 배경색
              borderRadius: BorderRadius.circular(20), // 둥근 모서리
              border: Border.all(color: colors.accent.withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 헤더 (제목 및 닫기 버튼) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '사운드 설정',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900, // 더 두꺼운 글씨체
                        color: colors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.textPrimary, size: 28),
                      onPressed: () => _handleClose(context),
                      tooltip: '닫기',
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // --- 1. BGM 설정 ---
                _buildSoundSettingRow(
                  context,
                  title: 'BGM (배경음악)',
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
                Divider(color: colors.appBar, height: 28, thickness: 0.5),

                // --- 2. SFX 설정 ---
                _buildSoundSettingRow(
                  context,
                  title: 'SFX (효과음)',
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
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
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
    final Color contentColor = isEnabled ? colors.textPrimary : colors.textSecondary;
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
                Icon(icon, color: contentColor, size: 24), // 아이콘 크기 조정
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: contentColor,
                  ),
                ),
              ],
            ),
            Switch.adaptive(
              value: isEnabled,
              onChanged: onToggle,
              activeColor: activeColor,
              inactiveTrackColor: colors.card,
            ),
          ],
        ),
        const SizedBox(height: 8),

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
                  fontSize: 15,
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
