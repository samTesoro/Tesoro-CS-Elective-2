import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';

class PokemonServiceException implements Exception {
  final String message;

  const PokemonServiceException(this.message);

  @override
  String toString() => message;
}

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const _typeUrl = 'https://pokeapi.co/api/v2/type';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    try {
      final results = await Future.wait<Object>([
        _getJson(Uri.parse('$_baseUrl?limit=$limit')),
        _fetchTypesByName(),
      ]);
      final body = results[0] as Map<String, dynamic>;
      final typesByName = results[1] as Map<String, List<PokemonType>>;
      if (body['results'] is! List) {
        throw const FormatException('Unexpected response shape');
      }

      return (body['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Pokemon.fromJson)
          .map((p) => p.withTypes(typesByName[p.name] ?? const []))
          .toList();
    } on TimeoutException {
      throw const PokemonServiceException(
        'The request timed out. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const PokemonServiceException(
        'No internet connection. Please check your network.',
      );
    } on FormatException {
      throw const PokemonServiceException(
        'Received invalid data from the PokeAPI.',
      );
    }
  }

  Future<Map<String, List<PokemonType>>> _fetchTypesByName() async {
    final slotted = <String, List<(int, PokemonType)>>{};

    final responses = await Future.wait(
      PokemonType.values.map((t) => _getJson(Uri.parse('$_typeUrl/${t.name}'))),
    );

    for (final (index, body) in responses.indexed) {
      final type = PokemonType.values[index];
      final entries = body['pokemon'];
      if (entries is! List) {
        throw const FormatException('Unexpected type response shape');
      }
      for (final entry in entries.whereType<Map<String, dynamic>>()) {
        final pokemon = entry['pokemon'];
        final slot = entry['slot'];
        if (pokemon is! Map<String, dynamic> || slot is! int) continue;
        final name = pokemon['name'];
        if (name is! String) continue;
        slotted.putIfAbsent(name, () => []).add((slot, type));
      }
    }

    return {
      for (final MapEntry(:key, :value) in slotted.entries)
        key: (value..sort((a, b) => a.$1.compareTo(b.$1)))
            .map((e) => e.$2)
            .toList(),
    };
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw PokemonServiceException(
        'Server responded with ${response.statusCode}. Please try again.',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response shape');
    }
    return body;
  }
}
