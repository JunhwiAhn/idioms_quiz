import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sfx { correct, wrong, clear, clearVoice, perfect }
enum Bgm { home, quiz }

String _sfxAsset(Sfx s) => switch (s) {
      Sfx.correct => 'audio/sfx_correct.mp3',
      Sfx.wrong => 'audio/sfx_wrong.mp3',
      Sfx.clear => 'audio/sfx_clear.mp3',
      Sfx.clearVoice => 'audio/sfx_clear_voice.mp3',
      Sfx.perfect => 'audio/sfx_perfect.mp3',
    };

String _bgmAsset(Bgm b) => switch (b) {
      Bgm.home => 'audio/bgm_home.mp3',
      Bgm.quiz => 'audio/bgm_quiz.mp3',
    };

/// Singleton wrapper around audioplayers with graceful degradation.
/// Autoplay is blocked on web until the user interacts; we lazily begin
/// BGM on the first call that follows a user gesture.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: 'bgm');
  Bgm? _currentBgm;
  bool _muted = false;
  double _volume = 0.4;
  bool _loaded = false;

  bool get muted => _muted;
  double get volume => _volume;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('audio_muted') ?? false;
    _volume = prefs.getDouble('audio_volume') ?? 0.4;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_muted ? 0 : _volume);
  }

  Future<void> setMuted(bool v) async {
    _muted = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', v);
    await _bgmPlayer.setVolume(v ? 0 : _volume);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0, 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_volume', _volume);
    if (!_muted) await _bgmPlayer.setVolume(_volume);
  }

  Future<void> playBgm(Bgm bgm) async {
    await load();
    if (_currentBgm == bgm) return;
    _currentBgm = bgm;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(
        AssetSource(_bgmAsset(bgm)),
        volume: _muted ? 0 : _volume,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('BGM playback failed: $e');
    }
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    await _bgmPlayer.stop();
  }

  /// Fires and forgets a one-shot SFX on its own player instance so it
  /// can overlap with BGM or other SFX.
  Future<void> playSfx(Sfx s, {double multiplier = 1.0}) async {
    if (_muted) return;
    try {
      final p = AudioPlayer();
      p.setReleaseMode(ReleaseMode.release);
      await p.play(
        AssetSource(_sfxAsset(s)),
        volume: (_volume * multiplier).clamp(0.0, 1.0),
      );
      p.onPlayerComplete.listen((_) => p.dispose());
    } catch (e) {
      if (kDebugMode) debugPrint('SFX playback failed: $e');
    }
  }
}
