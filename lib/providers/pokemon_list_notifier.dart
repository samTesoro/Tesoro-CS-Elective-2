import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import 'service_providers.dart';

class PokemonListNotifier extends Notifier<AsyncValue<List<Pokemon>>> {
  static const pokemonLimit = 30;

  int _requestId = 0;

  @override
  AsyncValue<List<Pokemon>> build() => const AsyncLoading<List<Pokemon>>();

  Future<void> fetch() async {
    final requestId = ++_requestId;

    if (!state.isLoading) state = const AsyncLoading<List<Pokemon>>();

    final result = await AsyncValue.guard(
      () => ref.read(pokemonServiceProvider).fetchPokemon(limit: pokemonLimit),
    );

    if (requestId != _requestId) return;
    state = result;
  }
}

final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, AsyncValue<List<Pokemon>>>(
      PokemonListNotifier.new,
    );

final loadedPokemonProvider = Provider<List<Pokemon>>((ref) {
  return switch (ref.watch(pokemonListProvider)) {
    AsyncData(:final value) => value,
    _ => const <Pokemon>[],
  };
});

final pokemonByIdProvider = Provider.family<Pokemon?, int>((ref, id) {
  for (final pokemon in ref.watch(loadedPokemonProvider)) {
    if (pokemon.id == id) return pokemon;
  }
  return null;
});

final pokemonDetailsProvider = FutureProvider.autoDispose
    .family<PokemonDetails, int>((ref, id) {
      return ref.read(pokemonServiceProvider).fetchDetails(id);
    });
