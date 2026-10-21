import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/music_notifier.dart';
import '../providers/nickname_notifier.dart';

Future<void> showNicknameEditor(BuildContext context, Pokemon pokemon) {
  return showDialog<void>(
    context: context,
    builder: (_) => NicknameDialog(pokemon: pokemon),
  );
}

class NicknameDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameDialog({super.key, required this.pokemon});

  @override
  ConsumerState<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends ConsumerState<NicknameDialog> {
  late final TextEditingController _controller;
  late final String? _current;

  @override
  void initState() {
    super.initState();
    _current = ref.read(nicknameProvider)[widget.pokemon.id];
    _controller = TextEditingController(text: _current ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(musicProvider.notifier).playClick();
    ref.read(nicknameProvider.notifier).setNickname(widget.pokemon.id, text);
    Navigator.of(context).pop();
  }

  void _remove() {
    ref.read(musicProvider.notifier).playClick();
    ref.read(nicknameProvider.notifier).removeNickname(widget.pokemon.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _current == null ? 'Add a nickname' : 'Edit nickname',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Original name: ${widget.pokemon.displayName}'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: NicknameNotifier.maxLength,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(hintText: 'e.g. Sprouty'),
          ),
        ],
      ),
      actions: [
        if (_current != null)
          TextButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => ElevatedButton(
            onPressed: value.text.trim().isEmpty ? null : _save,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
