class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  // Builds a Pokemon from one entry of the PokéAPI list response:
  // { "name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/" }
  // The list endpoint doesn't return the ID directly, so it is read from the
  // last segment of the URL.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];

    if (name is! String || url is! String) {
      throw const FormatException('Pokémon entry is missing name or url');
    }

    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    final id = int.tryParse(segments.isEmpty ? '' : segments.last);

    if (id == null) {
      throw FormatException('Could not read Pokémon ID from url', url);
    }

    return Pokemon(
      id: id,
      name: name,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  // "mr-mime" -> "Mr Mime"
  String get displayName => name
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  // 1 -> "#001"
  String get displayId => '#${id.toString().padLeft(3, '0')}';
}
