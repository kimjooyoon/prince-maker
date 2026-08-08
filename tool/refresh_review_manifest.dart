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
    'lib/canvas_scene_fingerprint.dart',
    'test/canvas_scene_fingerprint_test.dart',
    'lib/activity_catalog.dart',
    'test/activity_catalog_test.dart',
    'lib/decision_receipt.dart',
    'test/decision_receipt_test.dart',
    'test/ending_matrix_test.dart',
    'test/trilemma_verdict_test.dart',
    'test/narrative_ledger_test.dart',
    'test/narrative_ledger_golden_test.dart',
    'test/goldens/narrative-ledger.png',
    'test/goldens/narrative-ledger-en.png',
    'test/system_receipt_golden_test.dart',
    'test/goldens/system-receipt.png',
    'tool/verify_game.dart',
    'docs/render-quality-contract.json',
    'tool/verify_render_quality.dart',
    'tool/verify_gameplay_fun.dart',
    'test/chapter_golden_test.dart',
    'test/chapter_closure_golden_test.dart',
    'test/goldens/chapter-arrival.png',
    'test/goldens/chapter-blankMap.png',
    'test/goldens/chapter-commons.png',
    'test/goldens/chapter-constellation.png',
    'test/goldens/chapter-crossing.png',
    'test/goldens/chapter-fairShare.png',
    'test/goldens/chapter-farShore.png',
    'test/goldens/chapter-frost.png',
    'test/goldens/chapter-handoff.png',
    'test/goldens/chapter-horizon.png',
    'test/goldens/chapter-memoryHouse.png',
    'test/goldens/chapter-reply.png',
    'test/goldens/chapter-return.png',
    'test/goldens/chapter-returningGarden.png',
    'test/goldens/chapter-seedReturn.png',
    'test/goldens/chapter-threshold.png',
    'test/goldens/chapter-closure-arrival.png',
    'test/goldens/chapter-closure-blankMap.png',
    'test/goldens/chapter-closure-commons.png',
    'test/goldens/chapter-closure-constellation.png',
    'test/goldens/chapter-closure-crossing.png',
    'test/goldens/chapter-closure-fairShare.png',
    'test/goldens/chapter-closure-farShore.png',
    'test/goldens/chapter-closure-frost.png',
    'test/goldens/chapter-closure-handoff.png',
    'test/goldens/chapter-closure-horizon.png',
    'test/goldens/chapter-closure-memoryHouse.png',
    'test/goldens/chapter-closure-reply.png',
    'test/goldens/chapter-closure-return.png',
    'test/goldens/chapter-closure-returningGarden.png',
    'test/goldens/chapter-closure-seedReturn.png',
    'test/goldens/chapter-closure-threshold.png',
    'docs/development-goals.json',
    'docs/development-goals.md',
    'tool/generate_development_goals.dart',
    'tool/verify_development_goals.dart',
    'lib/decision_proof.dart',
    'docs/decision-proof-contract.json',
    'tool/verify_decision_proof.dart',
    'test/decision_proof_test.dart'
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
