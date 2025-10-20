import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/audio_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../widgets/sound_settings.dart';
import '../../../widgets/theme_selector.dart';
import '../../../widgets/button_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🧩 왼쪽 타이틀 제거, 영어 텍스트 고정 배치
          Row(
            children: [
              Text(
                "Theme",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                style: buttonStyle(context),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const ThemeSelectorWidget(),
                  );
                },
                child: const Icon(Icons.palette_outlined, size: 28),
              ),
              const SizedBox(width: 20),
              Text(
                "Sound",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textMain,
                ),
              ),
              const SizedBox(width: 6),
              Consumer<AudioController>(
                builder: (context, audio, _) {
                  return ElevatedButton(
                    style: buttonStyle(context),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const SoundSettingsWidget(),
                      );
                    },
                    child: Icon(
                      audio.sfxEnabled ? Icons.volume_up : Icons.volume_off,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}