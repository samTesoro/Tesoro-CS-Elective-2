import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/music_service.dart';
import 'service_providers.dart';

/// What the volume control shows.
typedef MusicState = ({bool isMuted, double volume});

/// Background music + click sounds (moved from Provider to Riverpod).
class MusicNotifier extends Notifier<MusicState> {
  MusicService get _music => ref.read(musicServiceProvider);

  @override
  MusicState build() {
    final music = ref.watch(musicServiceProvider);

    // Pause the music when the app is hidden, resume when it comes back.
    final lifecycle = AppLifecycleListener(
      onHide: music.pause,
      onShow: music.resume,
    );
    ref.onDispose(lifecycle.dispose);

    return (isMuted: music.isMuted, volume: music.volume);
  }

  Future<void> start() => _music.start();

  Future<void> playClick({bool ignoreMute = false}) =>
      _music.playClick(ignoreMute: ignoreMute);

  Future<void> toggleMute() async {
    await _music.toggleMute();
    _sync();
  }

  Future<void> setVolume(double value) async {
    await _music.setVolume(value);
    _sync();
  }

  void _sync() => state = (isMuted: _music.isMuted, volume: _music.volume);
}

final musicProvider = NotifierProvider<MusicNotifier, MusicState>(
  MusicNotifier.new,
);