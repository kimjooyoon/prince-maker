/// Pure projection for the next-run inheritance selector.
///
/// Collection records are the only unlock input; ordering is authored by the
/// stable profile id so the selector never depends on storage insertion order.
List<Map<String, dynamic>> unlockedLegacyProfiles(
    Map<String, dynamic> story, List<Map<String, dynamic>> collectionEntries) {
  final profiles = (story['legacyProfiles'] as List? ?? const [])
      .whereType<Map>()
      .map((profile) => profile.cast<String, dynamic>())
      .where((profile) {
    final endingIds =
        (profile['endingIds'] as List? ?? const []).map((id) => '$id').toSet();
    return collectionEntries
        .any((entry) => endingIds.contains('${entry['id']}'));
  }).toList()
    ..sort((a, b) => '${a['id']}'.compareTo('${b['id']}'));
  return profiles;
}

String? defaultLegacyProfileId(
    Map<String, dynamic> story, List<Map<String, dynamic>> collectionEntries) {
  final profiles = unlockedLegacyProfiles(story, collectionEntries);
  return profiles.isEmpty ? null : '${profiles.first['id']}';
}

/// Player-facing projection of the benchmark-verified replay space.
Map<String, dynamic> legacyPolicyForecast(Map<String, dynamic> story) {
  final contract =
      (story['lineageDistribution'] as Map? ?? {}).cast<String, dynamic>();
  final policies = contract['policyCount'] as int? ?? 0,
      endings = contract['observedDistinctEndingsPerProfile'] as int? ?? 0,
      signatures =
          contract['observedDistinctSignaturesPerProfile'] as int? ?? 0,
      fingerprints = contract['distinctProfileFingerprints'] as int? ?? 0;
  return {
    'verified': contract['schema'] == 'lumen-lineage-distribution-v1' &&
        policies > 0 &&
        endings > 0 &&
        signatures > 0 &&
        fingerprints > 0,
    'policies': policies,
    'endings': endings,
    'signatures': signatures,
    'fingerprints': fingerprints,
  };
}
