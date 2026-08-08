import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> story() async => jsonDecode(utf8
    .decode((await rootBundle.load('story/story.json')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> locales() async {
  final result = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final raw =
        jsonDecode(await rootBundle.loadString('story/locales/$locale.json'))
            as Map;
    result[locale] = raw.map((key, value) => MapEntry('$key', '$value'));
  }
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Canvas fate ledger renders the deterministic narrative loop',
      (tester) async {
    final source = await story(), flags = <String, bool>{};
    for (final thread in (source['fateThreads'] as List).cast<Map>()) {
      flags['${thread['flag']}'] = true;
    }
    for (final quest in (source['companionQuests'] as List).cast<Map>())
      for (final stage in (quest['stages'] as List).cast<Map>())
        flags['${stage['flag']}'] = true;
    final snapshot = GameSnapshot(
        week: 24,
        coins: 18,
        fatigue: 2,
        selected: 0,
        persona: 0,
        page: 5,
        eventIndex: 22,
        stats: {'지혜': 34, '공감': 31, '용기': 28},
        bonds: {'lumi': 8, 'bora': 8, 'taro': 8},
        flags: flags,
        history: const ['event:첫 결산|flag:first-ledger']);
    await tester.pumpWidget(
        Game(source, locales: await locales(), initialSnapshot: snapshot));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('5-24-0-22')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/narrative-ledger.png'));
    await tester.tapAt(const Offset(650, 40));
    await tester.pump();
    expect(find.byKey(const ValueKey('5-24-0-22-en')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/narrative-ledger-en.png'));
  });
}
