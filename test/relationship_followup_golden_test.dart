import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('relationship follow-up is a deterministic closure Golden',
      (tester) async {
    final source = await loadStory(),
        story = JsonStoryAdapter(source),
        session = GameSession(story, MemorySaveAdapter());
    session.choose(const ActivityChosen('지혜', 3, 0, 1, label: '별 관측'));
    final choice = story.events
        .firstWhere((event) => event['week'] == 2)['choices'][0] as Map;
    session.chooseEvent(StoryChoiceMade(
        choice['stat'], choice['delta'], choice['coins'], choice['label'],
        bondId: choice['bondId'],
        bondDelta: choice['bondDelta'],
        line: choice['line']));
    await tester
        .pumpWidget(Game(source, initialSnapshot: session.snapshot(page: 6)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('6-2-0-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-followup.png'));
  });
}
