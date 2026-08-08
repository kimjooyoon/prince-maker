import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('sixteen SSOT chapters cover the complete 48-week progression',
      () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final chapters =
        (story['progression'] as List).cast<Map<String, dynamic>>();
    final campaignWeeks = story['campaignWeeks'] as int;
    expect(chapters.length, campaignWeeks ~/ 3);
    expect(
        chapters
            .map((chapter) => '${chapter['weekStart']}-${chapter['weekEnd']}')
            .join(','),
        [
          for (var start = 1; start <= campaignWeeks; start += 3)
            '$start-${start + 2}'
        ].join(','));
    final events = (story['events'] as List).cast<Map<String, dynamic>>();
    final eventWeeks = events.map((event) => event['week']).toSet();
    expect(events.map((event) => event['week']).join(','),
        [for (var week = 2; week <= campaignWeeks; week++) week].join(','));
    for (final chapter in chapters) {
      expect(chapter['titleKey'], isA<String>());
      expect(chapter['premiseKey'], isA<String>());
      expect(chapter['payoffKey'], isA<String>());
      expect(
          (chapter['eventWeeks'] as List).every(eventWeeks.contains), isTrue);
      expect(
          (story['milestones'] as List)
              .any((milestone) => milestone['id'] == chapter['milestoneId']),
          isTrue);
    }
    expect(story['dialogueMetrics'], isA<Map>());
    expect((story['dialogueMetrics'] as Map)['minimumVisibleDialogueLines'],
        events.length + chapters.length);
    expect((story['dialogueMetrics'] as Map)['minimumVisibleNarrativeUnits'],
        greaterThanOrEqualTo(160));
  });
}
