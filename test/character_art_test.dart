import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/character_art.dart';
import 'package:prince_maker/character_roster.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every resident has a distinct illustration and emotion contract',
      () async {
    final story = decodeJsonl(utf8.decode(
        (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
    final characters = archiveCharacters(story);
    final art = characterArtFromStory(story);

    expect(art, hasLength(20));
    expect(art.map((entry) => entry.id).toSet(), hasLength(20));
    expect(art.map((entry) => entry.illustration).toSet(), hasLength(20));
    expect(art.map((entry) => entry.silhouette).toSet(), hasLength(20));
    expect(art.map((entry) => entry.gesture).toSet(), hasLength(20));
    expect(
        art.every((entry) =>
            entry.emotionNotes.length == lumenEmotionStates.length &&
            entry.emotionNotesEn.length == lumenEmotionStates.length &&
            entry.illustration.isNotEmpty &&
            entry.silhouette.isNotEmpty &&
            entry.gesture.isNotEmpty),
        isTrue);
    expect(art.map((entry) => entry.id), characters.map((entry) => entry.id));
  });

  test('emotion vocabulary is stable for every art surface', () {
    expect(lumenEmotionStates.map((state) => state.id),
        ['calm', 'joy', 'concern', 'resolve', 'wonder']);
    expect(
        lumenEmotionStates.map((state) => state.label).toSet(), hasLength(5));
    expect(
        lumenEmotionStates.map((state) => state.labelEn).toSet(), hasLength(5));
  });
}
