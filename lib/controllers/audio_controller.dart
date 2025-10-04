import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

/// 앱 전역 사운드 컨트롤러
/// BGM / SFX 설정을 관리하고 AudioService를 통해 실제 재생을 제어합니다.
class AudioController extends ChangeNotifier {
  static const String _bgmEnabledKey = 'bgm_enabled';
  static const String _bgmVolumeKey = 'bgm_volume';
  static const String _sfxEnabledKey = 'sfx_enabled';
  static const String _sfxVolumeKey = 'sfx_volume';

  final AudioService _audioService = AudioService();

  bool _bgmEnabled = true;
  double _bgmVolume = 1.0;
  bool _sfxEnabled = true;
  double _sfxVolume = 1.0;

  String? _currentBgm;
  bool _isInGame = false;

  AudioController() {
    _loadSettings();
  }

  bool get bgmEnabled => _bgmEnabled;
  double get bgmVolume => _bgmVolume;
  bool get sfxEnabled => _sfxEnabled;
  double get sfxVolume => _sfxVolume;

  /// -------------------------------
  /// 설정 불러오기 및 초기화
  /// -------------------------------
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _bgmEnabled = prefs.getBool(_bgmEnabledKey) ?? true;
    _bgmVolume = prefs.getDouble(_bgmVolumeKey) ?? 1.0;
    _sfxEnabled = prefs.getBool(_sfxEnabledKey) ?? true;
    _sfxVolume = prefs.getDouble(_sfxVolumeKey) ?? 1.0;

    _audioService
      ..setBgmVolume(_bgmVolume)
      ..setSfxVolume(_sfxVolume);

    if (_bgmEnabled) {
      _updateBgmState();
    } else {
      _audioService.pauseBgm();
    }
  }

  /// -------------------------------
  /// 설정 변경 관련 메서드
  /// -------------------------------
  Future<void> setBgmEnabled(bool enabled) async {
    _bgmEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bgmEnabledKey, enabled);

    if (enabled) {
        if (_currentBgm != null) {
        // 이미 곡 정보가 있으면 resume
        _audioService.resumeBgm();
        } else {
        // 곡 정보가 없으면 새로 play
        _updateBgmState();
        }
    } else {
        _audioService.pauseBgm();
    }

    notifyListeners();
  }

  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bgmVolumeKey, _bgmVolume);
    _audioService.setBgmVolume(_bgmVolume);
    notifyListeners(); // ✅ 추가
    }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sfxEnabledKey, enabled);

    // 🔊 SFX 관련 플레이어 상태 갱신 (필요 시)
    if (!enabled) {
        // 음소거면 즉시 효과음 중단
        _audioService.setSfxVolume(0);
    } else {
        // 다시 활성화하면 기존 볼륨 복원
        _audioService.setSfxVolume(_sfxVolume);
    }

    notifyListeners(); // ✅ UI 갱신 필수
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sfxVolumeKey, _sfxVolume);
    _audioService.setSfxVolume(_sfxVolume);
    notifyListeners(); // ✅ 추가
  }

  /// -------------------------------
  /// 재생 관련
  /// -------------------------------
  void playSfx(String assetName) {
    if (_sfxEnabled) {
      _audioService.playSfx(assetName, volume: _sfxVolume);
    }
  }

  void _updateBgmState() {
    if (!_bgmEnabled) {
      _audioService.pauseBgm();
      _currentBgm = null;
      return;
    }

    final nextTrack = _isInGame ? SoundFiles.playBgm : SoundFiles.cuteMainBgm;
    if (_currentBgm == nextTrack) return;

    _currentBgm = nextTrack;
    _audioService.playBgm(_currentBgm!, volume: _bgmVolume, loop: true);
  }

  /// -------------------------------
  /// 게임 상태 전환
  /// -------------------------------
  void playGameBgm() {
    if (!_isInGame) {
      _isInGame = true;
      _updateBgmState();
      notifyListeners();
    }
  }

  void stopGameBgm() {
    if (_isInGame) {
      _isInGame = false;
      _updateBgmState();
      notifyListeners();
    }
  }

  /// -------------------------------
  /// 포커스 및 앱 상태 제어
  /// -------------------------------
  void pauseAll() => _audioService.pauseBgm();

  void resumeAll() {
    if (_bgmEnabled) _audioService.resumeBgm();
  }

  void stopAll() {
    _currentBgm = null;
    _isInGame = false;
    _audioService.stopBgm();
  }
}