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
    const axes = {'stat', 'coins', 'fatigue', 'bond'};
    expect(chapters.every((chapter) {
      final contract = (chapter['contract'] as Map).cast<String, dynamic>();
      final eventWeeks = (chapter['eventWeeks'] as List).cast<int>();
      final choiceWeeks = (contract['choiceWeeks'] as List).cast<int>();
      final pressure = (contract['pressureAxes'] as List).cast<String>();
      final closing = source['milestones']
          .cast<Map<String, dynamic>>()
          .firstWhere((m) => m['id'] == contract['closureMilestone']);
      return (contract['reveal'] as String).isNotEmpty &&
          pressure.length >= 2 &&
          pressure.toSet().difference(axes).isEmpty &&
          choiceWeeks.toSet().containsAll(eventWeeks) &&
          choiceWeeks
              .every((week) => events.any((event) => event['week'] == week)) &&
          closing['week'] == chapter['weekEnd'];
    }), isTrue,
        reason: 'each chapter must prove reveal → pressure → choice → closure');
    final choices = events
        .expand(
            (event) => (event['choices'] as List).cast<Map<String, dynamic>>())
        .toList();
    expect(choices.length, 20);
    expect(
        choices.every((choice) =>
            choice['stat'] is String &&
            choice['delta'] is int &&
            choice['bondId'] is String &&
            choice['bondDelta'] is int &&
            (choice['line'] as String).isNotEmpty),
        isTrue);
    final rivalDeltas = choices
        .where((choice) => choice['rivalDelta'] is int)
        .map((choice) => choice['rivalDelta'] as int)
        .toList();
    expect(rivalDeltas, contains(-1));
    expect(rivalDeltas, contains(1));
    expect(choices.any((choice) => choice['setsFlag'] == 'windmill-truce'),
        isTrue);
  });
}
