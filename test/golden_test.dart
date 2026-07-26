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
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','personalities':[
      {'name':'고요한 관찰자','voice':'신중','line':'별을 볼래.'},{'name':'다정한 연결자','voice':'다정','line':'함께 보자.'},{'name':'용감한 개척자','voice':'용감','line':'가 보자!'}
    ]}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(300, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0')), findsOneWidget);
  });
  testWidgets('illustration page switches personality dialogue', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','personalities':[
      {'name':'고요한 관찰자','voice':'신중','line':'별을 볼래.'},{'name':'다정한 연결자','voice':'다정','line':'함께 보자.'},{'name':'용감한 개척자','voice':'용감','line':'가 보자!'}
    ]}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(620, 550));
    await tester.pump();
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/illustration.png'));
    await tester.tapAt(const Offset(300, 230));
    await tester.pump();
    expect(find.byKey(const ValueKey('1-1-1')), findsOneWidget);
  });
  testWidgets('twelve-week loop resolves to an ending', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','personalities':[
      {'name':'고요한 관찰자','voice':'신중','line':'별을 볼래.'},{'name':'다정한 연결자','voice':'다정','line':'함께 보자.'},{'name':'용감한 개척자','voice':'용감','line':'가 보자!'}
    ]}));
    await tester.pumpAndSettle();
    for (var i=0; i<12; i++) { await tester.tapAt(const Offset(300, 550)); await tester.pump(); }
    expect(find.byKey(const ValueKey('2-12-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/ending.png'));
  });
}
