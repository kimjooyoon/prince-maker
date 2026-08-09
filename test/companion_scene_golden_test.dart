import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> story() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> locales() async {
  final result = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/locales/$locale.jsonl'))
            .buffer
            .asUint8List()));
    result[locale] = source.map((key, value) => MapEntry('$key', '$value'));
  }
  return result;
}

void main() {
  testWidgets('companion scene archive records a scene', (tester) async {
    final source = await story();
    await tester.pumpWidget(Game(source,
        key: const ValueKey('companion-scene-archive'),
        locales: await locales(),
        initialSnapshot: const GameSnapshot(
          week: 1,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 13,
          eventIndex: 0,
          stats: {'지혜': 4, '공감': 5, '용기': 3},
          bonds: {'lumi': 1, 'bora': 0, 'taro': 0},
          history: [],
        )));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/companion-scenes.png'));
    await tester.tapAt(const Offset(190, 250));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0-pending')), findsOneWidget,
        reason: 'first card tap opens the choice projection before recording');
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-choice.png'));
    await tester.tapAt(const Offset(190, 300));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0-pending')), findsNothing,
        reason: 'choice-label tap records and closes the pending projection');
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-recorded.png'));
    await tester.tapAt(const Offset(650, 40));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-recorded-en.png'));
  });

  testWidgets('relationship ledger opens the companion scene archive',
      (tester) async {
    await tester.pumpWidget(Game(await story(),
        key: const ValueKey('relationship-to-companion-scenes'),
        initialSnapshot: const GameSnapshot(
          week: 1,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 11,
          eventIndex: 0,
          stats: {'지혜': 4, '공감': 5, '용기': 3},
          bonds: {'lumi': 1, 'bora': 0, 'taro': 0},
          history: [],
        )));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(120, 440));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0')), findsOneWidget);
  });

  testWidgets('companion archive exposes locked feedback and all route pages',
      (tester) async {
    final source = await story();
    await tester.pumpWidget(Game(source,
        key: const ValueKey('companion-scene-atlas'),
        locales: await locales(),
        initialSnapshot: const GameSnapshot(
          week: 48,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 13,
          eventIndex: 0,
          stats: {'지혜': 4, '공감': 5, '용기': 3},
          bonds: {'lumi': 1, 'bora': 1, 'taro': 1},
          flags: {
            'companion-scene:bora-shared-water': true,
            'companion-choice:bora-shared-water:care': true,
          },
          history: [],
        )));
    await tester.pumpAndSettle();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-lumi-mixed.png'));
    await tester.tapAt(const Offset(650, 620));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-bora-mixed.png'));
    await tester.tapAt(const Offset(650, 620));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-taro-mixed.png'));

    await tester.pumpWidget(Game(source,
        key: const ValueKey('companion-scene-locked'),
        locales: await locales(),
        initialSnapshot: const GameSnapshot(
          week: 1,
          coins: 12,
          fatigue: 0,
          selected: 0,
          persona: 0,
          page: 13,
          eventIndex: 0,
          stats: {'지혜': 4, '공감': 5, '용기': 3},
          bonds: {'lumi': 0, 'bora': 0, 'taro': 0},
          history: [],
        )));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(190, 250));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/companion-scene-locked.png'));
  });

  testWidgets('companion rejection feedback exposes stable localized states',
      (tester) async {
    final source = await story(), catalogs = await locales();
    var mountIndex = 0;
    Future<void> mount(GameSnapshot snapshot) async {
      await tester.pumpWidget(Game(source,
          key: ValueKey('companion-scene-rejection-states-${mountIndex++}'),
          locales: catalogs,
          initialSnapshot: snapshot));
      await tester.pumpAndSettle();
    }

    await mount(const GameSnapshot(
      week: 1,
      coins: 12,
      fatigue: 0,
      selected: 0,
      persona: 0,
      page: 13,
      eventIndex: 0,
      stats: {'지혜': 4, '공감': 5, '용기': 3},
      bonds: {'lumi': 0, 'bora': 0, 'taro': 0},
      history: [],
    ));
    await tester.tapAt(const Offset(190, 250));
    await tester.pump();
    expect(
        find.byKey(const ValueKey('13-1-0-0-rejected-bond')), findsOneWidget);

    await mount(const GameSnapshot(
      week: 1,
      coins: 12,
      fatigue: 0,
      selected: 0,
      persona: 0,
      page: 13,
      eventIndex: 0,
      stats: {'지혜': 4, '공감': 5, '용기': 3},
      bonds: {'lumi': 1, 'bora': 0, 'taro': 0},
      history: [],
    ));
    await tester.tapAt(const Offset(530, 250));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0-rejected-chapter')),
        findsOneWidget);

    await mount(const GameSnapshot(
      week: 1,
      coins: 12,
      fatigue: 0,
      selected: 0,
      persona: 0,
      page: 13,
      eventIndex: 0,
      stats: {'지혜': 4, '공감': 5, '용기': 3},
      bonds: {'lumi': 1, 'bora': 0, 'taro': 0},
      flags: {
        'companion-scene:lumi-first-margin': true,
        'companion-choice:lumi-first-margin:open': true,
      },
      history: [],
    ));
    await tester.tapAt(const Offset(190, 250));
    await tester.pump();
    expect(find.byKey(const ValueKey('13-1-0-0-rejected-duplicate')),
        findsOneWidget);
  });
}
