import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all side-scene type and mechanic labels fit the copy contract',
      () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final locales = <String, Map<String, String>>{};
    for (final locale in ['ko', 'en']) {
      locales[locale] = decodeJsonlCatalog(utf8.decode(
          (await rootBundle.load('story/locales/$locale.jsonl'))
              .buffer
              .asUint8List()));
    }
    final scenes = (story['sideScenes'] as List).cast<Map>();
    final types = scenes.map((scene) => '${scene['sceneType']}').toSet();
    final mechanics = scenes.map((scene) => '${scene['mechanic']}').toSet();
    for (final catalog in locales.values) {
      for (final type in types) {
        expect(catalog['ui.sideScene.type.$type'], isNotEmpty);
      }
      for (final mechanic in mechanics) {
        expect(catalog['ui.sideScene.mechanic.$mechanic'], isNotEmpty);
      }
      for (final key in [
        'ui.sideScene.title',
        'ui.sideScene.subtitle',
        'ui.sideScene.choice',
        'ui.sideScene.previous',
        'ui.sideScene.next',
        'ui.sideScene.back',
        'ui.sideScene.status.completed',
        'ui.sideScene.status.available',
        'ui.sideScene.status.locked',
        'ui.sideScene.lock.completed',
        'ui.sideScene.lock.companion',
        'ui.sideScene.lock.memory',
        'ui.sideScene.lock.stat',
        'ui.sideScene.lock.generic',
      ]) {
        expect(catalog[key], isNotEmpty, reason: key);
      }
    }
    for (final scene in scenes) {
      for (final choice in (scene['choices'] as List).cast<Map>()) {
        expect('${choice['label']}'.runes.length, lessThanOrEqualTo(48));
        expect('${choice['line']}'.runes.length, lessThanOrEqualTo(120));
      }
      expect('${scene['body']}'.runes.length, lessThanOrEqualTo(180));
      expect('${scene['prompt']}'.runes.length, lessThanOrEqualTo(120));
      expect('${scene['consequence']}'.runes.length, lessThanOrEqualTo(120));
    }
  });
}
