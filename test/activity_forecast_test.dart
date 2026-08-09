import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/activity_catalog.dart';
import 'package:prince_maker/activity_forecast.dart';
import 'package:prince_maker/i18n.dart';

void main() {
  test('fatigue and talent forecast is deterministic', () {
    final activity = defaultActivities.first,
        events = [
          {'week': 2, 'titleKey': 'event.mail.title'}
        ],
        first = forecastActivity(activity,
            week: 1,
            fatigue: 8,
            coins: 12,
            focusStat: '지혜',
            focusBonus: 1,
            events: events),
        replay = forecastActivity(activity,
            week: 1,
            fatigue: 8,
            coins: 12,
            focusStat: '지혜',
            focusBonus: 1,
            events: events);
    expect(first.toMap(), equals(replay.toMap()));
    expect(first.growth, 3); // (3 + talent 1) - fatigue guard 1
    expect(first.fatigueAfter, 9);
    expect(first.nextEventKey, 'event.mail.title');
  });

  test('forecast exposes a milestone only when no event owns the week', () {
    final forecast = forecastActivity(defaultActivities[3],
        week: 2,
        fatigue: 4,
        coins: 12,
        milestones: [
          {'id': 'spring', 'week': 3, 'titleKey': 'milestone.spring.title'}
        ]);
    expect(forecast.nextEventKey, isNull);
    expect(forecast.nextMilestoneId, 'spring');
    expect(forecast.nextMilestoneKey, 'milestone.spring.title');
    expect(forecast.fatigueAfter, 2);
  });

  test('activity horizon prioritizes the next authored event', () {
    setActiveLocale('ko', const LocaleCatalog({}));
    final forecast = forecastActivity(defaultActivities.first,
        week: 1,
        fatigue: 0,
        coins: 12,
        events: [
          {'week': 2, 'titleKey': 'event.mail.title'}
        ]);
    expect(localizedActivityHorizon(forecast), 'Next event · event.mail.title');
  });
}
