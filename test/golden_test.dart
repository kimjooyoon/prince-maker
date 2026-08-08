import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prince_maker/main.dart';
import 'package:prince_maker/jsonl.dart';

Map<String, dynamic> lineageGoldenStory({
  required String id,
  required String companionId,
  required String companionName,
  required String routeTitle,
  required String epilogue,
}) =>
    {
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'endingWeek': 12,
      'personalities': [
        {'name': '고요한 관찰자', 'voice': '신중', 'line': '별을 볼래.'}
      ],
      'legacyProfiles': [
        {
          'id': id,
          'endingIds': [id],
          'stat': '지혜',
          'bonus': 0,
          'companionId': companionId
        }
      ],
      'companions': [
        {
          'id': companionId,
          'name': companionName,
          'routeTitle': routeTitle,
          'routeTitleKey': 'companion.$companionId.routeTitle',
          'bondThreshold': 0,
          'epilogue': epilogue,
          'epilogueKey': 'companion.$companionId.epilogue'
        }
      ],
      'endings': [
        {
          'id': id,
          'stat': '지혜',
          'min': 0,
          'title': '루멘의 별읽기꾼',
          'body': '노아는 밤하늘의 결을 읽는 사람이 되었다.'
        }
      ],
      'milestones': <Map<String, dynamic>>[],
    };

Future<void> reachGoldenEnding(WidgetTester tester, Map<String, dynamic> story,
    String profileId, String goldenName) async {
  await tester
      .pumpWidget(Game(story, legacyId: profileId, key: ValueKey(profileId)));
  await tester.pumpAndSettle();
  for (var i = 0; i < 11; i++) {
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
  }
  expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
  await expectLater(
      find.byType(Game), matchesGoldenFile('goldens/$goldenName.png'));
}

void main() {
  testWidgets('canonical event page is stable', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 3,
          'title': '비가 오던 밤',
          'body': '마을의 등불이 꺼졌다.',
          'choices': [
            {
              'label': '아이들과 등불을 나눈다',
              'stat': '공감',
              'delta': 2,
              'coins': -1,
              'bondId': 'bora',
              'bondDelta': 4,
              'requiresStat': '용기',
              'requiresMin': 8
            },
            {
              'label': '별을 읽어 길을 찾는다',
              'stat': '지혜',
              'delta': 2,
              'coins': 0,
              'bondId': 'lumi',
              'bondDelta': 4
            }
          ]
        }
      ],
      'milestones': [
        {
          'id': 'spring',
          'week': 3,
          'title': '봄의 별씨앗',
          'stat': '지혜',
          'min': 8,
          'coins': 3,
          'pass': '달성',
          'fail': '실패'
        }
      ]
    }));
    await tester.pumpAndSettle();
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1000)));
    await tester.pump();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-3-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/event.png'));
  });
  testWidgets('legacy collection seed unlocks a replay choice', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 2,
          'title': '새벽 우편함',
          'body': '기록을 남긴 사람은 오늘 다른 소식을 읽는다.',
          'choices': [
            {
              'label': '루미에게 별의 이름을 묻는다',
              'stat': '지혜',
              'delta': 2,
              'coins': 0,
              'bondId': 'lumi',
              'bondDelta': 2
            },
            {
              'label': '마을 게시판에 소식을 나눈다',
              'stat': '공감',
              'delta': 1,
              'coins': 1,
              'bondId': 'bora',
              'bondDelta': 2,
              'requiresFlag': 'legacy-star'
            }
          ]
        }
      ]
    }, legacySeed: true));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-2-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/legacy-gate.png'));
  });
  testWidgets('legacy lineage resonance is visible on the authored choice',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'legacyProfiles': [
        {'id': 'stargazer', 'stat': '지혜', 'bonus': 2}
      ],
      'events': [
        {
          'week': 2,
          'title': '계승의 우편함',
          'body': '이전 기록은 새로운 선택의 결을 남긴다.',
          'choices': [
            {
              'label': '기록을 조용히 읽는다',
              'stat': '지혜',
              'delta': 1,
              'coins': 0,
              'bondId': 'lumi',
              'bondDelta': 1
            },
            {
              'label': '별의 소식을 나눈다',
              'stat': '공감',
              'delta': 1,
              'coins': 1,
              'bondId': 'bora',
              'bondDelta': 1,
              'requiresFlag': 'legacy-star',
              'legacyBonuses': {
                'stargazer': {'stat': '지혜', 'delta': 1},
                'gardener': {'stat': '공감', 'delta': 1},
                'pathfinder': {'stat': '용기', 'delta': 1}
              }
            }
          ]
        }
      ]
    }, legacyId: 'stargazer'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('3-2-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/legacy-profile.png'));
  });
  testWidgets('outing choice shows time-budget tradeoff', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 5,
          'title': '달빛 시장 산책',
          'body': '은화를 써서 누구와 루멘 밖을 걸을까?',
          'choices': [
            {
              'label': '루미와 지도 찾기',
              'stat': '지혜',
              'delta': 1,
              'coins': -2,
              'bondId': 'lumi',
              'bondDelta': 3,
              'line': '다음 길의 단서를 찾자.'
            },
            {
              'label': '보라와 씨앗 장터',
              'stat': '공감',
              'delta': 1,
              'coins': -2,
              'bondId': 'bora',
              'bondDelta': 3,
              'line': '내일의 정원을 골라보자.'
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('3-5-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/outing.png'));
  });
  testWidgets('relationship gate is visible before bond is earned',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 11,
          'title': '바람 언덕의 약속',
          'body': '누구와 걸은 시간이 다음 계절의 방향이 될까?',
          'choices': [
            {
              'label': '타로와 이름 없는 길',
              'stat': '용기',
              'delta': 1,
              'coins': -2,
              'bondId': 'taro',
              'bondDelta': 3,
              'requiresBondId': 'taro',
              'requiresBondMin': 2
            },
            {
              'label': '루미와 표식 남기기',
              'stat': '지혜',
              'delta': 1,
              'coins': -2,
              'bondId': 'lumi',
              'bondDelta': 3
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('3-11-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/relationship-gate.png'));
  });
  testWidgets('memory gate is visible before a prior choice is made',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 10,
          'title': '축제 전야',
          'body': '지난 선택이 오늘의 무대를 여는가?',
          'choices': [
            {
              'label': '새로운 무대를 직접 세운다',
              'stat': '용기',
              'delta': 2,
              'coins': 0,
              'bondId': 'taro',
              'bondDelta': 4,
              'requiresFlag': 'windmill-repair',
              'requiresStat': '용기',
              'requiresMin': 12
            },
            {
              'label': '모두가 쉴 자리를 만든다',
              'stat': '공감',
              'delta': 1,
              'coins': 1,
              'bondId': 'bora',
              'bondDelta': 2
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    for (var i = 0; i < 9; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('3-10-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/memory-gate.png'));
  });
  testWidgets('event choice shows a separated result banner', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 2,
          'title': '첫 번째 편지',
          'body': '누구와 먼저 읽을까?',
          'choices': [
            {
              'label': '루미에게 묻기',
              'stat': '지혜',
              'delta': 1,
              'coins': 0,
              'bondId': 'lumi',
              'bondDelta': 2,
              'line': '이름을 부르면 가까워져.'
            },
            {
              'label': '마을에 나누기',
              'stat': '공감',
              'delta': 1,
              'coins': 1,
              'bondId': 'bora',
              'bondDelta': 2,
              'line': '좋은 소식은 오래 남아.'
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    await tester.tapAt(const Offset(200, 350));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/feedback.png'));
  });
  testWidgets('rival bond choice shows relationship opportunity cost',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 2,
          'title': '바람이 멎은 오후',
          'body': '누구와 손을 맞출까?',
          'choices': [
            {
              'label': '타로와 고치기',
              'stat': '용기',
              'delta': 2,
              'coins': 1,
              'bondId': 'taro',
              'bondDelta': 2,
              'rivalId': 'bora',
              'rivalDelta': -1,
              'line': '함께 고치면 다시 움직여.'
            },
            {
              'label': '보라와 타로의 말을 함께 듣기',
              'stat': '공감',
              'delta': 2,
              'coins': -1,
              'bondId': 'bora',
              'bondDelta': 1,
              'rivalId': 'taro',
              'rivalDelta': 1,
              'setsFlag': 'windmill-truce',
              'line': '서로의 바람을 들으면 다시 이어져.'
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    await tester.tapAt(const Offset(200, 350));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/relationship-tension.png'));
  });
  testWidgets('mediation choice shows reciprocal relationship recovery',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 2,
          'title': '바람이 멎은 오후',
          'body': '두 사람의 말이 엇갈렸다. 함께 들을 수 있을까?',
          'choices': [
            {
              'label': '타로의 방식으로 고친다',
              'stat': '용기',
              'delta': 2,
              'coins': 1,
              'bondId': 'taro',
              'bondDelta': 2,
              'rivalId': 'bora',
              'rivalDelta': -1,
              'line': '먼저 움직이면 길이 열린다.'
            },
            {
              'label': '보라와 타로의 말을 함께 듣는다',
              'stat': '공감',
              'delta': 1,
              'coins': -2,
              'bondId': 'bora',
              'bondDelta': 1,
              'rivalId': 'taro',
              'rivalDelta': 1,
              'setsFlag': 'windmill-truce',
              'line': '서로의 바람을 들으면 다시 이어진다.'
            }
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    await tester.tapAt(const Offset(500, 350));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/mediation.png'));
  });
  testWidgets('season goal is visible before the first choice', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'milestones': [
        {
          'id': 'spring',
          'week': 3,
          'title': '봄의 별씨앗',
          'stat': '지혜',
          'min': 8,
          'coins': 3,
          'pass': '달성',
          'fail': '실패'
        }
      ]
    }));
    await tester.pumpAndSettle();
    await tester
        .runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/milestone.png'));
  });
  testWidgets('home screen is stable', (tester) async {
    await tester.pumpWidget(
      const Game({
        'title': '프린스 메이커',
        'setting': '바람과 별빛이 공존하는 작은 영지 루멘',
        'hero': '노아',
        'personalities': [
          {'name': '고요한 관찰자', 'focusStat': '지혜', 'focusBonus': 1},
          {'name': '다정한 연결자', 'focusStat': '공감', 'focusBonus': 1},
          {'name': '용감한 개척자', 'focusStat': '용기', 'focusBonus': 1},
        ],
      }),
    );
    await tester.pumpAndSettle();
    await tester
        .runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(find.byType(Game), matchesGoldenFile('goldens/home.png'));
  });
  testWidgets('activity advances the authored loop', (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'personalities': [
        {'name': '고요한 관찰자', 'voice': '신중', 'line': '별을 볼래.'},
        {'name': '다정한 연결자', 'voice': '다정', 'line': '함께 보자.'},
        {'name': '용감한 개척자', 'voice': '용감', 'line': '가 보자!'}
      ]
    }));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-2-0-0')), findsOneWidget);
  });
  testWidgets('illustration page switches personality dialogue',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'personalities': [
        {'name': '고요한 관찰자', 'voice': '신중', 'line': '별을 볼래.'},
        {'name': '다정한 연결자', 'voice': '다정', 'line': '함께 보자.'},
        {'name': '용감한 개척자', 'voice': '용감', 'line': '가 보자!'}
      ]
    }));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(500, 550));
    await tester.pump();
    await tester
        .runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/illustration.png'));
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
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'milestones': [
        {
          'id': 'spring',
          'week': 3,
          'title': '봄의 별씨앗',
          'stat': '지혜',
          'min': 99,
          'coins': 3,
          'pass': '달성',
          'fail': '다음 회차에 다시 시도'
        }
      ],
      'personalities': [
        {'name': '고요한 관찰자', 'voice': '신중', 'line': '별을 볼래.'},
        {'name': '다정한 연결자', 'voice': '다정', 'line': '함께 보자.'},
        {'name': '용감한 개척자', 'voice': '용감', 'line': '가 보자!'}
      ]
    }));
    await tester.pumpAndSettle();
    for (var i = 0; i < 11; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
      if (find.byKey(const ValueKey('6-3-0-0')).evaluate().isNotEmpty) {
        await tester.tapAt(const Offset(500, 540));
        await tester.pump();
      }
    }
    expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/ending.png'));
    await tester.tapAt(const Offset(500, 540));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/restart.png'));
  });
  testWidgets('lineage companion epilogue is visible in the ending Canvas',
      (tester) async {
    await tester.pumpWidget(Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'endingWeek': 12,
      'personalities': [
        {'name': '고요한 관찰자', 'voice': '신중', 'line': '별을 볼래.'}
      ],
      'legacyProfiles': [
        {
          'id': 'stargazer',
          'endingIds': ['stargazer'],
          'stat': '지혜',
          'bonus': 0,
          'companionId': 'lumi'
        }
      ],
      'companions': [
        {
          'id': 'lumi',
          'name': '루미',
          'routeTitle': '별자리 동행',
          'routeTitleKey': 'companion.lumi.routeTitle',
          'bondThreshold': 0,
          'epilogue': '루미는 노아의 기록 첫 장에 작은 별표를 남겼다.',
          'epilogueKey': 'companion.lumi.epilogue'
        }
      ],
      'endings': [
        {
          'id': 'stargazer',
          'stat': '지혜',
          'min': 0,
          'title': '루멘의 별읽기꾼',
          'body': '노아는 밤하늘의 결을 읽는 사람이 되었다.'
        }
      ],
      'milestones': <Map<String, dynamic>>[],
    }, legacyId: 'stargazer'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 11; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/companion-epilogue.png'));
  });
  testWidgets('ending exposes deterministic next-run legacy picker',
      (tester) async {
    final locales = <String, Map<String, String>>{};
    for (final locale in ['ko', 'en']) {
      locales[locale] = decodeJsonlCatalog(utf8.decode(
          (await rootBundle.load('story/locales/$locale.jsonl'))
              .buffer
              .asUint8List()));
    }
    final story = lineageGoldenStory(
      id: 'stargazer',
      companionId: 'lumi',
      companionName: '루미',
      routeTitle: '별자리 동행',
      epilogue: '루미는 노아의 기록 첫 장에 작은 별표를 남겼다.',
    )
      ..['legacySelection'] = {
        'schema': 'lumen-legacy-selection-v1',
      }
      ..['legacyProfiles'] = [
        {
          'id': 'stargazer',
          'endingIds': ['stargazer'],
          'stat': '지혜',
          'bonus': 2,
          'companionId': 'lumi',
          'title': '별읽기의 유산',
          'titleKey': 'legacy.stargazer.title',
        },
        {
          'id': 'gardener',
          'endingIds': ['stargazer'],
          'stat': '공감',
          'bonus': 2,
          'companionId': 'lumi',
          'title': '정원의 유산',
          'titleKey': 'legacy.gardener.title',
        },
        {
          'id': 'pathfinder',
          'endingIds': ['stargazer'],
          'stat': '용기',
          'bonus': 2,
          'companionId': 'lumi',
          'title': '길잡이의 유산',
          'titleKey': 'legacy.pathfinder.title',
        },
      ];
    await tester.pumpWidget(Game(story, locales: locales));
    await tester.pumpAndSettle();
    for (var i = 0; i < 11; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('2-12-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/legacy-picker.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    expect(find.byKey(const ValueKey('2-12-0-0-en')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/legacy-picker-en.png'));
    await tester.tapAt(const Offset(650, 50));
    await tester.pump();
    await tester.tapAt(const Offset(300, 525));
    await tester.pump();
    await expectLater(find.byType(Game),
        matchesGoldenFile('goldens/legacy-picker-selected.png'));
    await tester.tapAt(const Offset(500, 480));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/legacy-home.png'));
  });
  testWidgets('all lineage companion epilogues have distinct Canvas evidence',
      (tester) async {
    const routes = [
      {
        'id': 'stargazer',
        'companionId': 'lumi',
        'name': '루미',
        'title': '별자리 동행',
        'epilogue': '루미는 노아의 기록 첫 장에 작은 별표를 남겼다.'
      },
      {
        'id': 'gardener',
        'companionId': 'bora',
        'name': '보라',
        'title': '온실의 약속',
        'epilogue': '보라는 노아와 계절마다 새로운 씨앗을 심었다.'
      },
      {
        'id': 'pathfinder',
        'companionId': 'taro',
        'name': '타로',
        'title': '바람길 동행',
        'epilogue': '타로는 노아를 아직 지도에 없는 길로 데려갔다.'
      }
    ];
    for (final route in routes) {
      await reachGoldenEnding(
          tester,
          lineageGoldenStory(
            id: route['id']!,
            companionId: route['companionId']!,
            companionName: route['name']!,
            routeTitle: route['title']!,
            epilogue: route['epilogue']!,
          ),
          route['id']!,
          'companion-${route['id']}');
    }
  });
  testWidgets('authored event branches and returns to the loop',
      (tester) async {
    await tester.pumpWidget(const Game({
      'title': '프린스 메이커',
      'setting': '루멘',
      'hero': '노아',
      'events': [
        {
          'week': 4,
          'title': '사건',
          'body': '선택',
          'choices': [
            {'label': '공감', 'stat': '공감', 'delta': 2, 'coins': 0},
            {'label': '지혜', 'stat': '지혜', 'delta': 2, 'coins': 0}
          ]
        }
      ]
    }));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    expect(find.byKey(const ValueKey('3-4-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(120, 350));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-4-0-0')), findsOneWidget);
  });
  testWidgets('home exposes the save archive', (tester) async {
    await tester.pumpWidget(
        const Game({'title': '프린스 메이커', 'setting': '루멘', 'hero': '노아'}));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(300, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('4-1-0-0')), findsOneWidget);
    await tester.tapAt(const Offset(80, 570));
    await tester.pump();
    expect(find.byKey(const ValueKey('0-1-0-0')), findsOneWidget);
  });
  testWidgets('save archive exposes recent replay evidence', (tester) async {
    await tester.pumpWidget(
        const Game({'title': '프린스 메이커', 'setting': '루멘', 'hero': '노아'}));
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
  testWidgets('ending collection survives a restart', (tester) async {
    await tester.pumpWidget(
        const Game({'title': '프린스 메이커', 'setting': '루멘', 'hero': '노아'}));
    await tester.pumpAndSettle();
    for (var i = 0; i < 11; i++) {
      await tester.tapAt(const Offset(200, 550));
      await tester.pump();
    }
    await tester.tapAt(const Offset(500, 540));
    await tester.pump();
    await tester.tapAt(const Offset(300, 550));
    await tester.pump();
    expect(find.byKey(const ValueKey('4-1-0-0')), findsOneWidget);
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/collection.png'));
  });
  testWidgets('canonical SSOT renders a stable Canvas home', (tester) async {
    final source = decodeJsonl(utf8.decode(
            (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()))
        as Map;
    await tester.pumpWidget(Game(Map<String, dynamic>.from(source)));
    await tester.pump(const Duration(milliseconds: 100));
    await tester
        .runAsync(() async => Future<void>.delayed(const Duration(seconds: 1)));
    await tester.pump();
    await expectLater(
        find.byType(Game), matchesGoldenFile('goldens/canonical-home.png'));
  });
}
