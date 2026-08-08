import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/character_roster.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('character archive contains twenty distinct authored designs', () {
    expect(lumenCharacters, hasLength(20));
    expect(lumenCharacters.map((character) => character.id).toSet(),
        hasLength(20));
    expect(lumenCharacters.map((character) => character.sheetIndex).toSet(),
        {for (var index = 0; index < 20; index++) index});
    expect(
        lumenCharacters.every((character) =>
            character.name.isNotEmpty &&
            character.role.isNotEmpty &&
            character.motif.isNotEmpty),
        isTrue);
  });

  test('character roster PNG is a 5 by 4 sheet', () async {
    final bytes = await rootBundle.load('assets/lumen-character-roster.png');
    final codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    expect(frame.image.width, greaterThan(1000));
    expect(frame.image.height, greaterThan(800));
    expect(frame.image.width / frame.image.height, closeTo(1.25, .08));
  });

  test('SSOT character archive binds every sheet index and asset', () async {
    final source = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final archive = (source['characterArchive'] as List).cast<Map>();
    expect(archive, hasLength(20));
    expect(archive.map((entry) => entry['sheetIndex']).toSet(),
        {for (var index = 0; index < 20; index++) index});
    expect(
        archive.every((entry) =>
            entry['portraitAsset'] == 'assets/lumen-character-roster.png'),
        isTrue);
    expect(archiveCharacters(source).map((character) => character.id),
        archive.map((entry) => '${entry['id']}'));
  });
}
