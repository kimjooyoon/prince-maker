import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/save_state.dart';

Future<Map<String, dynamic>> story() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> locales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

void main() {
  testWidgets('event locale control changes the event Canvas state',
      (tester) async {
    final source = await story();
    await tester.pumpWidget(Game(source,
        locales: await locales(),
        initialSnapshot: const GameSnapshot(
            week: 2,
            coins: 12,
            fatigue: 0,
            selected: 0,
            persona: 0,
            page: 3,
            eventIndex: 0,
            stats: {'지혜': 4, '공감': 5, '용기': 3},
            history: [])));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('3-2-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-2-0-0-en')), findsOneWidget);
  });

  testWidgets('visible illustration back label returns home', (tester) async {
    final source = await story();
    await tester.pumpWidget(Game(source,
        locales: await locales(),
        initialSnapshot: const GameSnapshot(
            week: 1,
            coins: 12,
            fatigue: 0,
            selected: 0,
            persona: 0,
            page: 1,
            eventIndex: 0,
            stats: {'지혜': 4, '공감': 5, '용기': 3},
            history: [])));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('1-1-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(600, 560));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
  });
}
