import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/music_service.dart';
import 'service_providers.dart';

typedef MusicState = ({bool isMuted, double volume});

class MusicNotifier extends Notifier<MusicState> {
  MusicService get _music => ref.read(musicServiceProvider);

  @override
  MusicState build() {
    final music = ref.watch(musicServiceProvider);

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

  Future<void> playCry(String url) => _music.playCry(url);

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
