import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';
import '../services/pokemon_service.dart';

enum PokemonStatus { loading, success, error }

class PokemonProvider extends ChangeNotifier {
  static const pokemonLimit = 30;

  final PokemonService _service;

  PokemonProvider(this._service);

  PokemonStatus _status = PokemonStatus.loading;
  List<Pokemon> _pokemon = const [];
  String _errorMessage = '';
  String _query = '';
  PokemonType? _selectedType;
  int? _selectedId;

  int _requestId = 0;

  PokemonStatus get status => _status;
  List<Pokemon> get pokemon => _pokemon;
  String get errorMessage => _errorMessage;
  String get query => _query;
  PokemonType? get selectedType => _selectedType;

  Pokemon? get selectedPokemon {
    for (final p in _pokemon) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  List<Pokemon> get filteredPokemon {
    final q = _query.trim().toLowerCase().replaceFirst('#', '');
    final number = int.tryParse(q);
    return _pokemon
        .where((p) => _selectedType == null || p.types.contains(_selectedType))
        .where(
          (p) =>
              q.isEmpty ||
              p.displayName.toLowerCase().contains(q) ||
              p.name.contains(q) ||
              (number != null && p.id == number),
        )
        .toList();
  }

  String get noMatchMessage {
    final q = _query.trim();
    final type = _selectedType?.label;
    if (type != null && q.isNotEmpty) {
      return 'No $type-type Pokemon matches "$q".';
    }
    if (type != null) return 'No $type-type Pokemon in this list.';
    return 'No Pokemon matches "$q".';
  }

  Future<void> fetchPokemon() async {
    final requestId = ++_requestId;
    _status = PokemonStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _service.fetchPokemon(limit: pokemonLimit);
      if (requestId != _requestId) return;
      _pokemon = result;
      _status = PokemonStatus.success;
    } catch (e) {
      if (requestId != _requestId) return;
      _errorMessage = '$e';
      _status = PokemonStatus.error;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void selectType(PokemonType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void selectPokemon(int id) {
    _selectedId = id;
    notifyListeners();
  }
}
