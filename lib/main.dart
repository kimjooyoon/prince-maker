import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';
import 'canvas_surface.dart';
import 'canvas_scene_fingerprint.dart';
import 'activity_catalog.dart';
import 'feedback_banner.dart';
import 'i18n.dart';
import 'decision_receipt.dart';
import 'save_state.dart';
import 'save_adapter.dart';
import 'collection_adapter.dart';
import 'collection_platform.dart';
import 'game_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = jsonDecode(await rootBundle.loadString('story/story.json'));
  final locales = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    final raw =
        jsonDecode(await rootBundle.loadString('story/locales/$locale.json'))
            as Map;
    locales[locale] = raw.map((key, value) => MapEntry('$key', '$value'));
  }
  runApp(Game(s, locales: locales));
}

class Game extends StatefulWidget {
  const Game(this.story,
      {this.locales = const {},
      this.legacySeed = false,
      this.legacyId,
      this.initialSnapshot,
      super.key});
  final Map<String, dynamic> story;
  final Map<String, Map<String, String>> locales;
  final bool legacySeed;
  final String? legacyId;
  final GameSnapshot? initialSnapshot;
  @override
  State<Game> createState() => _Game();
}

class _Game extends State<Game> {
  int week = 1,
      coins = 12,
      fatigue = 0,
      selected = 0,
      page = 0,
      persona = 0,
      eventIndex = 0;
  String locale = 'ko';
  bool finished = false;
  final history = <String>[];
  final stats = {'지혜': 4, '공감': 5, '용기': 3},
      bonds = {'lumi': 0, 'bora': 0, 'taro': 0};
  final milestones = <String, bool>{}, flags = <String, bool>{};
  final collectionEntries = <Map<String, dynamic>>[];
  String lastResult = '', lastLine = '';
  ui.Image? image, personaImage;
  late GameSession session;
  late CollectionPort collection;
  LocaleCatalog get catalog => LocaleCatalog(widget.locales);
  String? legacyProfileId() {
    final profiles = (widget.story['legacyProfiles'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final candidates = profiles.where((profile) {
      final endings =
          (profile['endingIds'] as List? ?? const []).cast<String>();
      return collectionEntries.any((entry) => endings.contains(entry['id']));
    }).toList()
      ..sort((a, b) => '${a['id']}'.compareTo('${b['id']}'));
    return candidates.isEmpty ? null : '${candidates.first['id']}';
  }

  String tr(String key, String fallback) =>
      catalog.text(locale, key, fallback: fallback);
  void toggleLocale() => setState(() {
        locale = locale == 'ko' ? 'en' : 'ko';
        setActiveLocale(locale, catalog);
      });
  List<Activity> get activities => activitiesFromStory(widget.story);

  @override
  void initState() {
    super.initState();
    collection = createCollectionAdapter();
    collectionEntries.addAll(collection.read());
    session = GameSession(JsonStoryAdapter(widget.story), createSaveAdapter(),
        legacyUnlocked: widget.legacySeed ||
            widget.legacyId != null ||
            collectionEntries.isNotEmpty,
        legacyId:
            widget.legacyId ?? (widget.legacySeed ? null : legacyProfileId()));
    if (widget.initialSnapshot != null) {
      session.world.restore(widget.initialSnapshot!);
      page = widget.initialSnapshot!.page;
    } else {
      try {
        final restored = session.restore();
        if (restored != null) page = restored.page;
      } catch (_) {}
    }
    sync();
    FontLoader('NotoSansKR')
      ..addFont(rootBundle.load('assets/fonts/NotoSansKR-Regular.ttf'))
      ..load().then((_) {
        if (mounted) setState(() {});
      });
    rootBundle
        .load('assets/noa-sprite-sheet.png')
        .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
        .then((c) => c.getNextFrame())
        .then((f) {
      if (mounted) setState(() => image = f.image);
    });
    rootBundle
        .load('assets/lumen-personality-sheet.png')
        .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
        .then((c) => c.getNextFrame())
        .then((f) {
      if (mounted) setState(() => personaImage = f.image);
    });
  }

  void sync() {
    setActiveLocale(locale, catalog);
    final s = session.snapshot(page: page);
    setActiveFlags(s.flags);
    week = s.week;
    coins = s.coins;
    fatigue = s.fatigue;
    selected = s.selected;
    persona = s.persona;
    eventIndex = s.eventIndex;
    lastResult = s.lastResult;
    lastLine = s.lastLine;
    history
      ..clear()
      ..addAll(s.history);
    stats
      ..clear()
      ..addAll(s.stats);
    bonds
      ..clear()
      ..addAll(s.bonds);
    milestones
      ..clear()
      ..addAll(s.milestones);
    flags
      ..clear()
      ..addAll(s.flags);
  }

  void next() {
    final a = activities[selected.clamp(0, activities.length - 1)];
    final milestoneCount = milestones.length;
    setState(() {
      session.choose(
          ActivityChosen(a.stat, a.delta, a.coins, a.fatigue, label: a.label));
      sync();
      if (week >= session.story.endingWeek) {
        finished = true;
        recordEnding();
        page = 2;
      } else {
        final upcoming =
            session.story.events.indexWhere((e) => e['week'] == week);
        if (upcoming >= 0) {
          eventIndex = upcoming;
          session.world.progress[0]!.eventIndex = eventIndex;
          page = 3;
        } else if (milestones.length > milestoneCount) {
          page = 6;
        }
      }
      session.persist(page: page);
    });
  }

  void recordEnding() {
    final d = resolveEnding(JsonStoryAdapter(widget.story), stats,
        bonds: bonds, milestones: milestones);
    final routes = (d['epilogues'] as List? ?? const [])
        .map((route) => '${(route as Map)['id']}')
        .toList();
    collection.record('${d['id']}', (d['rank'] as int?) ?? 1, routes: routes);
    collectionEntries
      ..clear()
      ..addAll(collection.read());
  }

  bool choiceAvailable(Map e) =>
      (e['requiresStat'] == null ||
          (stats[e['requiresStat']] ?? 0) >= (e['requiresMin'] as int? ?? 0)) &&
      (e['requiresBondId'] == null ||
          (bonds[e['requiresBondId']] ?? 0) >=
              (e['requiresBondMin'] as int? ?? 0)) &&
      (e['requiresFlag'] == null || flags[e['requiresFlag']] == true);
  void chooseEvent(int i) {
    final e = session.story.events[eventIndex]['choices'][i];
    if (!choiceAvailable(e)) {
      final req = e['requiresStat'],
          bondReq = e['requiresBondId'],
          flag = e['requiresFlag'];
      setState(() => lastResult = flag != null
          ? '기억 조건 부족 · $flag 필요'
          : bondReq == null
              ? '조건 부족 · $req ${e['requiresMin']} 필요'
              : '관계 조건 부족 · $bondReq 유대 ${e['requiresBondMin']} 필요');
      return;
    }
    final d = e['delta'] as int,
        g = e['coins'] as int,
        milestoneCount = milestones.length;
    setState(() {
      session.chooseEvent(StoryChoiceMade(e['stat'], d, g, e['label'],
          bondId: e['bondId'] as String?,
          bondDelta: (e['bondDelta'] as int?) ?? 0,
          rivalId: e['rivalId'] as String?,
          rivalDelta: (e['rivalDelta'] as int?) ?? 0,
          requiresStat: e['requiresStat'] as String?,
          requiresMin: (e['requiresMin'] as int?) ?? 0,
          requiresBondId: e['requiresBondId'] as String?,
          requiresBondMin: (e['requiresBondMin'] as int?) ?? 0,
          requiresFlag: e['requiresFlag'] as String?,
          setsFlag: e['setsFlag'] as String?,
          line: e['line'] as String? ?? '',
          legacyBonuses: (e['legacyBonuses'] as Map?)?.cast<String, dynamic>(),
          legacyId: session.legacyId));
      sync();
      page = milestones.length > milestoneCount ? 6 : 0;
      session.persist(page: page);
    });
  }

  GameSnapshot snapshot() => session.snapshot(page: page);
  void restore(GameSnapshot s) {
    setState(() {
      session.world.restore(s);
      sync();
      page = s.page;
    });
  }

  void select(int i) {
    setState(() {
      selected = i;
      session.world.progress[0]!.selected = i;
      session.persist();
    });
  }

  void handleTap(Offset position, Size viewport) {
    final logical = CanvasViewport.logicalTap(position, viewport),
        x = logical.dx,
        y = logical.dy;
    if (page == 1) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y > 570 && x < 720)
        setState(() {
          persona = (x ~/ 245).clamp(0, 2);
          session.world.progress[0]!.persona = persona;
        });
      else if (y > 570)
        setState(() => page = 0);
      else if (y > 180 && y < 290)
        setState(() {
          persona = (x ~/ 245).clamp(0, 2);
          session.world.progress[0]!.persona = persona;
        });
    } else if (page == 2) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y > 490 && y < 680) restart();
    } else if (page == 3) {
      if (y > 260 && y < 470) chooseEvent((x ~/ 380).clamp(0, 1));
    } else if (page == 4) {
      if (y > 390 && y < 470 && x < 365) {
        Clipboard.setData(ClipboardData(text: snapshot().encode()));
        session.persist(page: page);
      } else if (y > 390 && y < 470)
        importSave();
      else if (y > 520 && x < 200)
        setState(() => page = 0);
      else if (y < 100) setState(() => page = 0);
    } else if (page == 5) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y < 100 || y > 560) setState(() => page = 0);
    } else if (page == 6) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y > 500)
        setState(() {
          page = 0;
          session.persist(page: page);
        });
    } else if (y > 500 && x >= 590) {
      next();
    } else if (y > 500 && x >= 430) {
      setState(() => page = 1);
    } else if (y > 500 && x >= 260) {
      setState(() => page = 4);
    } else if (y >= 620 && y < 650 && x < 220) {
      // Preserve the generous lower-screen tap target used by compact devices.
      next();
    } else if (y > 640 && x < 220) {
      setState(() => page = 5);
    } else if (y > 260 && y < 470) {
      final row = y < 350 ? 0 : 1,
          col = (x ~/ 245).clamp(0, 2),
          i = row == 0 ? col : 3 + col;
      if (i < activities.length) select(i);
    } else if (y > 500) {
      next();
    }
  }

  Future<void> importSave() async {
    final c = TextEditingController();
    final raw = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('저장 코드 붙여넣기'),
                content: TextField(controller: c, maxLines: 5),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, c.text),
                      child: const Text('복원'))
                ]));
    if (raw == null || raw.isEmpty) return;
    try {
      restore(GameSnapshot.decode(raw));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장 코드가 올바르지 않습니다.')));
    }
  }

  void restart() {
    session.save.clear();
    setState(() {
      session = GameSession(JsonStoryAdapter(widget.story), createSaveAdapter(),
          legacyUnlocked:
              widget.legacyId != null || collectionEntries.isNotEmpty,
          legacyId: widget.legacyId ?? legacyProfileId());
      week = 1;
      coins = 12;
      fatigue = 0;
      selected = 0;
      page = 0;
      eventIndex = 0;
      finished = false;
      lastResult = '';
      lastLine = '';
      history.clear();
      stats
        ..updateAll((k, v) => k == '지혜'
            ? 4
            : k == '공감'
                ? 5
                : 3);
      bonds..updateAll((k, v) => 0);
      milestones.clear();
      flags.clear();
      sync();
    });
  }

  @override
  Widget build(BuildContext c) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: paper,
          body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
            final viewport = Size(
                constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : CanvasViewport.logicalSize.width,
                constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : CanvasViewport.logicalSize.height);
            return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => handleTap(d.localPosition, viewport),
                child: CustomPaint(
                    key: ValueKey(
                        '$page-$week-$persona-$eventIndex${locale == 'ko' ? '' : '-$locale'}'),
                    painter: Scene(
                        widget.story,
                        week,
                        coins,
                        fatigue,
                        selected,
                        stats,
                        bonds,
                        milestones,
                        flags,
                        lastResult,
                        lastLine,
                        page,
                        persona,
                        image,
                        personaImage,
                        history,
                        eventIndex,
                        snapshot().encode(),
                        activities,
                        collectionEntries,
                        locale,
                        widget.locales),
                    size: viewport));
          }))));
}

class Scene extends CustomPainter {
  Scene(
      this.s,
      this.week,
      this.coins,
      this.fatigue,
      this.selected,
      this.stats,
      this.bonds,
      this.milestones,
      this.flags,
      this.lastResult,
      this.lastLine,
      this.page,
      this.persona,
      this.image,
      this.personaImage,
      this.history,
      this.eventIndex,
      this.saveCode,
      this.activities,
      this.collectionEntries,
      this.locale,
      this.locales) {
    repaintKey = canvasSceneFingerprint([
      s.hashCode,
      week,
      coins,
      fatigue,
      selected,
      page,
      persona,
      eventIndex,
      stats,
      bonds,
      milestones,
      flags,
      lastResult,
      lastLine,
      image?.hashCode,
      personaImage?.hashCode,
      history,
      saveCode,
      activities
          .map((a) => [a.label, a.icon, a.stat, a.delta, a.fatigue, a.coins])
          .toList(),
      collectionEntries,
      locale,
      locales.hashCode,
    ]);
  }
  final Map<String, dynamic> s;
  final int week, coins, fatigue, selected, page, persona, eventIndex;
  final Map<String, int> stats, bonds;
  final Map<String, bool> milestones, flags;
  final String lastResult, lastLine;
  final ui.Image? image, personaImage;
  final List<String> history;
  final String saveCode;
  final List<Activity> activities;
  final List<Map<String, dynamic>> collectionEntries;
  final String locale;
  final Map<String, Map<String, String>> locales;
  late final String repaintKey;
  void txt(Canvas c, String v, Offset p, double z, Color color,
      {bool bold = false, double maxWidth = 330}) {
    final t = TextPainter(
        text: TextSpan(
            text: v,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: z,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: maxWidth);
    t.paint(c, p);
  }

  void box(Canvas c, Rect r, Color color,
      {double radius = 18, Color? stroke, bool shadow = false}) {
    final shape = RRect.fromRectAndRadius(r, Radius.circular(radius));
    if (shadow) {
      c.drawRRect(shape.shift(const Offset(0, 3)),
          Paint()..color = ink.withValues(alpha: .08));
    }
    c.drawRRect(shape, Paint()..color = color);
    if (stroke != null)
      c.drawRRect(
          shape,
          Paint()
            ..color = stroke
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
  }

  void background(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, 0, 760, 700),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 0),
              const Offset(760, 700), [paper, const Color(0xfff1f5ee)]));
    c.drawCircle(
        const Offset(700, 18),
        170,
        Paint()
          ..shader = ui.Gradient.radial(const Offset(700, 18), 170,
              [sun.withValues(alpha: .16), sun.withValues(alpha: 0)]));
    final constellation = Paint()
      ..color = teal.withValues(alpha: .14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final stars = [
      const Offset(625, 82),
      const Offset(680, 54),
      const Offset(724, 102),
      const Offset(653, 126)
    ];
    for (var i = 0; i < stars.length - 1; i++) {
      c.drawLine(stars[i], stars[i + 1], constellation);
    }
    for (final star in stars) {
      c.drawCircle(star, 3, Paint()..color = sun.withValues(alpha: .55));
    }
  }

  void statPill(Canvas c, String label, int value, double x, Color accent) {
    box(c, Rect.fromLTWH(x, 157, 104, 28), Colors.white.withValues(alpha: .08),
        radius: 10);
    c.drawCircle(Offset(x + 14, 171), 4, Paint()..color = accent);
    txt(c, label, Offset(x + 25, 163), 10, Colors.white70,
        bold: true, maxWidth: 42);
    txt(c, '$value', Offset(x + 75, 160), 14, Colors.white,
        bold: true, maxWidth: 24);
  }

  void mark(Canvas c, String icon, Offset o, Color color) {
    final p = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        q = o + const Offset(18, 18);
    if (icon == '✦') {
      c.drawLine(q + const Offset(-15, 0), q + const Offset(15, 0), p);
      c.drawLine(q + const Offset(0, -15), q + const Offset(0, 15), p);
      c.drawLine(q + const Offset(-10, -10), q + const Offset(10, 10), p);
      c.drawLine(q + const Offset(10, -10), q + const Offset(-10, 10), p);
    } else if (icon == '❈') {
      c.drawCircle(q, 14, p);
      c.drawCircle(q, 5, p);
      for (final a in [0.0, 1.57, 3.14, 4.71])
        c.drawLine(q + Offset(cos(a) * 5, sin(a) * 5),
            q + Offset(cos(a) * 14, sin(a) * 14), p);
    } else if (icon == '◈') {
      final path = Path()
        ..moveTo(q.dx, q.dy - 16)
        ..lineTo(q.dx + 16, q.dy)
        ..lineTo(q.dx, q.dy + 16)
        ..lineTo(q.dx - 16, q.dy)
        ..close();
      c.drawPath(path, p);
    } else if (icon == '☾') {
      c.drawArc(Rect.fromCircle(center: q, radius: 15), -1.0, 4.6, false, p);
    } else {
      c.drawRect(Rect.fromCenter(center: q, width: 25, height: 25), p);
    }
  }

  StoryPort get storyModel => JsonStoryAdapter(s);

  List<Map<String, dynamic>> get fateProgress =>
      resolveFateThreads(storyModel, flags);

  List<Map<String, dynamic>> get questProgress =>
      resolveCompanionQuests(storyModel, bonds, flags);

  int get discoveredFateCount =>
      fateProgress.where((thread) => thread['discovered'] == true).length;

  int get completedQuestStages => questProgress.fold<int>(
      0, (sum, quest) => sum + ((quest['completedStages'] as int?) ?? 0));

  int get totalQuestStages => questProgress.fold<int>(
      0, (sum, quest) => sum + ((quest['totalStages'] as int?) ?? 0));

  String shortRouteName(Map<String, dynamic> location) => activeLocale == 'ko'
      ? '${location['name']}'
      : localized('${location['nameKey']}', '${location['name']}');

  void routeAtlas(Canvas c, {required Offset origin}) {
    final locations = (s['locations'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .take(4)
        .toList();
    txt(c, activeLocale == 'ko' ? '발견 경로' : 'Route atlas', origin, 10, teal,
        bold: true);
    final startX = origin.dx + 18.0, step = 170.0, nodeY = origin.dy + 28;
    for (var i = 0; i < locations.length; i++) {
      final location = locations[i],
          x = startX + i * step,
          found = flags['place:${location['id']}'] == true,
          color = found ? teal : ink.withValues(alpha: .18);
      if (i < locations.length - 1) {
        c.drawLine(
            Offset(x + 9, nodeY),
            Offset(x + step - 9, nodeY),
            Paint()
              ..color =
                  found && flags['place:${locations[i + 1]['id']}'] == true
                      ? teal
                      : ink.withValues(alpha: .12)
              ..strokeWidth = 2);
      }
      c.drawCircle(Offset(x, nodeY), 9, Paint()..color = color);
      c.drawCircle(
          Offset(x, nodeY),
          9,
          Paint()
            ..color = paper.withValues(alpha: .0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      txt(
          c,
          found ? shortRouteName(location) : '· · ·',
          Offset(x - 42, nodeY + 14),
          9,
          found ? ink : ink.withValues(alpha: .35),
          maxWidth: 84);
    }
  }

  void trackerLine(Canvas c, Offset origin, {double maxWidth = 700}) {
    final fateLabel = activeLocale == 'ko' ? '나비효과' : 'Butterfly effects';
    final questLabel = activeLocale == 'ko' ? '동료 퀘스트' : 'Companion quests';
    txt(
        c,
        '$fateLabel $discoveredFateCount/${fateProgress.length} · '
        '$questLabel $completedQuestStages/$totalQuestStages',
        origin,
        10,
        teal,
        bold: true,
        maxWidth: maxWidth);
  }

  void drawChoiceEcho(Canvas c, Map<String, dynamic> choice, Offset origin) {
    final flag = choice['setsFlag'] as String?;
    if (flag == null) return;
    txt(
        c,
        activeLocale == 'ko'
            ? '나비효과 · 다음 장에 남음'
            : 'Butterfly effect · carried forward',
        origin,
        10,
        teal,
        bold: true,
        maxWidth: 290);
  }

  void portrait(Canvas c, Rect d, int n) {
    final sheet = page == 1 ? personaImage : image;
    if (sheet != null) {
      final w = sheet.width / 3.0,
          h = (page == 1 ? sheet.height : sheet.height * .78).toDouble();
      c.drawImageRect(sheet, Rect.fromLTWH(n * w, 0, w, h), d, Paint());
      return;
    }
    chibi(c, d, n);
  }

  void chibi(Canvas c, Rect d, int n) {
    final p = Paint()..color = const Color(0xffffd9c0),
        cx = d.center.dx,
        head = Size(d.width * .66, d.height * .42);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(cx, d.top + d.height * .25),
            width: head.width,
            height: head.height),
        p);
    p.color = const Color(0xff273452);
    c.drawOval(
        Rect.fromCenter(
            center: Offset(cx, d.top + d.height * .16),
            width: head.width * 1.08,
            height: head.height * .6),
        p);
    p.color = sun;
    for (final x in [cx - d.width * .12, cx + d.width * .12])
      c.drawCircle(Offset(x, d.top + d.height * .25), d.width * .035, p);
    p.color = teal;
    c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(d.left + d.width * .22, d.top + d.height * .45,
                d.width * .56, d.height * .27),
            Radius.circular(20)),
        p);
    p.color = const Color(0xffa84f3c);
    c.drawOval(
        Rect.fromLTWH(d.left + d.width * .25, d.top + d.height * .67,
            d.width * .22, d.height * .2),
        p);
    c.drawOval(
        Rect.fromLTWH(d.left + d.width * .53, d.top + d.height * .67,
            d.width * .22, d.height * .2),
        p);
    p.color = ink;
    c.drawOval(
        Rect.fromLTWH(d.left + d.width * .28, d.bottom - d.height * .12,
            d.width * .18, d.height * .12),
        p);
    c.drawOval(
        Rect.fromLTWH(d.left + d.width * .54, d.bottom - d.height * .12,
            d.width * .18, d.height * .12),
        p);
  }

  @override
  void paint(Canvas c, Size z) {
    setActiveLocale(locale, LocaleCatalog(locales));
    final frame = CanvasViewport.frame(z),
        u = frame.scale,
        dx = frame.offset.dx,
        dy = frame.offset.dy;
    c.save();
    c.translate(dx, dy);
    c.scale(u);
    background(c);
    if (page == 1) {
      illustration(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      drawLocalizedIllustration(c, s, persona);
      c.restore();
      return;
    }
    if (page == 2) {
      ending(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 3) {
      if (activeLocale == 'ko') event(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      drawLocalizedEvent(c, s, eventIndex, stats, bonds);
      c.restore();
      return;
    }
    if (page == 4) {
      savePage(c);
      c.restore();
      return;
    }
    if (page == 5) {
      ledger(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 6) {
      chapterClosure(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    home(c);
    drawFeedbackBanner(c, lastResult, lastLine);
    seasonProgress(c);
    c.restore();
  }

  void seasonProgress(Canvas c) {
    final endingWeek = (s['endingWeek'] as int? ?? 12),
        campaignWeeks = (s['campaignWeeks'] as int? ?? endingWeek - 1),
        progress = ((week - 1) / campaignWeeks).clamp(0.0, 1.0),
        people = (s['personalities'] as List? ?? const []),
        person =
            people.isEmpty ? null : people[persona.clamp(0, people.length - 1)],
        chapters = (s['progression'] as List? ?? const []),
        chapter = chapters.cast<Map>().firstWhere(
            (chapter) =>
                (chapter['weekStart'] as int) <= week &&
                (chapter['weekEnd'] as int) >= week,
            orElse: () => {}),
        chapterIndex = chapters.cast<Map>().indexOf(chapter),
        chapterTitle = chapter.isEmpty
            ? ''
            : activeLocale == 'ko'
                ? '${chapterIndex + 1}막 · ${chapter['title']}'
                : localized('${chapter['titleKey']}', '${chapter['title']}');
    txt(
        c,
        '$chapterTitle · 루멘의 $week주차/$campaignWeeks · ${person?['name'] ?? '성격 미지정'}',
        const Offset(24, 228),
        10,
        teal,
        bold: true);
    box(c, const Rect.fromLTWH(155, 231, 555, 5), ink.withValues(alpha: .12),
        radius: 3);
    box(c, Rect.fromLTWH(155, 231, 555 * progress, 5), teal, radius: 3);
  }

  void home(Canvas c) {
    final condition = fatigue >= 10
            ? '오늘은 무리하지 말기'
            : fatigue >= 8
                ? '조금 지쳤어요'
                : '마음이 맑아요',
        rawGoals = (s['milestones'] as List? ?? const []),
        pending = rawGoals
            .where((g) => !milestones.containsKey(g['id']) && g['week'] >= week)
            .toList(),
        goal = pending.isEmpty ? null : pending.first,
        people = (s['personalities'] as List? ?? const []),
        talent =
            people.isEmpty ? null : people[persona.clamp(0, people.length - 1)];
    txt(c, s['title'], const Offset(24, 24), 30, ink, bold: true);
    txt(c, s['setting'], const Offset(25, 65), 14, teal);
    box(c, const Rect.fromLTWH(24, 105, 712, 120), ink,
        radius: 22, shadow: true);
    box(c, const Rect.fromLTWH(44, 125, 76, 76), sun, radius: 18);
    portrait(c, const Rect.fromLTWH(45, 122, 74, 80), persona);
    txt(c, '${s['hero']} · $week주차', const Offset(140, 128), 20, Colors.white,
        bold: true);
    statPill(c, '지혜', stats['지혜'] ?? 0, 140, sun);
    statPill(c, '공감', stats['공감'] ?? 0, 252, const Color(0xff9fe0c9));
    statPill(c, '용기', stats['용기'] ?? 0, 364, const Color(0xffff9a7a));
    txt(c, '은화 $coins · 피로 $fatigue/12 · $condition', const Offset(140, 190),
        14, fatigue > 9 ? const Color(0xffff8b6b) : sun);
    txt(c, '유대 루미 ${bonds['lumi']} · 보라 ${bonds['bora']} · 타로 ${bonds['taro']}',
        const Offset(140, 208), 10, Colors.white70);
    txt(
        c,
        goal == null
            ? (rawGoals.isEmpty ? '이번 회차는 자유롭게 시작합니다.' : '계절 목표를 모두 확인했습니다.')
            : '다음 목표 · ${goal['title']} · ${goal['stat']} ${stats[goal['stat']]}/${goal['min']}',
        const Offset(24, 250),
        14,
        teal,
        bold: true);
    for (var i = 0; i < activities.length; i++) {
      final a = activities[i],
          row = i < 3 ? 0 : 1,
          col = i < 3 ? i : i - 3,
          x = 24 + col * 236.0,
          y = row == 0 ? 275.0 : 370.0,
          on = i == selected,
          bonus = talent?['focusStat'] == a.stat && a.delta > 0
              ? ' · 재능 +${talent['focusBonus']}'
              : '';
      box(c, Rect.fromLTWH(x, y, 220, 80), on ? teal : Colors.white,
          stroke: on ? teal : ink.withValues(alpha: .12), shadow: true);
      c.drawCircle(Offset(x + 34, y + 40), 24,
          Paint()..color = on ? Colors.white.withValues(alpha: .16) : paper);
      mark(c, a.icon, Offset(x + 16, y + 22), on ? Colors.white : teal);
      txt(c, a.label, Offset(x + 52, y + 12), 14, on ? Colors.white : ink,
          bold: true);
      txt(c, '${a.hint}$bonus', Offset(x + 52, y + 40), 9,
          on ? Colors.white70 : ink.withValues(alpha: .55));
    }
    box(c, const Rect.fromLTWH(260, 500, 150, 54), Colors.white,
        radius: 15, stroke: teal, shadow: true);
    txt(c, '기록 보관소', const Offset(282, 517), 14, teal, bold: true);
    box(c, const Rect.fromLTWH(430, 500, 150, 54), Colors.white,
        radius: 15, stroke: teal, shadow: true);
    txt(c, '일러스트', const Offset(458, 517), 16, teal, bold: true);
    box(c, const Rect.fromLTWH(590, 500, 146, 54), teal,
        radius: 15, shadow: true);
    txt(c, '하루 보내기 →', const Offset(607, 517), 14, Colors.white, bold: true);
    trackerLine(c, const Offset(24, 565));
    routeAtlas(c, origin: const Offset(24, 580));
    box(c, const Rect.fromLTWH(24, 660, 170, 30), Colors.white,
        radius: 12, stroke: teal);
    txt(c, localized('ui.ledger.button', '운명 기록'), const Offset(62, 668), 12,
        teal,
        bold: true);
  }

  void ledger(Canvas c) {
    final threads = fateProgress,
        quests = questProgress,
        companions = (s['companions'] as List? ?? const []).cast<Map>(),
        receipts = recentDecisionReceipts(history);
    txt(c, localized('ui.ledger.title', '운명 기록 보관소'), const Offset(24, 24), 30,
        ink,
        bold: true);
    txt(c, localized('ui.ledger.subtitle', '선택은 기억이 되고, 동행은 다음 장을 연다.'),
        const Offset(25, 65), 13, teal,
        maxWidth: 560);
    txt(c, localized('ui.ledger.system', '루멘 규칙 엔진 · 자동 판정 · replay 가능'),
        const Offset(25, 91), 10, ink.withValues(alpha: .55));
    for (var i = 0; i < threads.length; i++) {
      final thread = threads[i],
          discovered = thread['discovered'] == true,
          x = 24 + (i % 3) * 240.0,
          y = 120 + (i ~/ 3) * 105.0,
          title = localized('${thread['titleRef']}', '${thread['id']}'),
          detail = discovered
              ? localized('${thread['detailKey']}', '${thread['detail']}')
              : localized('ui.ledger.hidden', '아직 닿지 않음');
      box(c, Rect.fromLTWH(x, y, 224, 88), discovered ? Colors.white : paper,
          radius: 16,
          stroke: discovered ? teal : ink.withValues(alpha: .12),
          shadow: discovered);
      mark(c, discovered ? '✦' : '◇', Offset(x + 10, y + 10),
          discovered ? teal : ink.withValues(alpha: .35));
      txt(c, title, Offset(x + 50, y + 12), 12, ink, bold: true, maxWidth: 130);
      txt(c, detail, Offset(x + 18, y + 48), 9,
          discovered ? teal : ink.withValues(alpha: .45),
          maxWidth: 190);
      txt(
          c,
          discovered ? localized('ui.ledger.discovered', '발견됨') : '·',
          Offset(x + 184, y + 12),
          9,
          discovered ? teal : ink.withValues(alpha: .3),
          bold: true,
          maxWidth: 32);
    }
    txt(c, localized('ui.ledger.quest', '동행 퀘스트'), const Offset(24, 350), 16,
        teal,
        bold: true);
    for (var i = 0; i < quests.length; i++) {
      final quest = quests[i],
          companion = companions.firstWhere(
              (candidate) => '${candidate['id']}' == '${quest['companionId']}',
              orElse: () => {'name': quest['companionId']}),
          x = 24 + i * 240.0,
          completed = quest['completedStages'] as int,
          total = quest['totalStages'] as int,
          title = localized('${quest['titleRef']}', '${companion['name']}'),
          complete = quest['complete'] == true;
      box(c, Rect.fromLTWH(x, 380, 224, 132), complete ? teal : Colors.white,
          radius: 18, stroke: teal, shadow: true);
      txt(c, '${companion['name']} · $title', Offset(x + 16, 400), 12,
          complete ? Colors.white : ink,
          bold: true, maxWidth: 190);
      txt(
          c,
          '$completed/$total · ${localized(complete ? 'ui.ledger.complete' : 'ui.ledger.progress', complete ? 'COMPLETE' : 'IN PROGRESS')}',
          Offset(x + 16, 432),
          10,
          complete ? sun : teal,
          bold: true);
      box(c, Rect.fromLTWH(x + 16, 462, 190, 6), ink.withValues(alpha: .12),
          radius: 3);
      box(
          c,
          Rect.fromLTWH(
              x + 16, 462, 190 * (total == 0 ? 0 : completed / total), 6),
          complete ? sun : teal,
          radius: 3);
    }
    if (receipts.isNotEmpty) {
      final owner = receipts.first.owner, contract = receipts.first.contract;
      txt(
          c,
          '${localized('ui.ledger.receipts', '시스템 판정 영수증')} · $owner · $contract',
          const Offset(24, 535),
          12,
          teal,
          bold: true);
      for (var i = 0; i < receipts.take(2).length; i++) {
        final receipt = receipts[i],
            status = localized(
                receipt.approved
                    ? 'ui.ledger.receipt.approved'
                    : 'ui.ledger.receipt.rejected',
                receipt.approved ? '승인' : '거절'),
            kind = localized('ui.ledger.receipt.${receipt.kind}', receipt.kind),
            y = 558 + i * 38.0;
        box(c, Rect.fromLTWH(24, y, 712, 30),
            receipt.approved ? Colors.white : const Color(0xffffeee8),
            radius: 10,
            stroke: receipt.approved ? teal : const Color(0xffa84f3c));
        txt(
            c,
            '$status · $kind · ${receipt.subject} · ${receipt.week}주 · ${receipt.rule} · #${receipt.shortHash} · p#${receipt.shortPreconditionHash}',
            Offset(38, y + 8),
            9,
            receipt.approved ? ink : const Color(0xffa84f3c),
            maxWidth: 670);
      }
    }
    txt(c, localized('ui.ledger.back', '← 홈으로'),
        Offset(24, receipts.isEmpty ? 570 : 650), 14, teal,
        bold: true);
  }

  void chapterClosure(Canvas c) {
    final chapters = (s['progression'] as List? ?? const []).cast<Map>(),
        chapter = chapters.firstWhere(
            (item) =>
                week >= (item['weekStart'] as int) &&
                week <= (item['weekEnd'] as int),
            orElse: () => <String, dynamic>{}),
        milestoneId = '${chapter['milestoneId']}',
        goals = (s['milestones'] as List? ?? const []).cast<Map>(),
        goal = goals.firstWhere((item) => '${item['id']}' == milestoneId,
            orElse: () => <String, dynamic>{}),
        passed = milestones[milestoneId] == true,
        title = localized('${chapter['titleKey']}', '${chapter['title']}'),
        result = localized('${passed ? goal['passKey'] : goal['failKey']}',
            '${passed ? goal['pass'] : goal['fail']}');
    txt(
        c,
        localized(passed ? 'ui.closure.recorded' : 'ui.closure.next',
            passed ? '장 결산 · 기록됨' : '장 결산 · 다음 기회'),
        const Offset(24, 28),
        30,
        ink,
        bold: true,
        maxWidth: 700);
    txt(c, '$title · ${goal['week']}${localized('ui.closure.week', '주차')}',
        const Offset(25, 70), 14, teal,
        bold: true);
    box(c, const Rect.fromLTWH(24, 120, 270, 410), ink,
        radius: 24, shadow: true);
    portrait(c, const Rect.fromLTWH(48, 155, 222, 300), persona);
    mark(c, passed ? '✦' : '◇', const Offset(102, 420),
        passed ? sun : Colors.white70);
    txt(
        c,
        localized(passed ? 'ui.closure.goalCleared' : 'ui.closure.keepGrowing',
            passed ? '목표 달성' : '다음에 이어가기'),
        const Offset(65, 490),
        12,
        passed ? sun : Colors.white70,
        bold: true);
    txt(c, localized('ui.closure.question', '이번 장의 질문'), const Offset(340, 132),
        13, teal,
        bold: true);
    txt(c, localized('${chapter['payoffKey']}', '${chapter['payoff'] ?? ''}'),
        const Offset(340, 164), 22, ink,
        bold: true, maxWidth: 360);
    box(c, const Rect.fromLTWH(340, 250, 360, 125), Colors.white,
        radius: 20, stroke: teal, shadow: true);
    txt(c, result, const Offset(365, 282), 17, ink, bold: true, maxWidth: 310);
    txt(c, '${goal['stat']} ${stats[goal['stat']] ?? 0}/${goal['min']}',
        const Offset(365, 338), 14, passed ? teal : const Color(0xffa84f3c),
        bold: true);
    trackerLine(c, const Offset(340, 405), maxWidth: 360);
    txt(c, lastResult, const Offset(340, 440), 11, ink.withValues(alpha: .6),
        maxWidth: 360);
    box(c, const Rect.fromLTWH(340, 510, 360, 64), teal,
        radius: 18, shadow: true);
    txt(c, localized('ui.closure.nextPage', '다음 장으로 →'), const Offset(445, 531),
        17, Colors.white,
        bold: true);
    txt(c, localized('ui.closure.link', '결과는 시스템 영수증과 다음 선택에 연결됩니다.'),
        const Offset(340, 595), 11, teal,
        maxWidth: 360);
  }

  void illustration(Canvas c) {
    final cs = (s['companions'] as List? ?? const []),
        p = s['personalities'][persona],
        comp = cs.isEmpty ? null : cs[persona] as Map,
        talent = p['focusStat'] == null
            ? '성격의 재능은 오늘의 선택에 스며듭니다.'
            : '재능 · ${p['focusStat']} 활동 성장 +${p['focusBonus']}';
    txt(c, '노아의 기록', const Offset(24, 24), 30, ink, bold: true);
    txt(c, '성격을 고르고, 오늘의 마음을 읽습니다.', const Offset(25, 65), 14, teal);
    box(c, const Rect.fromLTWH(24, 100, 330, 455), ink,
        radius: 24, shadow: true);
    portrait(c, const Rect.fromLTWH(46, 125, 286, 390),
        (comp?['portraitFrame'] as int?) ?? persona);
    txt(c, p['name'], const Offset(390, 125), 24, ink, bold: true);
    txt(c, comp == null ? p['voice'] : '${comp['name']} · ${comp['role']}',
        const Offset(390, 165), 14, teal);
    txt(c, talent, const Offset(390, 195), 13, teal);
    box(c, const Rect.fromLTWH(390, 220, 330, 150), Colors.white,
        radius: 20, stroke: ink.withValues(alpha: .12), shadow: true);
    txt(c, '“${p['line']}”', const Offset(415, 250), 20, ink, bold: true);
    txt(c, '${s['hero']}의 이번 주 기록', const Offset(390, 400), 14,
        ink.withValues(alpha: .55));
    for (var i = 0; i < 3; i++) {
      final x = 24 + i * 236.0,
          on = i == persona,
          label = cs.isEmpty ? s['personalities'][i]['name'] : cs[i]['name'];
      box(c, Rect.fromLTWH(x, 575, 220, 54), on ? teal : Colors.white,
          radius: 15, stroke: teal, shadow: true);
      txt(c, label, Offset(x + 25, 593), 13, on ? Colors.white : teal,
          bold: true);
    }
    txt(c, '← 돌아가기', const Offset(610, 650), 14, teal, bold: true);
  }

  void event(Canvas c) {
    final e = s['events'][eventIndex];
    final locations = (s['locations'] as List? ?? const []).cast<Map>(),
        location = locations.firstWhere((l) => l['id'] == e['locationId'],
            orElse: () => {'name': e['locationId'] ?? ''}),
        locationName = activeLocale == 'ko'
            ? '${location['name']}'
            : localized('${location['nameKey']}', '${location['name']}');
    txt(c, '작은 사건 · ${e['week']}주차', const Offset(24, 28), 30, ink, bold: true);
    txt(c, locationName, const Offset(25, 66), 11, teal, bold: true);
    txt(c, e['title'], const Offset(25, 84), 16, teal);
    box(c, const Rect.fromLTWH(24, 120, 712, 110), ink, radius: 22);
    txt(c, e['body'], const Offset(48, 158), 22, Colors.white,
        bold: true, maxWidth: 640);
    for (var i = 0; i < 2; i++) {
      final x = 24 + i * 356.0,
          ch = e['choices'][i],
          req = ch['requiresStat'] as String?,
          min = ch['requiresMin'] as int?,
          bondReq = ch['requiresBondId'] as String?,
          bondMin = ch['requiresBondMin'] as int?,
          flagReq = ch['requiresFlag'] as String?,
          locked = (req != null && (stats[req] ?? 0) < (min ?? 0)) ||
              (bondReq != null && (bonds[bondReq] ?? 0) < (bondMin ?? 0)) ||
              (flagReq != null && flags[flagReq] != true),
          tone = locked ? paper : Colors.white,
          rival = ch['rivalId'] as String?,
          rivalDelta = (ch['rivalDelta'] as int?) ?? 0,
          legacyId = flags.keys
              .where((key) => key.startsWith('legacy:'))
              .map((key) => key.substring('legacy:'.length))
              .firstOrNull,
          legacyBonus = legacyId == null
              ? null
              : (ch['legacyBonuses'] as Map?)?[legacyId],
          legacyText = legacyBonus is Map
              ? localized('ui.event.legacyBonus',
                      '계승 ${legacyBonus['stat']} +${legacyBonus['delta']}')
                  .replaceAll('{stat}', '${legacyBonus['stat']}')
                  .replaceAll('{delta}', '${legacyBonus['delta']}')
              : '',
          relation = rival == null
              ? ''
              : ' · $rival 유대 ${rivalDelta >= 0 ? '+' : ''}$rivalDelta';
      box(c, Rect.fromLTWH(x, 270, 332, 190), tone,
          radius: 18,
          stroke: locked ? ink.withValues(alpha: .2) : teal,
          shadow: !locked);
      txt(c, '선택 ${i + 1}', Offset(x + 22, 295), 14,
          locked ? ink.withValues(alpha: .45) : teal,
          bold: true);
      txt(c, ch['label'], Offset(x + 22, 340), 19,
          locked ? ink.withValues(alpha: .45) : ink,
          bold: true);
      txt(
          c,
          locked
              ? '조건: ${flagReq != null ? '$flagReq 기억' : '${bondReq == null ? '$req $min' : '$bondReq 유대 $bondMin'}'} 필요'
              : '${ch['stat']} +${ch['delta']}   은화 ${ch['coins']}   유대 +${(ch['bondDelta'] as int?) ?? 0}$relation$legacyText',
          Offset(x + 22, 400),
          13,
          locked ? ink.withValues(alpha: .45) : ink.withValues(alpha: .6));
      drawChoiceEcho(c, ch, Offset(x + 22, 435));
    }
    txt(
        c,
        flags['legacy-star'] == true
            ? localized('ui.event.legacy', '계승의 기록이 새로운 선택을 열었습니다.')
            : lastResult.startsWith('조건') ||
                    lastResult.startsWith('관계 조건') ||
                    lastResult.startsWith('기억 조건')
                ? lastResult
                : '하나를 골라 이야기를 이어갑니다.',
        const Offset(24, 570),
        14,
        flags['legacy-star'] == true ||
                lastResult.startsWith('조건') ||
                lastResult.startsWith('관계 조건') ||
                lastResult.startsWith('기억 조건')
            ? const Color(0xffa84f3c)
            : ink.withValues(alpha: .55));
  }

  void savePage(Canvas c) {
    final recent = history.reversed.take(3).toList(),
        endings = (s['endings'] as List? ?? const []).cast<Map>(),
        known = endings.length,
        discovered = collectionEntries.map((entry) {
          final e = endings.firstWhere(
              (candidate) => candidate['id'] == entry['id'],
              orElse: () => {'title': entry['id']});
          return '${e['title']} ★${entry['rank']}';
        }).join(' · ');
    final companions = (s['companions'] as List? ?? const []).cast<Map>(),
        companionIds = companions.map((c) => '${c['id']}').toSet(),
        routeIds = collectionEntries
            .expand((entry) =>
                (entry['routes'] as List? ?? const []).cast<String>())
            .where(companionIds.contains)
            .toSet()
            .toList()
          ..sort(),
        routeNames = routeIds
            .map((id) => companions.firstWhere((c) => c['id'] == id,
                orElse: () => {'name': id})['name'])
            .join(' · ');
    txt(c, '기록 보관소', const Offset(24, 28), 32, ink, bold: true);
    txt(c, '현재 상태를 코드로 보관하고 다른 실행에서 복원합니다.', const Offset(25, 70), 14, teal);
    box(c, const Rect.fromLTWH(24, 120, 712, 240), Colors.white,
        radius: 20, stroke: ink.withValues(alpha: .12), shadow: true);
    txt(
        c,
        'replay ${history.length}회 · 목표 ${milestones.values.where((v) => v).length}/${(s['milestones'] as List? ?? const []).length}',
        const Offset(48, 155),
        15,
        ink);
    txt(c, '유대 루미 ${bonds['lumi']} · 보라 ${bonds['bora']} · 타로 ${bonds['taro']}',
        const Offset(48, 180), 13, teal);
    for (var i = 0; i < recent.length; i++)
      txt(c, recent[i].replaceAll('|line:', ' · '), Offset(48, 210 + i * 20),
          10, ink.withValues(alpha: .65));
    txt(c, saveCode.substring(0, saveCode.length > 90 ? 90 : saveCode.length),
        const Offset(48, 285), 10, ink.withValues(alpha: .45));
    txt(
        c,
        '엔딩 도감 ${collectionEntries.length}/$known · ${discovered.isEmpty ? '아직 발견한 결말이 없습니다.' : discovered}',
        const Offset(48, 320),
        11,
        teal);
    txt(
        c,
        '관계 도감 ${routeIds.length}/${companions.length} · ${routeNames.isEmpty ? '아직 발견한 동행이 없습니다.' : routeNames}',
        const Offset(48, 343),
        11,
        teal);
    trackerLine(c, const Offset(48, 368), maxWidth: 650);
    box(c, const Rect.fromLTWH(24, 390, 300, 64), teal,
        radius: 18, shadow: true);
    txt(c, '저장 코드 복사', const Offset(100, 412), 16, Colors.white, bold: true);
    box(c, const Rect.fromLTWH(365, 390, 300, 64), sun,
        radius: 18, shadow: true);
    txt(c, '저장 코드 복원', const Offset(440, 412), 16, ink, bold: true);
    txt(c, '← 홈으로', const Offset(24, 570), 14, teal, bold: true);
  }

  void ending(Canvas c) {
    final d = resolveEnding(JsonStoryAdapter(s), stats,
            bonds: bonds, milestones: milestones),
        rank = (d['rank'] as int?) ?? 1,
        companions = (s['companions'] as List? ?? const []).cast<Map>(),
        routeTitles = companions
            .where((companion) =>
                (bonds[companion['id']] ?? 0) >=
                ((companion['bondThreshold'] as int?) ?? 8))
            .map((companion) => localized(
                companion['routeTitleKey'] as String? ?? '',
                '${companion['routeTitle'] ?? companion['name']}'))
            .toList(),
        routeLine = routeTitles
            .map((title) =>
                title.length > 12 ? '${title.substring(0, 12)}…' : title)
            .join(' · '),
        epilogues =
            (d['epilogues'] as List? ?? const []).cast<Map>().map((epilogue) {
          final text = '${epilogue['text']}';
          return text.length > 10 ? '${text.substring(0, 10)}…' : text;
        }).join(' · '),
        goalCount = milestones.values.where((v) => v).length,
        allMilestones =
            (s['milestones'] as List? ?? const []).cast<Map<String, dynamic>>(),
        missingGoals = allMilestones
            .cast<Map>()
            .where((goal) => milestones[goal['id']] != true)
            .take(2)
            .map((goal) => activeLocale == 'ko'
                ? '${goal['title']}'
                : localized(
                    goal['titleKey'] as String? ?? '', '${goal['title']}'))
            .toList();
    txt(c, '${JsonStoryAdapter(s).campaignWeeks}주의 끝', const Offset(24, 28), 32,
        ink,
        bold: true);
    txt(c, '루멘은 노아가 고른 방향을 기억합니다.', const Offset(25, 70), 14, teal);
    box(c, const Rect.fromLTWH(24, 110, 290, 420), ink,
        radius: 24, shadow: true);
    portrait(c, const Rect.fromLTWH(55, 145, 228, 330), persona);
    txt(c, d['title'], const Offset(365, 145), 26, ink, bold: true);
    txt(c, d['body'], const Offset(365, 200), 16, ink);
    txt(c, '지혜 ${stats['지혜']}   공감 ${stats['공감']}   용기 ${stats['용기']}',
        const Offset(365, 285), 15, teal);
    txt(
        c,
        '은화 $coins · 피로 $fatigue · 목표 $goalCount/${(s['milestones'] as List? ?? const []).length} · 유대 ${bonds.values.reduce((a, b) => a + b)}',
        const Offset(365, 320),
        15,
        ink);
    txt(c, '루멘 기록 등급 · ${List.filled(rank, '★').join()}',
        const Offset(365, 350), 15, teal,
        bold: true);
    if (epilogues.isNotEmpty || d['epilogue'] != null)
      txt(c, epilogues.isEmpty ? '${d['epilogue']}' : epilogues,
          const Offset(365, 378), 11, teal);
    if (companions.isNotEmpty) {
      txt(
          c,
          '${localized('ui.ending.relationshipGoals', '관계 목표')} ${routeTitles.length}/${companions.length}',
          const Offset(55, 488),
          12,
          sun,
          bold: true);
      if (routeTitles.isNotEmpty)
        txt(c, routeLine, const Offset(55, 510), 10, Colors.white70);
    }
    trackerLine(c, const Offset(55, 548), maxWidth: 250);
    drawEndingRetrospective(
        c, history, goalCount, missingGoals, allMilestones, milestones);
    box(c, const Rect.fromLTWH(365, 535, 300, 64), sun,
        radius: 18, shadow: true);
    txt(c, '다시 루멘으로', const Offset(450, 557), 17, ink, bold: true);
    drawLocalizedEnding(c, s, d, rank, history, goalCount, missingGoals,
        allMilestones, milestones);
  }

  @override
  bool shouldRepaint(Scene o) => o.repaintKey != repaintKey;
}
