import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/pokemon.dart';
import 'package:flutter_application_1/services/music_service.dart';
import 'package:flutter_application_1/services/pokemon_service.dart';

// Stands in for the real player so tests never touch the audio plugin.
class FakeMusicService implements MusicService {
  bool _muted = false;
  double _volume = 1;
  int startCalls = 0;

  @override
  bool get isMuted => _muted;
  @override
  double get volume => _volume;
  @override
  Future<void> setVolume(double value) async {
    _volume = value;
    if (value > 0) _muted = false;
  }

  @override
  Future<void> start() async => startCalls++;
  @override
  Future<void> toggleMute() async => _muted = !_muted;
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  Future<void> dispose() async {}
}

PokemonService serviceReturning(http.Response response) =>
    PokemonService(client: MockClient((_) async => response));

String listBody(int count) => jsonEncode({
  'results': [
    for (var i = 1; i <= count; i++)
      {'name': 'pokemon-$i', 'url': 'https://pokeapi.co/api/v2/pokemon/$i/'},
  ],
});

void main() {
  group('Pokemon.fromJson', () {
    test('reads the ID from the url', () {
      final p = Pokemon.fromJson({
        'name': 'mr-mime',
        'url': 'https://pokeapi.co/api/v2/pokemon/122/',
      });
      expect(p.id, 122);
      expect(p.displayId, '#122');
      expect(p.displayName, 'Mr Mime');
      expect(p.imageUrl, endsWith('/122.png'));
    });

    test('throws FormatException on bad data', () {
      expect(
        () => Pokemon.fromJson({'name': 'x'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PokemonService', () {
    test('requests limit=30', () async {
      Uri? requested;
      final service = PokemonService(
        client: MockClient((req) async {
          requested = req.url;
          return http.Response(listBody(30), 200);
        }),
      );
      final list = await service.fetchPokemon();
      expect(requested?.queryParameters['limit'], '30');
      expect(list, hasLength(30));
    });

    test('maps bad status code to PokemonServiceException', () {
      expect(
        serviceReturning(http.Response('', 500)).fetchPokemon(),
        throwsA(isA<PokemonServiceException>()),
      );
    });

    test('maps invalid JSON to PokemonServiceException', () {
      expect(
        serviceReturning(http.Response('{bad}', 200)).fetchPokemon(),
        throwsA(isA<PokemonServiceException>()),
      );
    });
  });

  group('PokedexScreen states', () {
    testWidgets('shows loading, then the grid', (tester) async {
      await tester.pumpWidget(
        MyApp(
          music: FakeMusicService(),
          service: serviceReturning(http.Response(listBody(3), 200)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump();
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Pokemon 1'), findsOneWidget);
      expect(find.text('#003'), findsOneWidget);
    });

    testWidgets('shows the error state with retry', (tester) async {
      await tester.pumpWidget(
        MyApp(
          music: FakeMusicService(),
          service: serviceReturning(http.Response('', 500)),
        ),
      );
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows the empty state', (tester) async {
      await tester.pumpWidget(
        MyApp(
          music: FakeMusicService(),
          service: serviceReturning(http.Response(listBody(0), 200)),
        ),
      );
      await tester.pump();

      expect(find.text('No Pokemon found'), findsOneWidget);
    });
  });
  group('Background music', () {
    testWidgets('starts on launch and the sound icon toggles mute', (
      tester,
    ) async {
      final music = FakeMusicService();
      await tester.pumpWidget(
        MyApp(
          music: music,
          service: serviceReturning(http.Response(listBody(1), 200)),
        ),
      );
      await tester.pump();

      expect(music.startCalls, greaterThan(0));
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await tester.tap(find.byTooltip('Mute music'));
      await tester.pump();

      expect(music.isMuted, isTrue);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('hovering the sound icon shows a volume slider', (
      tester,
    ) async {
      final music = FakeMusicService();
      await tester.pumpWidget(
        MyApp(
          music: music,
          service: serviceReturning(http.Response(listBody(1), 200)),
        ),
      );
      await tester.pump();

      Size sliderSize() => tester.getSize(
        find
            .ancestor(of: find.byType(Slider), matching: find.byType(ClipRect))
            .first,
      );
      expect(sliderSize().width, 0);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byTooltip('Mute music')));
      await tester.pumpAndSettle();
      expect(sliderSize().width, greaterThan(0));

      // Drag the slider to the far left: volume 0 shows the muted icon.
      await tester.drag(find.byType(Slider), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(music.volume, 0);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });
  });
}
