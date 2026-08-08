import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String hash(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

void main() {
  final file = File('docs/review-manifest.json');
  final manifest = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final entries =
      (manifest['reviewedFiles'] as List).cast<Map<String, dynamic>>();
  final known = {for (final entry in entries) entry['path'] as String: entry};
  for (final entry in entries) {
    final path = entry['path'] as String;
    entry['sha256'] = hash(path);
  }
  for (final path in [
    'tool/expand_story.dart',
    'tool/refresh_review_manifest.dart',
    'tool/verify_scenario_variants.dart',
    'tool/trilemma_verdict.dart',
    'test/canvas_surface_test.dart',
    'test/ending_matrix_test.dart',
    'test/trilemma_verdict_test.dart',
    'test/narrative_ledger_test.dart',
    'test/narrative_ledger_golden_test.dart',
    'test/goldens/narrative-ledger.png',
    'test/goldens/narrative-ledger-en.png'
  ]) {
    if (!known.containsKey(path)) {
      entries
          .add({'path': path, 'ref': '$path#reviewed', 'sha256': hash(path)});
    }
  }
  file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(manifest)}\n');
  stdout.writeln('REVIEW_MANIFEST_REFRESHED: ${entries.length} files');
}
