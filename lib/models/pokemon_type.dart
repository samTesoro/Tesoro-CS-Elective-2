import 'package:flutter/material.dart';

enum PokemonType {
  normal(Color(0xFF9FA19F)),
  fire(Color(0xFFE62829)),
  water(Color(0xFF2980EF)),
  grass(Color(0xFF3FA129)),
  electric(Color(0xFFFAC000)),
  ice(Color(0xFF3DCEF3)),
  fighting(Color(0xFFFF8000)),
  poison(Color(0xFF9141CB)),
  ground(Color(0xFF915121)),
  flying(Color(0xFF81B9EF)),
  psychic(Color(0xFFEF4179)),
  bug(Color(0xFF91A119)),
  rock(Color(0xFFAFA981)),
  ghost(Color(0xFF704170)),
  dragon(Color(0xFF5060E1)),
  dark(Color(0xFF624D4E)),
  steel(Color(0xFF60A1B8)),
  fairy(Color(0xFFEF70EF));

  final Color color;

  const PokemonType(this.color);

  String get label => '${name[0].toUpperCase()}${name.substring(1)}';

  String get iconAsset => 'assets/types/$name.svg';
}
