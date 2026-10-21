import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/music_service.dart';
import '../services/pokemon_service.dart';

final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

final musicServiceProvider = Provider<MusicService>((ref) {
  final service = MusicService();
  ref.onDispose(service.dispose);
  return service;
});
