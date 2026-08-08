/// Deterministic quality score contract shared by the generator and verifier.
///
/// The score is an evidence index, not a subjective review grade. Every
/// component is normalized to [0, 1], capped at 1, and combined by the fixed
/// weights below. Missing components are an error in the verifier.
class QualityScoreComponent {
  const QualityScoreComponent({
    required this.id,
    required this.weight,
    required this.target,
    required this.formula,
    required this.evidence,
  });

  final String id;
  final double weight;
  final num target;
  final String formula;
  final String evidence;

  Map<String, dynamic> toJson() => {
        'id': id,
        'weight': weight,
        'target': target,
        'formula': formula,
        'evidence': evidence,
      };
}

const qualityScoreSchema = 'lumen-quality-score-v1';
const qualityScoreTarget = 0.99;

const qualityScoreComponents = <QualityScoreComponent>[
  QualityScoreComponent(
    id: 'scenario-contract',
    weight: 0.12,
    target: 8,
    formula: 'valid scenario dimensions / 8',
    evidence: 'tool/verify_game.dart#scenario-contract',
  ),
  QualityScoreComponent(
    id: 'choice-impact',
    weight: 0.12,
    target: 1.0,
    formula: 'effectful authored choices / authored choices',
    evidence: 'build/gameplay-fun-verdict.json#metrics.choiceImpactRate',
  ),
  QualityScoreComponent(
    id: 'event-divergence',
    weight: 0.10,
    target: 1.0,
    formula: 'events with distinct authored effects / events',
    evidence: 'build/gameplay-fun-verdict.json#metrics.eventDivergenceRate',
  ),
  QualityScoreComponent(
    id: 'multi-axis-choice',
    weight: 0.10,
    target: 0.9,
    formula: 'choices changing at least two numeric axes / choices',
    evidence: 'build/gameplay-fun-verdict.json#metrics.multiAxisImpactRate',
  ),
  QualityScoreComponent(
    id: 'gated-choice',
    weight: 0.08,
    target: 20,
    formula: 'min(gated authored choices / 20, 1)',
    evidence: 'build/gameplay-fun-verdict.json#metrics.gatedChoices',
  ),
  QualityScoreComponent(
    id: 'chapter-event-golden',
    weight: 0.10,
    target: 16,
    formula: 'chapter event Goldens / 16',
    evidence: 'test/goldens/chapter-*.png',
  ),
  QualityScoreComponent(
    id: 'chapter-closure-golden',
    weight: 0.10,
    target: 16,
    formula: 'chapter closure Goldens / 16',
    evidence: 'test/goldens/chapter-closure-*.png',
  ),
  QualityScoreComponent(
    id: 'locale-coverage',
    weight: 0.08,
    target: 505,
    formula: 'minimum locale catalog keys / 505',
    evidence: 'story/locales/{ko,en}.jsonl#catalog',
  ),
  QualityScoreComponent(
    id: 'replay-determinism',
    weight: 0.10,
    target: 1.0,
    formula: 'benchmark checksum == replayChecksum and approved',
    evidence: 'build/benchmark-verdict.json#checksumReplayMustMatch',
  ),
  QualityScoreComponent(
    id: 'runtime-proof',
    weight: 0.10,
    target: 1.0,
    formula: 'decision proof + gameplay proof + benchmark all approve',
    evidence: 'build/{decision-proof,gameplay-fun,benchmark}-verdict.json',
  ),
];

Map<String, dynamic> qualityScoreModel() => {
      'schema': qualityScoreSchema,
      'targetScore': qualityScoreTarget,
      'unit': 'fraction',
      'formula': 'sum(component.score × component.weight)',
      'normalization':
          'each component is capped to [0, 1]; missing evidence is 0 and fails closed',
      'components': [
        for (final component in qualityScoreComponents) component.toJson()
      ],
    };

double weightedQualityScore(Map<String, double> scores) {
  final expected = qualityScoreComponents.map((component) => component.id);
  if (!scores.keys.toSet().containsAll(expected) ||
      scores.keys.length != expected.length) {
    throw ArgumentError('quality score components are incomplete');
  }
  final total = qualityScoreComponents.fold<double>(
      0, (sum, component) => sum + scores[component.id]! * component.weight);
  return double.parse(total.toStringAsFixed(6));
}

double cappedRatio(num actual, num target) {
  if (target <= 0) return 0;
  final ratio = actual / target;
  return ratio.clamp(0, 1).toDouble();
}
