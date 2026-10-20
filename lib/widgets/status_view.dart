import 'package:flutter/material.dart';

import '../theme.dart';

class StatusView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  /// Button text/icon; defaults to "Try Again" for retrying a fetch.
  final String actionLabel;
  final IconData actionIcon;

  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
    this.actionLabel = 'Try Again',
    this.actionIcon = Icons.refresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: pixelBox(color: theme.cardTheme.color ?? Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(actionIcon),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}