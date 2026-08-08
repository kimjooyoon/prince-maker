import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('eight SSOT chapters cover the complete 24-week progression', () async {
    final story = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final chapters =
        (story['progression'] as List).cast<Map<String, dynamic>>();
    expect(chapters.length, 8);
    expect(
        chapters
            .map((chapter) => '${chapter['weekStart']}-${chapter['weekEnd']}')
            .join(','),
        '1-3,4-6,7-9,10-12,13-15,16-18,19-21,22-24');
    final events = (story['events'] as List).cast<Map<String, dynamic>>();
    final eventWeeks = events.map((event) => event['week']).toSet();
    expect(events.map((event) => event['week']).join(','), '2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23');
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
    expect((story['dialogueMetrics'] as Map)['minimumVisibleDialogueLines'], 23);
    expect(
        (story['dialogueMetrics'] as Map)['minimumVisibleNarrativeUnits'], 64);
  });
}
