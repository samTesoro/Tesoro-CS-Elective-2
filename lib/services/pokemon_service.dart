import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

// Thrown by PokemonService with a message that is safe to show in the UI.
class PokemonServiceException implements Exception {
  final String message;

  const PokemonServiceException(this.message);

  @override
  String toString() => message;
}

class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2/pokemon';
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;

  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  // Future, not Stream: this is a single HTTP GET that produces exactly one
  // result (the list of Pokemon) and then has a clear "finished" moment.
  // Nothing new arrives over time, so there is nothing for a Stream to emit
  // after the first value.
  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    final uri = Uri.parse('$_baseUrl?limit=$limit');

    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw PokemonServiceException(
          'Server responded with ${response.statusCode}. Please try again.',
        );
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic> || body['results'] is! List) {
        throw const FormatException('Unexpected response shape');
      }

      return (body['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Pokemon.fromJson)
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
}
