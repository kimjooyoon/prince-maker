import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/activity_journal_painter.dart';

void main() {
  test('activity journal opens only recorded reflection pages', () {
    const scenes = [
      {'id': 'mist'},
      {'id': 'late'},
    ];
    final entries = activityJournalEntries(
        scenes, const ['activity-scene:mist', 'activity:지혜+3']);
    expect(entries.map((entry) => entry['open']), [true, false]);
    expect(activityJournalEntries(scenes, const []), [
      {'id': 'mist', 'open': false},
      {'id': 'late', 'open': false},
    ]);
  });
}
