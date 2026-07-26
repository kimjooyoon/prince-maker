import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/main.dart';

Future<Map<String, Map<String, String>>> loadLocales() async {
  final locales = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final raw = jsonDecode(await rootBundle.loadString('story/locales/$locale.json')) as Map;
    locales[locale] = raw.map((key, value) => MapEntry('$key', '$value'));
  }
  return locales;
}

void main() {
  testWidgets('English locale renders original personality and event dialogue', (tester) async {
    final story = jsonDecode(await rootBundle.loadString('story/story.json')) as Map<String, dynamic>;
    final locales = await loadLocales();
    await tester.pumpWidget(Game(story, locales: locales));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(500, 550));
    await tester.pump();
    await tester.tapAt(const Offset(300, 580));
    await tester.pump();
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    expect(find.byKey(const ValueKey('1-1-1-0-en')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/english-illustration.png'));
    await tester.tapAt(const Offset(750, 580));
    await tester.pump();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-2-1-0-en')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/english-event.png'));
  });
}
