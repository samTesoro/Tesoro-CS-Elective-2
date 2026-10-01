import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static const _track = 'music/pokecenter.mp3';
  static const _click = 'music/pokemon_click_trimmed.wav';
  static const _clickVoices = 4;
  static const _clickGain = 0.8;

  final _random = Random();
  Future<List<AudioPlayer>>? _clickPlayers;
  int _nextClickVoice = 0;

  AudioPlayer? _player;
  Future<void>? _loading;
  bool _muted = false;
  bool _hidden = false;
  double _volume = 1;

  bool get isMuted => _muted;

  double get volume => _volume;

  double get _effectiveVolume => _muted ? 0 : _volume;

  Future<void> start() async {
    try {
      final player = _player ??= AudioPlayer()
        ..audioCache = AudioCache(prefix: '');
      await (_loading ??= _load(player));

      if (_hidden || player.state == PlayerState.playing) return;
      await player.resume();
    } catch (e) {
      _loading = null;
      debugPrint('Background music could not start: $e');
    }
  }

  Future<void> _load(AudioPlayer player) async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(_effectiveVolume);
    await player.setSource(AssetSource(_track));
  }

  Future<void> playClick({bool ignoreMute = false}) async {
    final volume = ignoreMute ? _volume : _effectiveVolume;
    if (volume == 0) return;

    try {
      final players = await (_clickPlayers ??= _loadClickPlayers());
      final player = players[_nextClickVoice];
      _nextClickVoice = (_nextClickVoice + 1) % players.length;
      if (player.state == PlayerState.playing) await player.stop();
      await player.setVolume(
        volume * _clickGain * (0.85 + _random.nextDouble() * 0.15),
      );
      await player.setPlaybackRate(0.96 + _random.nextDouble() * 0.08);
      await player.resume();
    } catch (e) {
      _clickPlayers = null;
      debugPrint('Click sound could not play: $e');
    }
  }

  Future<List<AudioPlayer>> _loadClickPlayers() async {
    final players = [
      for (var i = 0; i < _clickVoices; i++)
        AudioPlayer()..audioCache = AudioCache(prefix: ''),
    ];
    final mixContext = AudioContextConfig(
      focus: AudioContextConfigFocus.mixWithOthers,
    ).build();
    for (final player in players) {
      await player.setAudioContext(mixContext);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setSource(AssetSource(_click));
    }
    return players;
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _applyVolume();
  }

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

  Future<void> pause() async {
    _hidden = true;
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('Could not pause music: $e');
    }
  }

  Future<void> resume() async {
    _hidden = false;
    if (_loading == null) return;
    await start();
  }

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _loading = null;

    final clickPlayers = _clickPlayers;
    _clickPlayers = null;
    if (clickPlayers != null) {
      for (final player in await clickPlayers) {
        await player.dispose();
      }
    }
  }
}
