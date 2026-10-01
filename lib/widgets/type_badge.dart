import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/pokemon_type.dart';
import '../theme.dart';

class TypeIcon extends StatelessWidget {
  final PokemonType type;
  final double size;

  const TypeIcon({super.key, required this.type, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: type.label,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.15),
        decoration: BoxDecoration(
          color: type.color,
          border: Border.all(color: pixelBorderColor, width: 2),
        ),
        child: SvgPicture.asset(type.iconAsset, semanticsLabel: type.label),
      ),
    );
  }
}

class TypeFilterChip extends StatelessWidget {
  final PokemonType? type;
  final bool selected;
  final VoidCallback onTap;

  const TypeFilterChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = this.type;
    final Color background;
    final Color foreground;
    if (!selected) {
      background = controlFillColor(context);
      foreground = controlTextColor(context);
    } else if (type != null) {
      background = type.color;
      foreground = Colors.white;
    } else {
      background = controlTextColor(context);
      foreground = controlFillColor(context);
    }

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 2, 10, 2),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: pixelBorderColor,
                width: pixelBorderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (type != null)
                  TypeIcon(type: type, size: 22)
                else
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 20,
                      color: foreground,
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  type?.label ?? 'All',
                  style: TextStyle(fontSize: 18, color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
