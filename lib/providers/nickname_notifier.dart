import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature 2 — Pokémon Nickname Editor.
///
/// State is a map of Pokémon ID -> nickname. The Pokémon model itself is
/// never changed, so the original name is always kept.
///
/// Riverpod only notifies listeners when the new state is `!=` the old one,
/// so every method builds a NEW map instead of mutating the current one.
class NicknameNotifier extends Notifier<Map<int, String>> {
  static const maxLength = 20;

  @override
  Map<int, String> build() => const {};

  /// Adds or edits a nickname. An empty value removes it.
  void setNickname(int pokemonId, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(pokemonId);
      return;
    }
    state = <int, String>{...state, pokemonId: trimmed};
  }

  void removeNickname(int pokemonId) {
    if (!state.containsKey(pokemonId)) return;
    state = <int, String>{...state}..remove(pokemonId);
  }
}

final nicknameProvider = NotifierProvider<NicknameNotifier, Map<int, String>>(
  NicknameNotifier.new,
);