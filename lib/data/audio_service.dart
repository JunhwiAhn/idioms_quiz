import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sfx { correct, wrong, clear, modeStart }

String _sfxAsset(Sfx s) => switch (s) {
  Sfx.correct => 'audio/sfx_correct.mp3',
  Sfx.wrong => 'audio/sfx_wrong.mp3',
  Sfx.clear => 'audio/sfx_clear.mp3',
  Sfx.modeStart => 'audio/mode_start.mp3',
};

/// Singleton wrapper around audioplayers with graceful degradation.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  bool _muted = false;
  double _volume = 0.4;
  bool _loaded = false;

  // Small reusable pool instead of spinning up a new native AudioPlayer per
  // SFX call; round-robins so overlapping SFX still play concurrently.
  static const int _poolSize = 3;
  final List<AudioPlayer> _pool = List.generate(
    _poolSize,
    (_) => AudioPlayer()..setReleaseMode(ReleaseMode.stop),
  );
  int _nextPlayer = 0;

  bool get muted => _muted;
  double get volume => _volume;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('audio_muted') ?? false;
    _volume = prefs.getDouble('audio_volume') ?? 0.4;
  }

  Future<void> setMuted(bool v) async {
    _muted = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', v);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0, 1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_volume', _volume);
  }

  /// Fires and forgets a one-shot SFX using a pooled player so it can
  /// overlap with other SFX without allocating a new native player each time.
  Future<void> playSfx(Sfx s, {double multiplier = 1.0}) async {
    if (_muted) return;
    try {
      final p = _pool[_nextPlayer];
      _nextPlayer = (_nextPlayer + 1) % _poolSize;
      await p.stop();
      await p.play(
        AssetSource(_sfxAsset(s)),
        volume: (_volume * multiplier).clamp(0.0, 1.0),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SFX playback failed: $e');
    }
  }
}
