import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/main.dart';

void main() {
  testWidgets('canonical SSOT renders a stable Canvas ending', (tester) async {
    final source =
        jsonDecode(await rootBundle.loadString('story/story.json')) as Map;
    await tester.pumpWidget(Game(Map<String, dynamic>.from(source)));
    await tester.pumpAndSettle();
    const eventWeeks = {2, 3, 4, 6, 7, 8, 9, 10};
    for (var week = 1; week <= 11; week++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
      if (eventWeeks.contains(week + 1)) {
        await tester.tapAt(Offset(week + 1 == 6 ? 500 : 200, 350));
        await tester.pump();
      }
    }
    expect(find.byKey(const ValueKey('2-12-0-7')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/canonical-ending.png'));
  });
}
