import 'package:flutter/widgets.dart';

import '../services/music_service.dart';

class MusicProvider extends ChangeNotifier {
  final MusicService _music;
  late final AppLifecycleListener _lifecycle;

  MusicProvider(this._music) {
    _lifecycle = AppLifecycleListener(
      onHide: _music.pause,
      onShow: _music.resume,
    );
  }

  bool get isMuted => _music.isMuted;
  double get volume => _music.volume;

  Future<void> start() => _music.start();

  Future<void> playClick({bool ignoreMute = false}) =>
      _music.playClick(ignoreMute: ignoreMute);

  Future<void> toggleMute() async {
    await _music.toggleMute();
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    await _music.setVolume(value);
    notifyListeners();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _music.dispose();
    super.dispose();
  }
}
