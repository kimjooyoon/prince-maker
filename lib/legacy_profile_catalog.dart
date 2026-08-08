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
