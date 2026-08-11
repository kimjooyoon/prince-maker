import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/main.dart';

Future<Map<String, dynamic>> loadStory() async => decodeJsonl(utf8
    .decode((await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));

Future<Map<String, Map<String, String>>> loadLocales() async => {
      for (final locale in ['ko', 'en'])
        locale: decodeJsonlCatalog(utf8.decode(
            (await rootBundle.load('story/locales/$locale.jsonl'))
                .buffer
                .asUint8List()))
    };

void main() {
  testWidgets('home and personality controls expose localized semantic labels',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester
        .pumpWidget(Game(await loadStory(), locales: await loadLocales()));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('언어 바꾸기'), findsOneWidget);
    expect(find.bySemanticsLabel('성격 상반신 열기'), findsOneWidget);
    expect(find.bySemanticsLabel('하루 보내기'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('성격 상반신 열기'));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('성격 선택')), findsNWidgets(3));
    expect(find.bySemanticsLabel('홈으로 돌아가기'), findsOneWidget);
    semantics.dispose();
  });
}
