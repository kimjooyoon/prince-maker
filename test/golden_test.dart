import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:prince_maker/main.dart';

void main() {
  testWidgets('canonical event page is stable', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','events':[
      {'week':3,'title':'비가 오던 밤','body':'마을의 등불이 꺼졌다.','choices':[{'label':'아이들과 등불을 나눈다','stat':'공감','delta':2,'coins':-1,'bondId':'bora','bondDelta':4,'requiresStat':'용기','requiresMin':8},{'label':'별을 읽어 길을 찾는다','stat':'지혜','delta':2,'coins':0,'bondId':'lumi','bondDelta':4}]}
    ],'milestones':[
      {'id':'spring','week':3,'title':'봄의 별씨앗','stat':'지혜','min':8,'coins':3,'pass':'달성','fail':'실패'}
    ]}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-3-0-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/event.png'));
  });
  testWidgets('season goal is visible before the first choice', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','milestones':[
      {'id':'spring','week':3,'title':'봄의 별씨앗','stat':'지혜','min':8,'coins':3,'pass':'달성','fail':'실패'}
    ]}));
    await tester.pumpAndSettle();
    await tester.runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/milestone.png'));
  });
  testWidgets('home screen is stable', (tester) async {
    await tester.pumpWidget(
      const Game({
        'title': '프린스 메이커',
        'setting': '바람과 별빛이 공존하는 작은 영지 루멘',
        'hero': '노아',
        'personalities': [
          {'name':'고요한 관찰자','focusStat':'지혜','focusBonus':1},
          {'name':'다정한 연결자','focusStat':'공감','focusBonus':1},
          {'name':'용감한 개척자','focusStat':'용기','focusBonus':1},
        ],
      }),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
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
    await tester.tapAt(const Offset(500, 550));
    await tester.pump();
    await tester.runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/illustration.png'));
    await tester.tapAt(const Offset(300, 580));
    await tester.pump();
    expect(find.byKey(const ValueKey('1-1-1-0')), findsOneWidget);
    await tester.tapAt(const Offset(300, 230));
    await tester.pump();
    expect(find.byKey(const ValueKey('1-1-1-0')), findsOneWidget);
    await tester.tapAt(const Offset(750, 580));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-1-0')), findsOneWidget);
  });
  testWidgets('twelve-week loop resolves to an ending', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아','personalities':[
      {'name':'고요한 관찰자','voice':'신중','line':'별을 볼래.'},{'name':'다정한 연결자','voice':'다정','line':'함께 보자.'},{'name':'용감한 개척자','voice':'용감','line':'가 보자!'}
    ]}));
    await tester.pumpAndSettle();
    for (var i=0; i<11; i++) { await tester.tapAt(const Offset(200, 550)); await tester.pump(); }
    expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/ending.png'));
    await tester.tapAt(const Offset(500, 440));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/restart.png'));
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
    await tester.tapAt(const Offset(80, 570));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
  });
  testWidgets('save archive exposes recent replay evidence', (tester) async {
    await tester.pumpWidget(const Game({'title':'프린스 메이커','setting':'루멘','hero':'노아'}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 300));
    await tester.pump();
    await tester.tapAt(const Offset(650, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(300, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('4-2-0-0')), findsOneWidget);
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/save.png'));
  });
}
