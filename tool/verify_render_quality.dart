import 'dart:convert';
import 'dart:io';

Never fail(String message) {
  stderr.writeln('RENDER_QUALITY_GATE_FAIL: $message');
  exit(1);
}

String read(String path) {
  final file = File(path);
  if (!file.existsSync()) fail('missing evidence file $path');
  return file.readAsStringSync();
}

void requireText(String path, String source, String phrase) {
  if (!source.contains(phrase)) fail('$path is missing "$phrase"');
}

void main() {
  final contract = jsonDecode(read('docs/render-quality-contract.json'))
      as Map<String, dynamic>;
  if (contract['schema'] != 'lumen-render-quality-v1' ||
      contract['version'] != 1) {
    fail('unsupported render quality contract');
  }
  final preconditions = (contract['preconditions'] as List? ?? const [])
      .cast<Map<String, dynamic>>();
  final proofs =
      (contract['proofs'] as List? ?? const []).cast<Map<String, dynamic>>();
  const requiredPreconditions = {
    'viewport-geometry',
    'tap-inverse',
    'single-render-path'
  };
  const requiredProofs = {
    'viewport-mapping',
    'visual-regression',
    'static-analysis'
  };
  final actualPreconditions = preconditions.map((entry) => entry['id']).toSet(),
      actualProofs = proofs.map((entry) => entry['id']).toSet();
  if (actualPreconditions.length != requiredPreconditions.length ||
      !actualPreconditions.containsAll(requiredPreconditions) ||
      actualProofs.length != requiredProofs.length ||
      !actualProofs.containsAll(requiredProofs)) {
    fail('render quality contract must declare all preconditions and proofs');
  }
  final decision = (contract['decision'] as Map).cast<String, dynamic>();
  if (decision['owner'] != 'Lumen Render Quality Gate' ||
      decision['mode'] != 'system-adjudicated' ||
      decision['humanApprovalRequired'] != false ||
      decision['failureMode'] != 'fail-closed' ||
      decision['onlyBlockingCondition'] !=
          'failed or missing deterministic proof') {
    fail('render quality decision must be system-owned and fail-closed');
  }

  final viewport = read('lib/canvas_surface.dart'),
      main = read('lib/main.dart');
  requireText('lib/canvas_surface.dart', viewport,
      'min(viewport.width / logicalSize.width,');
  requireText('lib/canvas_surface.dart', viewport, 'logicalTap');
  requireText('lib/main.dart', main, 'CanvasViewport.logicalTap');
  requireText('lib/main.dart', main, 'CanvasViewport.frame');
  requireText('lib/main.dart', main, 'LayoutBuilder');
  requireText('lib/main.dart', main, 'size: viewport');
  final surfaceTest = read('test/canvas_surface_test.dart');
  requireText('test/canvas_surface_test.dart', surfaceTest,
      'maps centered taps deterministically');
  final goldenTest = read('test/golden_test.dart');
  requireText('test/golden_test.dart', goldenTest, 'matchesGoldenFile');
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  if (goldens < 30)
    fail('expected at least 30 golden evidence files, found $goldens');
  stdout.writeln(
      'RENDER_QUALITY_PRECONDITIONS_OK: preconditions=${preconditions.length} proofs=${proofs.length} goldens=$goldens');
}
