import 'dart:io';
import 'package:prince_maker/jsonl.dart';

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
  final contract = decodeJsonl(read('docs/render-quality-contract.jsonl'));
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
  final chapterGoldenTest = read('test/chapter_golden_test.dart');
  requireText('test/chapter_golden_test.dart', chapterGoldenTest,
      'all sixteen SSOT chapters have deterministic event Goldens');
  requireText('test/chapter_golden_test.dart', chapterGoldenTest,
      'goldens/chapter-\$id.png');
  final chapterClosureGoldenTest =
      read('test/chapter_closure_golden_test.dart');
  final relationshipArchiveGoldenTest =
      read('test/relationship_archive_golden_test.dart');
  final playerFacingGoldenTest = read('test/player_facing_golden_test.dart');
  final activityForecastGoldenTest =
      read('test/activity_forecast_golden_test.dart');
  final activityReflectionGoldenTest =
      read('test/activity_reflection_golden_test.dart');
  final activityJournalGoldenTest =
      read('test/activity_journal_golden_test.dart');
  final characterRosterGoldenTest =
      read('test/character_roster_golden_test.dart');
  final environmentAtlasGoldenTest = read('test/environment_golden_test.dart');
  requireText('test/chapter_closure_golden_test.dart', chapterClosureGoldenTest,
      'all sixteen SSOT chapter closures have deterministic goal Goldens');
  requireText('test/chapter_closure_golden_test.dart', chapterClosureGoldenTest,
      'goldens/chapter-closure-\$id.png');
  requireText('lib/main.dart', main, 'chapterClosure(c)');
  requireText('lib/main.dart', main, 'page == 6');
  requireText('lib/main.dart', main, "ui.closure.scene");
  requireText('test/chapter_closure_golden_test.dart', chapterClosureGoldenTest,
      'relationship scene must bind a speaker');
  requireText('test/character_roster_golden_test.dart',
      characterRosterGoldenTest, 'goldens/character-roster.png');
  requireText('test/character_roster_golden_test.dart',
      characterRosterGoldenTest, 'goldens/character-roster-en.png');
  requireText('test/environment_golden_test.dart', environmentAtlasGoldenTest,
      'goldens/environment-atlas.png');
  requireText('test/environment_golden_test.dart', environmentAtlasGoldenTest,
      'goldens/environment-atlas-en.png');
  for (final name in [
    'goldens/relationship-archive.png',
    'goldens/relationship-archive-kind.png',
    'goldens/relationship-archive-bold.png',
  ]) {
    requireText('test/relationship_archive_golden_test.dart',
        relationshipArchiveGoldenTest, name);
  }
  requireText(
      'test/activity_forecast_golden_test.dart',
      activityForecastGoldenTest,
      'home shows deterministic activity forecasts');
  requireText('test/activity_forecast_golden_test.dart',
      activityForecastGoldenTest, 'goldens/activity-forecast.png');
  requireText(
      'test/activity_reflection_golden_test.dart',
      activityReflectionGoldenTest,
      'event shows localized activity reflection after day spend');
  requireText('test/activity_reflection_golden_test.dart',
      activityReflectionGoldenTest, 'goldens/activity-reflection-en.png');
  requireText(
      'test/activity_journal_golden_test.dart',
      activityJournalGoldenTest,
      'activity journal renders deterministic reflection pages');
  requireText('test/activity_journal_golden_test.dart',
      activityJournalGoldenTest, 'goldens/activity-journal-en.png');
  requireText('test/player_facing_golden_test.dart', playerFacingGoldenTest,
      'all personality illustration pages render deterministic portraits');
  for (final name in [
    'goldens/personality-quiet.png',
    'goldens/personality-kind.png',
    'goldens/personality-bold.png',
  ]) {
    requireText(
        'test/player_facing_golden_test.dart', playerFacingGoldenTest, name);
  }
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  if (goldens < 30)
    fail('expected at least 30 golden evidence files, found $goldens');
  final chapterGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .where((file) =>
          file.uri.pathSegments.last.startsWith('chapter-') &&
          !file.uri.pathSegments.last.startsWith('chapter-closure-'))
      .length;
  if (chapterGoldens != 16)
    fail(
        'expected exactly 16 chapter golden evidence files, found $chapterGoldens');
  final chapterClosureGoldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .where(
          (file) => file.uri.pathSegments.last.startsWith('chapter-closure-'))
      .length;
  if (chapterClosureGoldens != 16)
    fail(
        'expected exactly 16 chapter closure golden evidence files, found $chapterClosureGoldens');
  stdout.writeln(
      'RENDER_QUALITY_PRECONDITIONS_OK: preconditions=${preconditions.length} proofs=${proofs.length} goldens=$goldens chapterGoldens=$chapterGoldens chapterClosureGoldens=$chapterClosureGoldens');
}
