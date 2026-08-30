import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AdaptiveActionButton extends StatelessWidget {
  const AdaptiveActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      return CupertinoButton.filled(
        onPressed: () {},
        child: const Text('Continue'),
      );
    }

    return ElevatedButton(
      onPressed: () {},
      child: const Text('Continue'),
    );
  }
}