import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void main() {
  final story = decodeJsonl(File('story/story.jsonl').readAsStringSync());
  final characters = (story['characterArchive'] as List).cast<Map>();
  final events = (story['events'] as List).cast<Map>();
  const emotions = ['calm', 'joy', 'concern', 'resolve', 'wonder'];
  const major = ['noa', 'lumi', 'bora', 'taro'];
  final metadata = <String, dynamic>{
    'formula': '5 * 20 + 4 * 47 = 288',
    'emotionCount': emotions.length,
    'characterCount': characters.length,
    'majorCharacterCount': major.length,
    'mainEventCount': events.length,
    'sideSceneCount': (story['sideScenes'] as List).length,
    'emotionFrameCount': emotions.length * characters.length,
    'eventFrameCount': major.length * events.length,
    'totalFrameCount':
        emotions.length * characters.length + major.length * events.length,
    'packaging': '20 character sheets + 47 event sheets = 67 PNG sheets',
    'scope': 'main events only; sideScenes are a separate future expansion',
  };
  final rows = <Map<String, dynamic>>[
    {
      'type': 'header',
      'schema': 'lumen-document-jsonl-v1',
      'document': 'design/image-design-matrix.jsonl',
    },
    ...metadata.entries.map(
        (entry) => {'type': 'field', 'key': entry.key, 'value': entry.value}),
  ];
  for (var i = 0; i < characters.length; i++) {
    final id = '${characters[i]['id']}';
    final asset = '${characters[i]['emotionAsset']}';
    rows.add({
      'type': 'item',
      'section': 'characterEmotionSheets',
      'index': i,
      'id': id,
      'value': {
        'id': id,
        'characterId': id,
        'asset': asset,
        'frameCount': emotions.length,
        'emotionIds': emotions,
        'sha256': sha(asset),
      },
    });
  }
  for (var i = 0; i < events.length; i++) {
    final id = '${events[i]['id'] ?? events[i]['week']}';
    final asset = '${events[i]['illustrationAsset']}';
    rows.add({
      'type': 'item',
      'section': 'eventIllustrationSheets',
      'index': i,
      'id': id,
      'value': {
        'id': id,
        'eventId': id,
        'asset': asset,
        'frameCount': major.length,
        'majorCharacterIds': major,
        'sha256': sha(asset),
      },
    });
  }
  File('design/image-design-matrix.jsonl')
      .writeAsStringSync(rows.map(jsonEncode).join('\n') + '\n');
  stdout.writeln(
      'IMAGE_MATRIX_OK: characterSheets=${characters.length} eventSheets=${events.length} totalFrames=${emotions.length * characters.length + major.length * events.length}');
}
