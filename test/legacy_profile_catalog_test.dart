import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/legacy_profile_catalog.dart';

void main() {
  test('collection unlocks profiles in stable order', () {
    const story = {
      'legacyProfiles': [
        {
          'id': 'zeta',
          'endingIds': ['zeta-ending'],
        },
        {
          'id': 'alpha',
          'endingIds': ['alpha-ending'],
        },
        {
          'id': 'hidden',
          'endingIds': ['missing-ending'],
        },
      ],
    };
    final collection = [
      {'id': 'zeta-ending'},
      {'id': 'alpha-ending'},
    ];
    final profiles = unlockedLegacyProfiles(story, collection);
    expect(profiles.map((profile) => profile['id']), ['alpha', 'zeta']);
    expect(defaultLegacyProfileId(story, collection), 'alpha');
    expect(defaultLegacyProfileId(story, const []), isNull);
  });

  test('duplicate collection records cannot duplicate a profile card', () {
    const story = {
      'legacyProfiles': [
        {
          'id': 'stargazer',
          'endingIds': ['stargazer']
        },
      ],
    };
    final profiles = unlockedLegacyProfiles(story, [
      {'id': 'stargazer'},
      {'id': 'stargazer'},
    ]);
    expect(profiles, hasLength(1));
  });

  test('legacy policy forecast projects only the verified SSOT contract', () {
    final forecast = legacyPolicyForecast(const {
      'lineageDistribution': {
        'schema': 'lumen-lineage-distribution-v1',
        'policyCount': 5,
        'observedDistinctEndingsPerProfile': 4,
        'observedDistinctSignaturesPerProfile': 4,
        'distinctProfileFingerprints': 3,
      }
    });
    expect(forecast, {
      'verified': true,
      'policies': 5,
      'endings': 4,
      'signatures': 4,
      'fingerprints': 3,
    });
    expect(legacyPolicyForecast(const {})['verified'], false);
  });
}
