import 'pokemon_type.dart';

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  final List<PokemonType> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  Pokemon withTypes(List<PokemonType> types) =>
      Pokemon(id: id, name: name, imageUrl: imageUrl, types: types);

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];

    if (name is! String || url is! String) {
      throw const FormatException('Pokemon entry is missing name or url');
    }

    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty);
    final id = int.tryParse(segments.isEmpty ? '' : segments.last);

    if (id == null) {
      throw FormatException('Could not read Pokemon ID from url', url);
    }

    return Pokemon(
      id: id,
      name: name,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
    );
  }

  String get displayName => name
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  String get displayId => '#${id.toString().padLeft(3, '0')}';
}
