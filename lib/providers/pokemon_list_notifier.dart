import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'service_providers.dart';

/// Feature 1 — Pokémon List Management.
///
/// Holds the Pokémon list as an `AsyncValue`, which already models the three
/// states the exam asks for:
///   AsyncLoading -> show the Pokéball spinner
///   AsyncData    -> show the grid
///   AsyncError   -> show the error message + Try Again
///
/// [fetch] is the ONLY method that talks to the API. The first load and
/// every refresh (pull-to-refresh, Refresh button, Try Again) call it.
class PokemonListNotifier extends Notifier<AsyncValue<List<Pokemon>>> {
  static const pokemonLimit = 30;

  /// Increases on every fetch so a slow, older response can't overwrite a
  /// newer one (e.g. Refresh tapped twice quickly).
  int _requestId = 0;

  @override
  AsyncValue<List<Pokemon>> build() => const AsyncLoading<List<Pokemon>>();

  Future<void> fetch() async {
    final requestId = ++_requestId;

    // Already loading on the very first call (initial state), so we only
    // switch to loading when coming from data or error.
    if (!state.isLoading) state = const AsyncLoading<List<Pokemon>>();

    // AsyncValue.guard runs the Future and turns a thrown exception into
    // AsyncError instead of crashing.
    final result = await AsyncValue.guard(
      () => ref.read(pokemonServiceProvider).fetchPokemon(limit: pokemonLimit),
    );

    if (requestId != _requestId) return; // a newer fetch started; drop this
    state = result;
  }
}

final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, AsyncValue<List<Pokemon>>>(
      PokemonListNotifier.new,
    );

/// The loaded list, or an empty list while loading / on error.
/// Other providers build on this instead of repeating the AsyncValue check.
final loadedPokemonProvider = Provider<List<Pokemon>>((ref) {
  return switch (ref.watch(pokemonListProvider)) {
    AsyncData(:final value) => value,
    _ => const <Pokemon>[],
  };
});

/// Looks up one Pokémon by ID (used by the details screen).
final pokemonByIdProvider = Provider.family<Pokemon?, int>((ref, id) {
  for (final pokemon in ref.watch(loadedPokemonProvider)) {
    if (pokemon.id == id) return pokemon;
  }
  return null;
});