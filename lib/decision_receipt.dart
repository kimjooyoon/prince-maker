/// Immutable, render-ready projection of a system decision trace.
class DecisionReceipt {
  const DecisionReceipt({
    required this.approved,
    required this.owner,
    required this.kind,
    required this.subject,
    required this.week,
    required this.rule,
    required this.contract,
    required this.decisionHash,
    this.preconditionHash = 'legacy',
    this.parentDecisionHash = 'genesis',
  });

  final bool approved;
  final String owner, kind, subject, rule, contract, decisionHash;
  final String preconditionHash, parentDecisionHash;
  final int week;

  static DecisionReceipt? parse(String trace) {
    if (!trace.startsWith('approval:')) return null;
    final fields = <String, String>{};
    for (final part in trace.split('|')) {
      final separator = part.indexOf(':');
      if (separator > 0) {
        fields[part.substring(0, separator)] = part.substring(separator + 1);
      }
    }
    final week = int.tryParse(fields['week'] ?? '');
    final approval = fields['approval'];
    if (week == null ||
        (approval != 'approved' && approval != 'rejected') ||
        fields['kind'] == null ||
        fields['decisionHash'] == null) {
      return null;
    }
    return DecisionReceipt(
      approved: approval == 'approved',
      owner: fields['owner'] ?? 'Lumen Ledger System',
      kind: fields['kind']!,
      subject: fields['subject'] ?? '',
      week: week,
      rule: fields['rule'] ?? '',
      contract: fields['contract'] ?? '',
      decisionHash: fields['decisionHash']!,
      preconditionHash: fields['preconditionHash'] ?? 'legacy',
      parentDecisionHash: fields['parentDecisionHash'] ?? 'genesis',
    );
  }

  String get shortHash =>
      decisionHash.length > 8 ? decisionHash.substring(0, 8) : decisionHash;
  String get shortPreconditionHash => preconditionHash.length > 8
      ? preconditionHash.substring(0, 8)
      : preconditionHash;
}

List<DecisionReceipt> recentDecisionReceipts(Iterable<String> trace) => trace
    .map(DecisionReceipt.parse)
    .whereType<DecisionReceipt>()
    .toList()
    .reversed
    .take(3)
    .toList();
