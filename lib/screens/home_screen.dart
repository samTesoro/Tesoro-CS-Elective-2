import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tesoro's Printing Press"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find the right print for you',
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Quality printing made simple.',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 32),

            Text(
              'Featured Products',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  _PlaceholderProduct(name: 'Business Cards'),
                  _PlaceholderProduct(name: 'Flyers'),
                  _PlaceholderProduct(name: 'Posters'),
                  _PlaceholderProduct(name: 'Stickers'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderProduct extends StatelessWidget {
  final String name;

  const _PlaceholderProduct({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}