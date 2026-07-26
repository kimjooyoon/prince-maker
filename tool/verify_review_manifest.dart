import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Never fail(String message) { stderr.writeln('REVIEW_GATE_FAIL: $message'); exit(1); }
void main() {
  final manifest = jsonDecode(File('docs/review-manifest.json').readAsStringSync()) as Map<String, dynamic>;
  if (manifest['schema'] != 'agent-review-v1') fail('unsupported manifest schema');
  for (final entry in (manifest['reviewedFiles'] as List).cast<Map<String, dynamic>>()) {
    final path = entry['path'] as String;
    if (!File(path).existsSync()) fail('missing reviewed file $path');
    final actual = sha256.convert(File(path).readAsBytesSync()).toString();
    if (actual != entry['sha256']) fail('$path changed; reread it and update its hash/ref');
    if ((entry['ref'] as String).isEmpty) fail('$path has no source ref');
  }
  stdout.writeln('REVIEW_GATE_OK: ${manifest['reviewedFiles'].length} files read+hashed at ${manifest['reviewedRef']}');
}
