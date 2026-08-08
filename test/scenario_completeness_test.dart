import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('scenario completeness specimen covers every authored closure',
      () async {
    final source = jsonDecode(utf8.decode(
            (await rootBundle.load('story/story.json')).buffer.asUint8List()))
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
    expect(chapters.length, source['campaignWeeks'] ~/ 3);
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
    expect(choices.length, events.length * 2);
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

  test('2,000-case route budget and ending matrix are executable', () async {
    final source = jsonDecode(utf8.decode(
            (await rootBundle.load('story/story.json')).buffer.asUint8List()))
        as Map<String, dynamic>;
    final budget = source['scenarioVariantBudget'] as Map<String, dynamic>;
    final branchWeeks = (budget['branchWeeks'] as List).cast<int>();
    final branchVectors = 1 << branchWeeks.length;
    expect(budget['minimumCases'], greaterThanOrEqualTo(2000));
    expect(budget['authoredBranchVectors'], branchVectors);
    expect(
        budget['routeInputCases'],
        branchVectors *
            (source['activities'] as List).length *
            (source['personalities'] as List).length *
            ((source['legacyProfiles'] as List).length + 1));
    expect(budget['verifiedReachableCases'], greaterThanOrEqualTo(2000));

    final story = JsonStoryAdapter(source);
    final ending = resolveEnding(
      story,
      {'지혜': 60, '공감': 10, '용기': 10},
      bonds: {'lumi': 8, 'bora': 8, 'taro': 8},
      milestones: {'spring': true, 'winter': true},
    );
    expect(ending['id'], 'stargazer-master');
    expect(ending['endingFamily'], 'stargazer');
    expect(ending['endingTier'], 'master');
    expect(ending['routeId'], 'stargazer-master::lumi+bora+taro');
    expect(ending['companionRouteIds'], ['lumi', 'bora', 'taro']);
  });
}
