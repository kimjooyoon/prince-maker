import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:prince_maker/main.dart';

void main() {
  testWidgets('home screen is stable', (tester) async {
    await tester.pumpWidget(
      const Game({
        'title': '프린스 메이커',
        'setting': '바람과 별빛이 공존하는 작은 영지 루멘',
        'hero': '노아',
      }),
    );
    await tester.pumpAndSettle();
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/home.png'));
  });
  testWidgets('activity advances the authored loop', (tester) async {
    await tester.pumpWidget(
      const Game({'title': '프린스 메이커', 'setting': '루멘', 'hero': '노아'}),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(620, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('week-2')), findsOneWidget);
  });
}
