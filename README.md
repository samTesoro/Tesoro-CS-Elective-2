# Pokédex List — Dart Async Activity

Fetches the first 30 Pokémon from the [PokéAPI](https://pokeapi.co/api/v2/pokemon)
and shows each one's name, image, and ID in a scrollable grid.

## Folder structure

```
lib/
├── main.dart                     # App entry, theme toggle
├── theme.dart
├── models/pokemon.dart           # Pokemon model + fromJson
├── services/pokemon_service.dart # PokéAPI call (Future<List<Pokemon>>)
├── widgets/
│   ├── pokemon_card.dart         # One grid tile
│   └── status_view.dart          # Error / empty state view
└── screens/pokedex_screen.dart   # FutureBuilder + GridView
```

## Future or Stream? → Future

The deciding question is: does this operation produce exactly one result, or a
sequence of results over time?

`GET /pokemon?limit=30` is a single HTTP request. It returns one response and
then it's done. Nothing new arrives later, so a Stream would have nothing to
emit after its first value. A `Future<List<Pokemon>>` consumed by a
`FutureBuilder` fits this. A Stream fits continuous data, such as a chat feed,
Firestore snapshots, or sensor readings.

Because the list endpoint only returns `name` and `url`, the ID is read from the
URL and the image is built from the official-artwork sprite URL. That keeps the
data fetch to one request instead of 31.

## Async concepts applied

- **async/await with try/catch.** The service catches `TimeoutException`,
  `http.ClientException` (no internet), and `FormatException` (bad JSON). It
  turns each one into a readable `PokemonServiceException`.
- **Request timeout.** `.timeout(Duration(seconds: 10))`.
- **Future created once.** It is stored in a field set in `initState()`, not
  inline in `build()`, so toggling the theme does not fetch the data again.
- **All states handled.** `ConnectionState.waiting` shows a spinner. `hasError`
  shows an error view with a retry button. An empty list shows an empty-state
  view. Otherwise the grid is shown.
- **Type-safe parsing.** `is` checks and `int.tryParse` guard against bad data.

## Run

```
flutter pub get
flutter run
flutter test
```
