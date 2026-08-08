import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('ending matrix materializes all eight companion route sets', () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final story = JsonStoryAdapter(source),
        ids = story.companions.map((c) => '${c['id']}').toList(),
        observed = <String>{};
    for (var mask = 0; mask < 1 << ids.length; mask++) {
      final bonds = {
        for (var i = 0; i < ids.length; i++)
          ids[i]: mask & (1 << i) == 0 ? 0 : 8
      };
      final ending = resolveEnding(story, {'지혜': 60, '공감': 10, '용기': 10},
          bonds: bonds, milestones: {'spring': true, 'winter': true});
      observed.add('${ending['routeId']}');
    }
    expect(story.endingDesign['maximumCompanionRouteSets'], 8);
    expect(observed, hasLength(8));
    expect(observed, contains('stargazer-master::solo'));
    expect(observed, contains('stargazer-master::lumi+bora+taro'));
    print(
        'ENDING_MATRIX_OK: routeSets=${observed.length} core=stargazer-master');
  });
}
