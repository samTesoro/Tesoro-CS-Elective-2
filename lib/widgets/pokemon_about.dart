import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon_details.dart';
import '../providers/music_notifier.dart';
import '../providers/pokemon_list_notifier.dart';
import '../theme.dart';
import 'pokeball_spinner.dart';

class PokemonAbout extends ConsumerWidget {
  final int pokemonId;

  const PokemonAbout({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final details = ref.watch(pokemonDetailsProvider(pokemonId));

    return switch (details) {
      AsyncData(:final value) => _AboutContent(details: value),
      AsyncError(:final error) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(musicProvider.notifier).playClick();
                ref.invalidate(pokemonDetailsProvider(pokemonId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: PokeballSpinner(size: 48)),
      ),
    };
  }
}

class PokemonCryButton extends ConsumerWidget {
  final int pokemonId;

  const PokemonCryButton({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cryUrl = ref.watch(
      pokemonDetailsProvider(pokemonId).select((d) => d.value?.cryUrl),
    );
    if (cryUrl == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: 'Play cry',
      icon: const Icon(Icons.volume_up),
      onPressed: () => ref.read(musicProvider.notifier).playCry(cryUrl),
    );
  }
}

class _AboutContent extends StatelessWidget {
  final PokemonDetails details;

  const _AboutContent({required this.details});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionTitle('About'),
          if (details.genus.isNotEmpty)
            Text(
              details.genus,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          if (details.bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(details.bio, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  label: 'Height',
                  value: '${details.heightM.toStringAsFixed(1)} m',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  label: 'Weight',
                  value: '${details.weightKg.toStringAsFixed(1)} kg',
                ),
              ),
            ],
          ),
          if (details.abilities.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoBox(label: 'Abilities', value: details.abilities.join(', ')),
          ],
          if (details.stats.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Base Stats'),
            for (final stat in details.stats) _StatRow(stat: stat),
            const SizedBox(height: 4),
            Text(
              'Total: ${details.totalStats}',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.only(bottom: 4),
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(color: pixelBorderColor, width: pixelBorderWidth),
      ),
    ),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: pixelBorderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  static const _maxStat = 255;

  final PokemonStat stat;

  const _StatRow({required this.stat});

  Color get _color => switch (stat.value) {
    < 50 => const Color(0xFFE3350D),
    < 80 => const Color(0xFFF2B807),
    < 110 => const Color(0xFF4CAF50),
    _ => const Color(0xFF1E88E5),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(stat.label, style: theme.textTheme.bodyLarge),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${stat.value}',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border.all(color: pixelBorderColor, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (stat.value / _maxStat).clamp(0.0, 1.0),
                child: ColoredBox(color: _color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
