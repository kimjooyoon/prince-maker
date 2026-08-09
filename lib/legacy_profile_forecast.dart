/// Pure projection for the authored target route shown on a next-run card.
///
/// The target is read from SSOT rather than inferred from policy output, so the
/// preview and the selected GameSession share one explicit contract.
Map<String, dynamic>? _byId(List? values, String id) {
  for (final value in values ?? const []) {
    if (value is Map && '${value['id']}' == id) {
      return value.cast<String, dynamic>();
    }
  }
  return null;
}

Map<String, dynamic> legacyProfileForecast(
    Map<String, dynamic> story, Map<String, dynamic> profile) {
  final targetId = '${profile['targetEndingId'] ?? ''}',
      ending = _byId(story['endings'] as List?, targetId),
      companionId = '${profile['companionId'] ?? ''}',
      companion = _byId(story['companions'] as List?, companionId),
      verified = targetId.isNotEmpty && ending != null && companion != null;
  return {
    'verified': verified,
    'profileId': '${profile['id'] ?? ''}',
    'targetEndingId': targetId,
    'targetEndingTitle': ending?['title'] ?? targetId,
    'targetEndingTitleKey': ending?['titleKey'] ?? '',
    'companionId': companionId,
    'companionName': companion?['name'] ?? companionId,
    'companionNameKey': companion?['nameKey'] ?? '',
  };
}
