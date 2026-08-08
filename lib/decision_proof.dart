/// Deterministic proof attached to every system-owned game decision.
class SystemDecisionReceipt {
  const SystemDecisionReceipt(
      this.approved,
      this.kind,
      this.subject,
      this.week,
      this.rule,
      this.contract,
      this.preconditionHash,
      this.parentDecisionHash,
      this.decisionHash,
      this.owner);

  final bool approved;
  final String kind, subject, rule, contract;
  final String preconditionHash, parentDecisionHash, decisionHash, owner;
  final int week;

  String get trace =>
      'approval:${approved ? 'approved' : 'rejected'}|owner:$owner|kind:$kind|subject:$subject|week:$week|rule:$rule|contract:$contract|preconditionHash:$preconditionHash|parentDecisionHash:$parentDecisionHash|decisionHash:$decisionHash';
}

/// Approval is a pure function of SSOT contract, state preconditions and chain.
class SystemDecisionPolicy {
  static SystemDecisionReceipt evaluate({
    required String kind,
    required String subject,
    required int week,
    required int endingWeek,
    required bool conditions,
    required String owner,
    required String contract,
    String preconditions = '',
    String parentDecisionHash = 'genesis',
  }) {
    final inWindow = week < endingWeek;
    final approved = inWindow && conditions;
    final rule = !inWindow
        ? 'terminal-window'
        : conditions
            ? 'input-contract'
            : 'input-contract-rejected';
    final preconditionHash = digest(preconditions);
    final decisionHash = digest(
        '$contract|$kind|$subject|$week|${approved ? 'approve' : 'reject'}|$preconditionHash|$parentDecisionHash');
    return SystemDecisionReceipt(approved, kind, subject, week, rule, contract,
        preconditionHash, parentDecisionHash, decisionHash, owner);
  }

  static String parentHash(Iterable<String> trace) {
    for (final entry in trace.toList().reversed) {
      for (final field in entry.split('|')) {
        if (field.startsWith('approval:')) {
          final hash = entry
              .split('|')
              .where((part) => part.startsWith('decisionHash:'))
              .map((part) => part.substring('decisionHash:'.length))
              .firstOrNull;
          if (hash != null && hash.isNotEmpty) return hash;
        }
      }
    }
    return 'genesis';
  }

  static String digest(String payload) {
    var hash = 2166136261;
    for (final unit in payload.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
