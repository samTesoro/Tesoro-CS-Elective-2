import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';
import 'pokemon_list_notifier.dart';

/// Feature 5 — Pokémon Type Filter. `null` means "All" (no filter).
class TypeFilterNotifier extends Notifier<PokemonType?> {
  @override
  PokemonType? build() => null;

  void select(PokemonType? type) => state = type;

  void clear() => state = null;
}

final typeFilterProvider = NotifierProvider<TypeFilterNotifier, PokemonType?>(
  TypeFilterNotifier.new,
);

/// Search box text (kept from the earlier activity).
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;

  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// What the grid actually shows: the loaded list after the type filter and
/// the search query. Because it `watch`es all three, it recomputes on its
/// own whenever any of them changes.
final filteredPokemonProvider = Provider<List<Pokemon>>((ref) {
  final all = ref.watch(loadedPokemonProvider);
  final type = ref.watch(typeFilterProvider);
  final q = ref.watch(searchQueryProvider).trim().toLowerCase().replaceFirst(
    '#',
    '',
  );
  final number = int.tryParse(q);

  return all
      .where((p) => type == null || p.types.contains(type))
      .where(
        (p) =>
            q.isEmpty ||
            p.displayName.toLowerCase().contains(q) ||
            p.name.contains(q) ||
            (number != null && p.id == number),
      )
      .toList();
});

/// Message for the "no match" view.
String noMatchMessage({required String query, PokemonType? type}) {
  final q = query.trim();
  final label = type?.label;
  if (label != null && q.isNotEmpty) {
    return 'No $label-type Pokemon matches "$q".';
  }
  if (label != null) return 'No $label-type Pokemon in this list.';
  return 'No Pokemon matches "$q".';
}