import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/pokemon.dart';
import 'package:flutter_application_1/models/pokemon_type.dart';
import 'package:flutter_application_1/services/music_service.dart';
import 'package:flutter_application_1/services/pokemon_service.dart';

class FakeMusicService implements MusicService {
  bool _muted = false;
  double _volume = 1;
  int startCalls = 0;
  int clicks = 0;

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
  Future<void> playClick({bool ignoreMute = false}) async => clicks++;
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

http.Response typeResponse(Uri url, int count) => http.Response(
  jsonEncode({
    'pokemon': [
      if (url.pathSegments.contains('fire'))
        for (var i = 1; i <= count; i += 2)
          {
            'slot': 1,
            'pokemon': {
              'name': 'pokemon-$i',
              'url': 'https://pokeapi.co/api/v2/pokemon/$i/',
            },
          },
    ],
  }),
  200,
);

PokemonService serviceWithList(int count) => PokemonService(
  client: MockClient((req) async {
    if (req.url.pathSegments.contains('type')) {
      return typeResponse(req.url, count);
    }
    return http.Response(listBody(count), 200);
  }),
);

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
          if (req.url.pathSegments.contains('type')) {
            return typeResponse(req.url, 30);
          }
          requested = req.url;
          return http.Response(listBody(30), 200);
        }),
      );
      final list = await service.fetchPokemon();
      expect(requested?.queryParameters['limit'], '30');
      expect(list, hasLength(30));
    });

    test('attaches types from the type endpoints', () async {
      final list = await serviceWithList(2).fetchPokemon();
      expect(list[0].types, [PokemonType.fire]);
      expect(list[1].types, isEmpty);
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
        MyApp(music: FakeMusicService(), service: serviceWithList(3)),
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
        MyApp(music: FakeMusicService(), service: serviceWithList(0)),
      );
      await tester.pump();

      expect(find.text('No Pokemon found'), findsOneWidget);
    });

    testWidgets('type filter shows only Pokemon of that type', (tester) async {
      await tester.pumpWidget(
        MyApp(music: FakeMusicService(), service: serviceWithList(3)),
      );
      await tester.pump();
      expect(find.text('Pokemon 2'), findsOneWidget);

      await tester.tap(find.text('Fire'));
      await tester.pump();
      expect(find.text('Pokemon 1'), findsOneWidget);
      expect(find.text('Pokemon 2'), findsNothing);
      expect(find.text('Pokemon 3'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(find.text('Pokemon 2'), findsOneWidget);
    });
  });
  group('Background music', () {
    testWidgets('starts on launch and the sound icon toggles mute', (
      tester,
    ) async {
      final music = FakeMusicService();
      await tester.pumpWidget(MyApp(music: music, service: serviceWithList(1)));
      await tester.pump();

      expect(music.startCalls, greaterThan(0));
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      await tester.tap(find.byTooltip('Mute music'));
      await tester.pump();

      expect(music.isMuted, isTrue);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('buttons play the click sound', (tester) async {
      final music = FakeMusicService();
      await tester.pumpWidget(MyApp(music: music, service: serviceWithList(1)));
      await tester.pump();

      await tester.tap(find.text('Fire'));
      await tester.tap(find.byTooltip('Dark mode'));
      await tester.tap(find.byTooltip('Mute music'));
      await tester.pump();

      expect(music.clicks, 3);
    });

    testWidgets('hovering the sound icon shows a volume slider', (
      tester,
    ) async {
      final music = FakeMusicService();
      await tester.pumpWidget(MyApp(music: music, service: serviceWithList(1)));
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

      await tester.drag(find.byType(Slider), const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(music.volume, 0);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });
  });
}
