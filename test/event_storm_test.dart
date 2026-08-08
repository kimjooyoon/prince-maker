import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  test('event storm covers every authored unit and closes each choice loop',
      () {
    final artifact =
        decodeJsonl(File('docs/event-storm.jsonl').readAsStringSync());
    final summary = (artifact['summary'] as Map).cast<String, dynamic>();
    final nodes = (artifact['nodes'] as List).cast<Map<String, dynamic>>();
    expect(artifact['schema'], 'lumen-event-storm-v1');
    expect(nodes, hasLength(133));
    expect(summary['choiceCount'], 166);
    expect(summary['effectCoverage'], 1.0);
    expect(summary['feedbackCoverage'], 1.0);
    expect(summary['tradeoffChoices'], greaterThanOrEqualTo(72));
    expect(summary['gatedChoices'], greaterThanOrEqualTo(29));
    expect(
      (summary['mechanics'] as List),
      containsAll(
          {'exploration', 'resource-crisis', 'mini-game', 'companion-pair'}),
    );
    expect(
      nodes.map((node) => node['id']).toSet(),
      hasLength(nodes.length),
    );
    for (final node in nodes.where((node) =>
        node['kind'] == 'main-event' || node['kind'] == 'side-scene')) {
      final commands = node['commands'] as List;
      final domainEvents = node['domainEvents'] as List;
      expect(commands.length, domainEvents.length,
          reason: '${node['id']} must close command to domain event');
      for (final event in domainEvents.cast<Map<String, dynamic>>()) {
        expect(event['axes'], isNotEmpty,
            reason: '${node['id']} must change a state axis');
        expect(event['hasFeedback'], true,
            reason: '${node['id']} must return authored feedback');
      }
    }
  });
}
