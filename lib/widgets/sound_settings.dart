import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/audio_controller.dart';
import '../services/audio_service.dart'; // SFX 재생을 위해 SoundFiles가 필요할 수 있습니다.

/// 사운드 설정 조정용 팝업 위젯
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
    // AudioController의 상태 변화를 감지합니다.
    final audioController = context.watch<AudioController>();

    // 상태를 위젯의 State가 아닌, Controller에서 직접 가져옵니다.
    final bool bgmEnabled = audioController.bgmEnabled;
    final double bgmVolume = audioController.bgmVolume;
    final bool sfxEnabled = audioController.sfxEnabled;
    final double sfxVolume = audioController.sfxVolume;

    return Material(
      // Dialog처럼 사용하기 위해 배경을 투명하게 설정합니다.
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
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
                  const Text(
                    'Sound Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _handleClose(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 1. BGM 설정 ---
              _buildSoundSettingRow(
                context,
                title: 'BGM (배경음악)',
                isEnabled: bgmEnabled,
                volume: bgmVolume,
                onToggle: (enabled) {
                  audioController.setBgmEnabled(enabled);
                },
                onVolumeChanged: (volume) {
                  audioController.setBgmVolume(volume);
                },
              ),
              const SizedBox(height: 24),

              // --- 2. SFX 설정 ---
              _buildSoundSettingRow(
                context,
                title: 'SFX (효과음)',
                isEnabled: sfxEnabled,
                volume: sfxVolume,
                onToggle: (enabled) {
                  audioController.setSfxEnabled(enabled);
                },
                onVolumeChanged: (volume) {
                  // SFX 볼륨 조절 시 효과음을 재생하여 즉시 피드백을 제공합니다.
                  audioController.setSfxVolume(volume);
                  audioController.playSfx(SoundFiles.click);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BGM/SFX 설정 섹션을 재사용 가능한 위젯으로 분리
  Widget _buildSoundSettingRow(
    BuildContext context, {
    required String title,
    required bool isEnabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onVolumeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Switch.adaptive(
              value: isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
        Slider(
          value: volume,
          onChanged: isEnabled ? onVolumeChanged : null, // 비활성화 시 슬라이더 잠금
          min: 0.0,
          max: 1.0,
          // BGM이 꺼져 있으면 회색으로 표시
          activeColor: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
      ],
    );
  }
}