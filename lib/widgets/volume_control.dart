import 'package:flutter/material.dart';

import '../services/music_service.dart';

class VolumeControl extends StatefulWidget {
  final MusicService music;

  const VolumeControl({super.key, required this.music});

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  static const _sliderWidth = 120.0;

  bool _hovering = false;
  bool _dragging = false;

  bool get _showSlider => _hovering || _dragging;

  Future<void> _toggleMute() async {
    widget.music.playClick(ignoreMute: true);
    await widget.music.toggleMute();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setVolume(double value) async {
    await widget.music.setVolume(value);
    if (!mounted) return;
    setState(() {});
  }

  IconData get _icon {
    final music = widget.music;
    if (music.isMuted || music.volume == 0) return Icons.volume_off;
    if (music.volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    final music = widget.music;
    final level = music.isMuted ? 0.0 : music.volume;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: _showSlider ? _sliderWidth : 0,
              child: OverflowBox(
                minWidth: _sliderWidth,
                maxWidth: _sliderWidth,
                alignment: Alignment.centerRight,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white38,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                    trackShape: const RectangularSliderTrackShape(),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                  ),
                  child: Slider(
                    value: level,
                    semanticFormatterCallback: (v) =>
                        'Volume ${(v * 100).round()}%',
                    onChangeStart: (_) => setState(() => _dragging = true),
                    onChangeEnd: (_) => setState(() => _dragging = false),
                    onChanged: _setVolume,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: music.isMuted ? 'Unmute music' : 'Mute music',
            icon: Icon(_icon),
            onPressed: _toggleMute,
          ),
        ],
      ),
    );
  }
}
