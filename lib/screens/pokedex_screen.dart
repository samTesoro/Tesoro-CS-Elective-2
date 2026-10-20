import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_type.dart';
import '../providers/favorites_notifier.dart';
import '../providers/filter_notifiers.dart';
import '../providers/music_notifier.dart';
import '../providers/pokemon_list_notifier.dart';
import '../providers/theme_notifier.dart';
import '../theme.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/nickname_dialog.dart';
import '../widgets/pokeball_spinner.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/status_view.dart';
import '../widgets/type_badge.dart';
import '../widgets/volume_control.dart';
import 'pokemon_detail_screen.dart';

/// Home page: Pokemon grid + search + type filter + favorites panel.
///
/// ConsumerStatefulWidget only because it owns the search box's
/// TextEditingController. Every value on screen comes from Riverpod.
class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  late final _searchController = TextEditingController(
    text: ref.read(searchQueryProvider),
  );

  @override
  void initState() {
    super.initState();
    // First load: the same fetch() method that refresh uses.
    ref.read(pokemonListProvider.notifier).fetch();
    ref.read(musicProvider.notifier).start();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  VoidCallback _withClick(VoidCallback action) => () {
    ref.read(musicProvider.notifier).playClick();
    action();
  };

  /// Refresh = RECALL the existing fetch() method (no new method).
  Future<void> _refresh() => ref.read(pokemonListProvider.notifier).fetch();

  void _openDetails(int id) => openPokemonDetails(context, id);

  Widget _buildTypeFilter(PokemonType? selectedType) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        itemCount: PokemonType.values.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // Index 0 is "All", which clears the filter.
          final type = index == 0 ? null : PokemonType.values[index - 1];
          return TypeFilterChip(
            type: type,
            selected: selectedType == type,
            onTap: _withClick(() {
              final filter = ref.read(typeFilterProvider.notifier);
              type == null ? filter.clear() : filter.select(type);
            }),
          );
        },
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<Pokemon>> listState) {
    // Loading state
    if (listState.isLoading) {
      return const Center(child: PokeballSpinner(size: 80));
    }

    // Error state
    if (listState.hasError) {
      return StatusView(
        icon: Icons.wifi_off_rounded,
        title: 'Something went wrong',
        message: '${listState.error}',
        onRetry: _withClick(_refresh),
      );
    }

    // Success state
    final all = ref.watch(loadedPokemonProvider);
    if (all.isEmpty) {
      return StatusView(
        icon: Icons.catching_pokemon,
        title: 'No Pokemon found',
        message: 'The PokeAPI returned an empty list.',
        onRetry: _withClick(_refresh),
      );
    }

    final results = ref.watch(filteredPokemonProvider);
    return RefreshIndicator(
      onRefresh: _refresh,
      child: results.isEmpty
          // ListView so pull-to-refresh still works on the "no match" view.
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [_buildNoMatch()],
            )
          : GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final pokemon = results[index];
                return PokemonCard(
                  key: ValueKey(pokemon.id),
                  pokemon: pokemon,
                  onTap: _withClick(() => _openDetails(pokemon.id)),
                  onLongPress: () => showNicknameEditor(context, pokemon),
                );
              },
            ),
    );
  }

  Widget _buildNoMatch() {
    final query = ref.watch(searchQueryProvider);
    final type = ref.watch(typeFilterProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: StatusView(
        icon: Icons.search_off,
        title: 'No match',
        message: noMatchMessage(query: query, type: type),
        actionLabel: 'Clear filters',
        actionIcon: Icons.filter_alt_off,
        onRetry: _withClick(() {
          _searchController.clear();
          ref.read(searchQueryProvider.notifier).clear();
          ref.read(typeFilterProvider.notifier).clear();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final listState = ref.watch(pokemonListProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedType = ref.watch(typeFilterProvider);
    final favoriteCount = ref.watch(favoritesProvider.select((s) => s.length));
    final isPanelOpen = ref.watch(favoritesPanelProvider);
    // Phones get a floating favorites button + drawer instead of the
    // AppBar button and inline panel, which crowd the small screen.
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Listener(
      onPointerDown: (_) => ref.read(musicProvider.notifier).start(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          centerTitle: true,
          automaticallyImplyActions: false,
          // Room for the volume slider, which slides out on hover (desktop).
          leadingWidth: isMobile ? 96 : 216,
          leading: Row(
            children: [
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: listState.isLoading ? null : _withClick(_refresh),
              ),
              const VolumeControl(),
            ],
          ),
          title: Image.asset(
            'assets/pokedex_logo.png',
            height: 52,
            semanticLabel: 'Pokedex',
          ),
          actions: [
            if (!isMobile)
              // Opens / closes the favorites panel from the AppBar too.
              IconButton(
                tooltip: isPanelOpen ? 'Hide favorites' : 'Show favorites',
                icon: Badge(
                  isLabelVisible: favoriteCount > 0,
                  label: Text('$favoriteCount'),
                  child: Icon(
                    isPanelOpen ? Icons.favorite : Icons.favorite_border,
                  ),
                ),
                onPressed: _withClick(
                  ref.read(favoritesPanelProvider.notifier).toggle,
                ),
              ),
            IconButton(
              tooltip: isDark ? 'Light mode' : 'Dark mode',
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: _withClick(
                ref.read(themeProvider.notifier).toggleTheme,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(108),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: ref.read(searchQueryProvider.notifier).set,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(
                      fontSize: 20,
                      color: controlTextColor(context),
                    ),
                    cursorColor: controlTextColor(context),
                    decoration: InputDecoration(
                      hintText: 'Search Pokemon...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: controlTextColor(context),
                      ),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: Icon(
                                Icons.close,
                                color: controlTextColor(context),
                              ),
                              onPressed: _withClick(() {
                                _searchController.clear();
                                ref.read(searchQueryProvider.notifier).clear();
                              }),
                            ),
                    ),
                  ),
                ),
                _buildTypeFilter(selectedType),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        endDrawer: isMobile ? FavoritesDrawer(onOpen: _openDetails) : null,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/pokedex_background.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: isDark
                        ? ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.6),
                            BlendMode.srcATop,
                          )
                        : null,
                  ),
                ),
                child: Column(
                  children: [
                    if (!isMobile) FavoritesPanel(onOpen: _openDetails),
                    Expanded(child: _buildBody(listState)),
                  ],
                ),
              ),
            ),
            if (isMobile) const Positioned.fill(child: FavoritesFab()),
          ],
        ),
      ),
    );
  }
}
