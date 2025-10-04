import 'package:audioplayers/audioplayers.dart';

class SoundFiles {
  static const String click = 'click.mp3';
  static const String complete = 'complete.mp3';
  static const String cuteMainBgm = 'cute_main_bgm.mp3';
  static const String fail = 'fail.mp3';
  static const String gameover = 'gameover.mp3';
  static const String hint = 'hint.mp3';
  static const String playBgm = 'play_bgm.mp3';
  static const String success = 'success.mp3';
}

/// 배경음악(BGM)과 효과음(SFX)을 중앙에서 관리하는 서비스 (AudioController 스타일)
class AudioService {
  // 싱글톤 패턴
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;
  String? _currentBgm;

  /// BGM(배경음악) 재생, loop 기본 true
  Future<void> playBgm(String fileName, {double? volume, bool loop = true}) async {
    if (_currentBgm == fileName) {
      // 이미 재생 중인 BGM이면 무시
      return;
    }
    await stopBgm();
    _currentBgm = fileName;
    if (volume != null) {
      _bgmVolume = volume.clamp(0.0, 1.0);
    }
    await _bgmPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _bgmPlayer.play(AssetSource('sounds/$fileName'));
  }

  /// BGM 정지
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentBgm = null;
  }

  /// BGM 일시정지
  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  /// BGM 재개
  Future<void> resumeBgm() async {
    await _bgmPlayer.resume();
  }

  /// BGM 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  /// SFX(효과음) 재생, 항상 1회 재생
  Future<void> playSfx(String fileName, {double? volume}) async {
    if (volume != null) {
      _sfxVolume = volume.clamp(0.0, 1.0);
    }
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource('sounds/$fileName'), volume: _sfxVolume);
  }

  /// SFX 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  /// 현재 볼륨 값
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  /// 리소스 해제
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
