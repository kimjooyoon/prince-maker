import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:prince_maker/jsonl.dart';

String storyHash() =>
    sha256.convert(File('story/story.jsonl').readAsBytesSync()).toString();

void refresh(String path, String ref) {
  final file = File(path), document = decodeJsonl(file.readAsStringSync());
  final source = (document['source'] as Map).cast<String, dynamic>();
  source['ref'] = ref;
  source['sha256'] = storyHash();
  document['source'] = source;
  file.writeAsStringSync(
      encodeJsonl(document, schema: 'lumen-document-jsonl-v1', document: path));
  stdout.writeln('SSOT_CONTRACT_HASH_REFRESHED: $path');
}

void main() {
  refresh(
      'docs/decision-proof-contract.jsonl', 'story/story.jsonl#decisionSystem');
  refresh('docs/originality-contract.jsonl', 'story/story.jsonl#root');
}
