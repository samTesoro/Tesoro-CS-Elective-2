/// Extra info shown on the details page, fetched on demand per Pokemon
/// from `/pokemon/{id}` and `/pokemon-species/{id}`.
class PokemonDetails {
  /// Pokedex entry text (English), e.g. "A strange seed was planted...".
  final String bio;

  /// Category, e.g. "Seed Pokemon".
  final String genus;

  /// In metres / kilograms (the API gives decimetres / hectograms).
  final double heightM;
  final double weightKg;

  final List<String> abilities;

  /// Base stats in API order: HP, Attack, Defense, Sp. Atk, Sp. Def, Speed.
  final List<PokemonStat> stats;

  const PokemonDetails({
    required this.bio,
    required this.genus,
    required this.heightM,
    required this.weightKg,
    required this.abilities,
    required this.stats,
  });

  int get totalStats => stats.fold(0, (sum, s) => sum + s.value);

  factory PokemonDetails.fromJson(
    Map<String, dynamic> pokemon,
    Map<String, dynamic> species,
  ) {
    final height = pokemon['height'];
    final weight = pokemon['weight'];
    if (height is! int || weight is! int) {
      throw const FormatException('Pokemon is missing height or weight');
    }

    return PokemonDetails(
      bio: _english(species['flavor_text_entries'], 'flavor_text')
          // Entries contain hard line/page breaks from the games.
          .replaceAll(RegExp(r'[\n\f\r]+'), ' ')
          .replaceAll('POKEMON', 'Pokemon'),
      genus: _english(species['genera'], 'genus'),
      heightM: height / 10,
      weightKg: weight / 10,
      abilities: [
        for (final entry
            in (pokemon['abilities'] as List? ?? const [])
                .whereType<Map<String, dynamic>>())
          if (entry['ability'] case {'name': final String name})
            _titleCase(name),
      ],
      stats: [
        for (final entry
            in (pokemon['stats'] as List? ?? const [])
                .whereType<Map<String, dynamic>>())
          if (entry case {
            'base_stat': final int value,
            'stat': {'name': final String name},
          })
            PokemonStat(name, value),
      ],
    );
  }

  /// Latest English entry from a localized list, or '' if none.
  static String _english(Object? entries, String field) {
    if (entries is! List) return '';
    final english = entries.whereType<Map<String, dynamic>>().where(
      (e) => switch (e['language']) {
        {'name': 'en'} => true,
        _ => false,
      },
    );
    final value = english.isEmpty ? null : english.last[field];
    return value is String ? _plainE(value) : '';
  }

  /// The pixel font has no accented e, so "Pokémon" falls back to another
  /// font at a different size. Swap it for a plain e.
  static String _plainE(String text) =>
      text.replaceAll('é', 'e').replaceAll('É', 'E');

  static String _titleCase(String slug) => slug
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class PokemonStat {
  /// API name, e.g. "special-attack".
  final String name;
  final int value;

  const PokemonStat(this.name, this.value);

  String get label => switch (name) {
    'hp' => 'HP',
    'attack' => 'ATK',
    'defense' => 'DEF',
    'special-attack' => 'SP.ATK',
    'special-defense' => 'SP.DEF',
    'speed' => 'SPD',
    _ => name.toUpperCase(),
  };
}
