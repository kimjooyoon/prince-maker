import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/environment_catalog.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('six locations expose a complete environment design contract', () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final environments = environmentsFromStory(story);
    expect(environments, hasLength(6));
    expect(environments.map((environment) => environment.id).toSet(), {
      'archive',
      'greenhouse',
      'market',
      'river-road',
      'observatory',
      'quarry',
    });
    expect(
        environments.every((environment) =>
            environment.motif.isNotEmpty &&
            environment.affordance.isNotEmpty &&
            environment.weather.isNotEmpty &&
            environment.activity.isNotEmpty),
        isTrue);
  });

  test('environment gameplay promises map to distinct primary axes', () {
    final environments = environmentsFromStory({
      'locations': [
        {'id': 'archive', 'name': '기록관', 'nameKey': 'location.archive.name'},
        {
          'id': 'greenhouse',
          'name': '온실',
          'nameKey': 'location.greenhouse.name'
        },
        {'id': 'market', 'name': '시장', 'nameKey': 'location.market.name'},
        {
          'id': 'river-road',
          'name': '바람길',
          'nameKey': 'location.riverRoad.name'
        },
        {
          'id': 'observatory',
          'name': '관측소',
          'nameKey': 'location.observatory.name'
        },
        {'id': 'quarry', 'name': '채석장', 'nameKey': 'location.quarry.name'},
      ],
    });
    expect(environments.map((environment) => environment.stat).toSet(),
        hasLength(6));
  });
}
