import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('scenario completeness specimen covers every authored closure',
      () async {
    final source = jsonDecode(await rootBundle.loadString('story/story.json'))
        as Map<String, dynamic>;
    final model = source['scenarioCompleteness'] as Map<String, dynamic>;
    final dimensions =
        (model['dimensions'] as List).cast<Map<String, dynamic>>();
    expect(dimensions.map((d) => d['id']).toSet(), {
      'arc',
      'agency',
      'relationship',
      'feedback',
      'gating',
      'replay',
      'presentation',
      'closure'
    });
    final chapters =
        (source['progression'] as List).cast<Map<String, dynamic>>();
    final events = (source['events'] as List).cast<Map<String, dynamic>>();
    expect(chapters.length, 4);
    expect(
        chapters.every((chapter) =>
            (chapter['eventWeeks'] as List).isNotEmpty &&
            events.any((event) =>
                (chapter['eventWeeks'] as List).contains(event['week']))),
        isTrue);
    final choices = events
        .expand(
            (event) => (event['choices'] as List).cast<Map<String, dynamic>>())
        .toList();
    expect(choices.length, 16);
    expect(
        choices.every((choice) =>
            choice['stat'] is String &&
            choice['delta'] is int &&
            choice['bondId'] is String &&
            choice['bondDelta'] is int &&
            (choice['line'] as String).isNotEmpty),
        isTrue);
  });
}
