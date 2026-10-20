import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/music_service.dart';
import '../services/pokemon_service.dart';

/// Services are exposed through plain Providers so every notifier gets them
/// with `ref.read(...)`, and tests can swap them with `overrideWithValue`
/// (e.g. a PokemonService backed by a MockClient).

final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

final musicServiceProvider = Provider<MusicService>((ref) {
  final service = MusicService();
  ref.onDispose(service.dispose); // releases the audio players
  return service;
});
