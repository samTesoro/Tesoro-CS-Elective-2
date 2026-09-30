import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

// Loops the background music from music/pokecenter.mp3.
class MusicService {
  static const _track = 'music/pokecenter.mp3';

  AudioPlayer? _player;
  Future<void>? _loading;
  bool _muted = false;
  bool _hidden = false;
  double _volume = 1;

  bool get isMuted => _muted;

  // Slider level from 0.0 to 1.0. Kept separately from mute so unmuting
  // returns to the level the user picked.
  double get volume => _volume;

  // What the player actually outputs.
  double get _effectiveVolume => _muted ? 0 : _volume;

  // Safe to call repeatedly: it does nothing once the song is playing.
  //
  // On web, Chrome blocks audio until the user interacts with the page. A
  // play attempt made before that never completes (it doesn't throw either),
  // so this checks the player's real state instead of remembering "already
  // started". The screen calls it on every tap, and the first tap after the
  // page is unlocked starts the music.
  Future<void> start() async {
    try {
      // Created lazily so nothing touches the audio plugin until playback is
      // actually requested. The file lives in music/, not assets/, so the
      // default 'assets/' prefix is cleared.
      final player = _player ??= AudioPlayer()
        ..audioCache = AudioCache(prefix: '');

      // Load the song once and keep it on loop.
      await (_loading ??= _load(player));

      if (_hidden || player.state == PlayerState.playing) return;
      await player.resume();
    } catch (e) {
      // Missing file or playback error: the app works without music.
      _loading = null;
      debugPrint('Background music could not start: $e');
    }
  }

  Future<void> _load(AudioPlayer player) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(_effectiveVolume);
    await player.setSource(AssetSource(_track));
  }

  // Muting changes the volume instead of stopping, so the song keeps its
  // place and picks up from there when unmuted.
  Future<void> toggleMute() async {
    _muted = !_muted;
    await _applyVolume();
  }

  // Moving the slider up while muted also unmutes, like most media players.
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    if (_volume > 0) _muted = false;
    await _applyVolume();
  }

  Future<void> _applyVolume() async {
    try {
      await _player?.setVolume(_effectiveVolume);
    } catch (e) {
      debugPrint('Could not change volume: $e');
    }
  }

  // Called when the app is minimized / the browser tab is hidden.
  Future<void> pause() async {
    _hidden = true;
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('Could not pause music: $e');
    }
  }

  // Called when the app comes back to the foreground.
  Future<void> resume() async {
    _hidden = false;
    if (_loading == null) return;
    await start();
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _loading = null;
  }
}
