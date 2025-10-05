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

/// 배경음악(BGM)과 효과음(SFX)을 중앙에서 관리하는 서비스
class AudioService {
  // 싱글톤 패턴
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  
  // AudioPlayer 인스턴스 분리
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _bgmVolume = 1.0;
  double _sfxVolume = 1.0;
  String? _currentBgm;

  // Ducking state for SFX playback (to keep BGM audible but lowered)
  bool _isDucking = false;
  int _duckNest = 0; // handle overlapping SFX
  double _preDuckBgmVolume = 1.0;

  AudioService._internal() {
    // ⭐️ 최적화: BGM과 SFX의 오디오 포커스 설정을 분리합니다.
    _initAudioContext();
  }
  
  void _initAudioContext() {
  // 🎵 BGM용 컨텍스트
    final bgmContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    );
    _bgmPlayer.setAudioContext(bgmContext);

    // 🔊 SFX용 컨텍스트
    final sfxContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        // Use media/music stream so device "Media volume" controls SFX audibility
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient, // ✅ ambient는 mixWithOthers 제거
        options: {},
      ),
    );
    _sfxPlayer.setAudioContext(sfxContext);
  }

  /// BGM(배경음악) 재생, loop 기본 true
  Future<void> playBgm(String fileName, {double? volume, bool loop = true}) async {
    if (_currentBgm == fileName) {
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

  /// SFX(효과음) 재생 - 저지연 + BGM 덕킹(옵션)
  Future<void> playSfx(String fileName, {double? volume, bool duckBgm = true}) async {
    if (volume != null) {
      _sfxVolume = volume.clamp(0.0, 1.0);
    }
    if (_sfxVolume <= 0) {
      return; // muted
    }

    await _sfxPlayer.setVolume(_sfxVolume);

    // 덕킹: 효과음이 시작될 때 BGM 볼륨을 잠시 낮췄다가, 재생이 끝나면 복원
    if (duckBgm && _currentBgm != null) {
      await _beginDuck();
    }

    // 저지연 재생 - 효과음 겹침에도 끊김 없이 재생
    await _sfxPlayer.play(
      AssetSource('sounds/$fileName'),
      volume: _sfxVolume,
      mode: PlayerMode.lowLatency,
    );

    // 재생 종료 후 덕킹 해제
    _sfxPlayer.onPlayerComplete.first.then((_) async {
      if (duckBgm && _currentBgm != null) {
        await _endDuck();
      }
    });
  }

  /// SFX 볼륨 설정 (0.0 ~ 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  /// 현재 볼륨 값
  double get bgmVolume => _bgmVolume;
  double get sfxVolume => _sfxVolume;

  /// BGM 덕킹 시작 (부드럽게 낮춤)
  Future<void> _beginDuck({double to = 0.35, Duration fade = const Duration(milliseconds: 120)}) async {
    _duckNest++;
    if (_isDucking) return;
    _isDucking = true;

    _preDuckBgmVolume = _bgmVolume;
    final steps = 6;
    final stepDelay = Duration(milliseconds: fade.inMilliseconds ~/ steps);
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = _preDuckBgmVolume + (to - _preDuckBgmVolume) * t;
      await _bgmPlayer.setVolume(v);
      await Future.delayed(stepDelay);
    }
  }

  /// BGM 덕킹 종료 (부드럽게 복원)
  Future<void> _endDuck({Duration fade = const Duration(milliseconds: 160)}) async {
    if (_duckNest > 0) _duckNest--;
    if (_duckNest > 0) return; // 다른 SFX가 아직 재생 중

    final start = _preDuckBgmVolume <= 0 ? 0.0 : await Future.value(null) == null ? null : null; // keep lints calm
    // 복원은 _bgmVolume(사용자 설정값)을 기준으로
    final from = _preDuckBgmVolume > 0 ? _preDuckBgmVolume : _bgmVolume * 0.35;
    final target = _bgmVolume;

    final steps = 6;
    final stepDelay = Duration(milliseconds: fade.inMilliseconds ~/ steps);
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      final v = from + (target - from) * t;
      await _bgmPlayer.setVolume(v);
      await Future.delayed(stepDelay);
    }
    _isDucking = false;
  }

  /// 리소스 해제
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}
