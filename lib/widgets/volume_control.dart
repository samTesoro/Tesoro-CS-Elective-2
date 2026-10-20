import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_notifier.dart';

class VolumeControl extends ConsumerStatefulWidget {
  const VolumeControl({super.key});

  @override
  ConsumerState<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends ConsumerState<VolumeControl> {
  static const _sliderWidth = 120.0;

  bool _hovering = false;
  bool _dragging = false;

  bool get _showSlider => _hovering || _dragging;

  void _toggleMute() {
    final music = ref.read(musicProvider.notifier);
    music.playClick(ignoreMute: true);
    music.toggleMute();
  }

  IconData _icon(MusicState music) {
    if (music.isMuted || music.volume == 0) return Icons.volume_off;
    if (music.volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicProvider);
    final level = music.isMuted ? 0.0 : music.volume;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: music.isMuted ? 'Unmute music' : 'Mute music',
            icon: Icon(_icon(music)),
            onPressed: _toggleMute,
          ),
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: _showSlider ? _sliderWidth : 0,
              child: OverflowBox(
                minWidth: _sliderWidth,
                maxWidth: _sliderWidth,
                alignment: Alignment.centerLeft,
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
                    onChanged: ref.read(musicProvider.notifier).setVolume,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
