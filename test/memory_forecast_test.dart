import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/i18n.dart';
import 'package:prince_maker/memory_forecast.dart';

void main() {
  test('choice maps to an authored fate thread', () {
    final threads = <Map<String, dynamic>>[
      {
        'flag': 'first-ledger',
        'titleRef': 'event.firstLedger.title',
        'detailKey': 'fate.ledger-echo.detail',
      },
    ];
    final first = forecastChoiceMemory({'setsFlag': 'first-ledger'}, threads);
    final replay = forecastChoiceMemory({'setsFlag': 'first-ledger'}, threads);
    expect(first?.toMap(), equals(replay?.toMap()));
    expect(first?.titleKey, 'event.firstLedger.title');
    expect(first?.detailKey, 'fate.ledger-echo.detail');
    expect(forecastChoiceMemory({'label': 'no memory'}, threads), isNull);
  });

  test('memory impact copy localizes the authored title', () {
    setActiveLocale(
      'en',
      const LocaleCatalog({
        'en': {
          'ui.event.memoryImpact': 'Memory impact · {title}: {detail}',
          'event.firstLedger.title': 'The First Ledger Night',
          'fate.ledger-echo.detail': 'The ledger choice returns as a rule.',
        },
      }),
    );
    expect(
      localizedChoiceMemoryImpact(
        {'setsFlag': 'first-ledger'},
        const [
          {
            'flag': 'first-ledger',
            'titleRef': 'event.firstLedger.title',
            'detailKey': 'fate.ledger-echo.detail',
          },
        ],
      ),
      'Memory impact · The First Ledger Night: The ledger choice returns as a rule.',
    );
  });
}
