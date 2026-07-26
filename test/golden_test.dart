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
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
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
    expect(find.byKey(const ValueKey('1-1-1-0')), findsOneWidget);
  });
  testWidgets('twelve-week loop resolves to an ending', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','personalities':[
      {'name':'고요한 관찰자','voice':'신중','line':'별을 볼래.'},{'name':'다정한 연결자','voice':'다정','line':'함께 보자.'},{'name':'용감한 개척자','voice':'용감','line':'가 보자!'}
    ]}));
    await tester.pumpAndSettle();
    for (var i=0; i<11; i++) { await tester.tapAt(const Offset(200, 550)); await tester.pump(); }
    expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/ending.png'));
  });
  testWidgets('authored event branches and returns to the loop', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','events':[
      {'week':4,'title':'사건','body':'선택','choices':[{'label':'공감','stat':'공감','delta':2,'coins':0},{'label':'지혜','stat':'지혜','delta':2,'coins':0}]}
    ]}));
    await tester.pumpAndSettle();
    for (var i=0; i<3; i++) { await tester.tapAt(const Offset(200, 550)); await tester.pump(); }
    expect(find.byKey(const ValueKey('3-4-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(120, 350));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-4-0-0')), findsOneWidget);
  });
  testWidgets('home exposes the save archive', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아'}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(300, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('4-1-0-0')), findsOneWidget);
  });
}
