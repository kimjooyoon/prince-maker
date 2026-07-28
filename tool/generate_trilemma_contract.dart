import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String sha(String path) =>
    sha256.convert(File(path).readAsBytesSync()).toString();

Map<String, dynamic> buildContract(Map<String, dynamic> story, String hash) {
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final choices = events.fold<int>(
      0, (sum, event) => sum + (event['choices'] as List).length);
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  final dialogue = (story['dialogueMetrics'] as Map).cast<String, dynamic>();
  return {
    'schema': 'prince-maker-trilemma-v1',
    'source': {'ref': 'story/story.json#root', 'sha256': hash},
    'axes': [
      {
        'id': 'completeness',
        'targetScore': 0.95,
        'unit': 'gate-score',
        'guardrails': {
          'scenarioDimensions': 8,
          'authoredBranches': choices + (story['endings'] as List).length,
          'goldens': goldens,
          'localeKeys': dialogue['minimumLocaleKeys'],
        },
        'evidence': [
          'tool/verify_game.dart#scenario-contract',
          'test/scenario_completeness_test.dart#scenario-closure',
          'test/golden_test.dart#all',
          'test/locale_contract_test.dart#ssot-dialogue-contract',
        ],
      },
      {
        'id': 'purity',
        'targetScore': 0.75,
        'unit': 'route-variety',
        'guardrails': {
          'schedulePolicies': (story['activities'] as List).length,
          'minDistinctEndings': 3,
          'minDistinctSignatures': 3,
          'minLegacyProfiles': (story['legacyProfiles'] as List? ?? []).length,
          'minLegacyTargetEndings':
              (story['legacyProfiles'] as List? ?? []).length,
          'deterministicReplay': true,
        },
        'evidence': [
          'test/gameplay_metrics_test.dart#route-variety',
          'test/purity_integration_test.dart#same-schedule-budget-outcomes',
        ],
      },
      {
        'id': 'performance',
        'targetScore': 0.95,
        'unit': 'campaign-throughput',
        'guardrails': {
          'campaigns': 5000,
          'transitionBudget': 105000,
          'maxMillis': 5000,
          'minSignatures': 3,
          'lineageProfiles': (story['legacyProfiles'] as List? ?? []).length,
          'lineageTargetEndings':
              (story['legacyProfiles'] as List? ?? []).length,
          'checksumReplayMustMatch': true,
        },
        'evidence': [
          'tool/benchmark_game.dart#ssot-campaign-throughput-signatures'
        ],
      },
    ],
  };
}

void main(List<String> args) {
  const input = 'story/story.json';
  final source =
      jsonDecode(File(input).readAsStringSync()) as Map<String, dynamic>;
  final output = const JsonEncoder.withIndent('  ')
          .convert(buildContract(source, sha(input))) +
      '\n';
  const path = 'docs/trilemma-contract.json';
  if (args.contains('--check')) {
    if (!File(path).existsSync() || File(path).readAsStringSync() != output) {
      stderr.writeln('TRILEMMA_CONTRACT_FAIL: regenerate $path');
      exit(1);
    }
    stdout.writeln('TRILEMMA_CONTRACT_OK: $path');
    return;
  }
  File(path).writeAsStringSync(output);
  stdout.writeln('TRILEMMA_CONTRACT_WRITTEN: $path');
}
