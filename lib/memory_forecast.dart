class MemoryForecast {
  const MemoryForecast({
    required this.flag,
    required this.fallbackTitle,
    this.titleKey,
    this.detailKey,
  });

  final String flag;
  final String fallbackTitle;
  final String? titleKey;
  final String? detailKey;

  Map<String, dynamic> toMap() => {
        'flag': flag,
        'fallbackTitle': fallbackTitle,
        'titleKey': titleKey,
        'detailKey': detailKey,
      };
}

MemoryForecast? forecastChoiceMemory(
    Map<String, dynamic> choice, List<Map<String, dynamic>> fateThreads) {
  final flag = choice['setsFlag'];
  if (flag is! String || flag.isEmpty) return null;
  for (final thread in fateThreads) {
    if (thread['flag'] != flag) continue;
    final titleKey = thread['titleRef'];
    final detailKey = thread['detailKey'];
    return MemoryForecast(
      flag: flag,
      fallbackTitle: '${thread['title'] ?? flag}',
      titleKey: titleKey is String ? titleKey : null,
      detailKey: detailKey is String ? detailKey : null,
    );
  }
  return MemoryForecast(flag: flag, fallbackTitle: flag);
}
