import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'jsonl.dart';
import 'design_tokens.dart';
import 'canvas_surface.dart';
import 'canvas_scene_fingerprint.dart';
import 'activity_catalog.dart';
import 'activity_forecast.dart';
import 'activity_localization.dart';
import 'activity_journal_painter.dart';
import 'feedback_banner.dart';
import 'i18n.dart';
import 'decision_receipt.dart';
import 'save_state.dart';
import 'save_adapter.dart';
import 'collection_adapter.dart';
import 'collection_platform.dart';
import 'game_core.dart';
import 'character_roster.dart';
import 'character_art_painter.dart';
import 'relationship_archive_painter.dart';
import 'environment_catalog.dart';
import 'canvas_ui_kit.dart';
import 'canvas_choice_impact.dart';
import 'event_art.dart';
import 'legacy_profile_catalog.dart';
import 'companion_scene_archive_painter.dart';
import 'companion_scene_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = decodeJsonl(utf8.decode(
      (await rootBundle.load('story/story.jsonl')).buffer.asUint8List()));
  final locales = <String, Map<String, String>>{};
  for (final locale in ['ko', 'en']) {
    locales[locale] = decodeJsonlCatalog(utf8.decode(
        (await rootBundle.load('story/locales/$locale.jsonl'))
            .buffer
            .asUint8List()));
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
      eventIndex = 0,
      sideSceneCursor = 0,
      companionSceneIndex = 0,
      archiveCharacterIndex = 0,
      archiveEmotionIndex = 0;
  String locale = 'ko';
  bool finished = false;
  String? selectedLegacyId;
  String? pendingCompanionSceneId;
  final history = <String>[];
  final stats = {'지혜': 4, '공감': 5, '용기': 3},
      bonds = {'lumi': 0, 'bora': 0, 'taro': 0};
  final milestones = <String, bool>{}, flags = <String, bool>{};
  final collectionEntries = <Map<String, dynamic>>[];
  String lastResult = '', lastLine = '';
  ui.Image? image, personaImage;
  ui.Image? rosterImage;
  final characterEmotionImages = <String, ui.Image>{};
  final eventIllustrationImages = <String, ui.Image>{};
  final sideSceneIllustrationImages = <String, ui.Image>{};
  bool rosterLoadStarted = false, emotionLoadStarted = false;
  int eventAssetGeneration = 0;
  int sideSceneAssetGeneration = 0;
  late GameSession session;
  late CollectionPort collection;
  LocaleCatalog get catalog => LocaleCatalog(widget.locales);
  void persistUiState() {
    if (session.autoPersist) session.save.write(snapshot().encode());
  }

  void restoreUiState(GameSnapshot value) {
    sideSceneCursor = value.sideSceneCursor;
    companionSceneIndex = value.companionSceneIndex;
    pendingCompanionSceneId = value.pendingCompanionSceneId;
    archiveCharacterIndex = value.archiveCharacterIndex;
    archiveEmotionIndex = value.archiveEmotionIndex;
    selectedLegacyId = value.selectedLegacyId;
    locale = value.locale == 'en' ? 'en' : 'ko';
  }

  String? legacyProfileId() {
    return defaultLegacyProfileId(widget.story, collectionEntries);
  }

  String tr(String key, String fallback) =>
      catalog.text(locale, key, fallback: fallback);
  String formatUi(String key, String fallback, Map<String, Object?> values) {
    var value = tr(key, fallback);
    for (final entry in values.entries)
      value = value.replaceAll('{${entry.key}}', '${entry.value}');
    return value;
  }

  void toggleLocale() => setState(() {
        locale = locale == 'ko' ? 'en' : 'ko';
        setActiveLocale(locale, catalog);
        persistUiState();
      });
  List<Activity> get activities => activitiesFromStory(widget.story);
  List<Map<String, dynamic>> get sideScenes => session.story.sideScenes;
  Map<String, dynamic>? get activeSideScene => sideScenes.isEmpty
      ? null
      : sideScenes[sideSceneCursor.clamp(0, sideScenes.length - 1)];

  void openSideScenes() {
    final firstAvailable = sideScenes.indexWhere((scene) =>
        (scene['unlockWeek'] as int? ?? 1) <= week &&
        flags['side-scene:${scene['id']}'] != true);
    setState(() {
      sideSceneCursor = firstAvailable < 0 ? 0 : firstAvailable;
      page = 9;
      persistUiState();
    });
    loadCurrentSideSceneIllustration();
  }

  void chooseSideScene(int choice) {
    final scene = activeSideScene;
    if (scene == null) return;
    final choices = (scene['choices'] as List).cast<Map<String, dynamic>>();
    if (choice < 0 ||
        choice >= choices.length ||
        !choiceAvailable(choices[choice])) {
      setState(() => lastResult = '조건 부족 · 사이드 장면의 준비 조건을 확인하세요.');
      return;
    }
    setState(() {
      session.chooseSideScene('${scene['id']}', choice);
      sync();
      page = 0;
      persistUiState();
    });
  }

  void openCompanionScenes(int index) => setState(() {
        companionSceneIndex = index.clamp(0, 2);
        pendingCompanionSceneId = null;
        page = 13;
        persistUiState();
      });

  List<Map<String, dynamic>> companionScenesForCurrent() {
    final p = session.world.progress[0]!,
        currentChapter = ((p.week + 2) ~/ 3).clamp(1, 16);
    return resolveCompanionScenes(session.story, p.bonds, p.flags,
            currentChapter: currentChapter)
        .where((scene) =>
            '${scene['companionId']}' ==
            '${session.story.companions[companionSceneIndex]['id']}')
        .toList();
  }

  void chooseCompanionScene(int index, {int choiceIndex = -1}) {
    final scenes = companionScenesForCurrent();
    if (index < 0 || index >= scenes.length) return;
    final scene = scenes[index], sceneId = '${scene['id']}';
    if (scene['available'] == true) {
      setState(() {
        pendingCompanionSceneId = sceneId;
        persistUiState();
      });
      return;
    }
    setState(() {
      session.recordCompanionScene(sceneId, choiceIndex: choiceIndex);
      sync();
      persistUiState();
    });
  }

  void choosePendingCompanionScene(int choiceIndex) {
    final sceneId = pendingCompanionSceneId;
    if (sceneId == null) return;
    setState(() {
      session.recordCompanionScene(sceneId, choiceIndex: choiceIndex);
      pendingCompanionSceneId = null;
      sync();
      persistUiState();
    });
  }

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
      restoreUiState(widget.initialSnapshot!);
    } else {
      try {
        final restored = session.restore();
        if (restored != null) {
          page = restored.page;
          restoreUiState(restored);
        }
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
    if (page == 6 || page == 7) {
      loadRosterImage();
    }
    if (page == 7 || page == 10) {
      loadCharacterEmotionImages();
    }
    if (page == 10) {
      loadRosterImage();
      loadCharacterEmotionImages();
    }
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
    // Keep the next authored event warm on the home/event surface. The Canvas
    // golden contract captures immediately after the transition, while small
    // fixture stories (such as the companion archive tests) may not ship an
    // illustration for their synthetic event.
    if (page == 0 || page == 3) loadCurrentEventIllustration();
    if (page == 9) loadCurrentSideSceneIllustration();
  }

  void loadCurrentEventIllustration() {
    final events = (widget.story['events'] as List? ?? const [])
        .whereType<Map>()
        .map((event) => event.cast<String, dynamic>())
        .toList();
    if (eventIndex < 0 || eventIndex >= events.length) return;
    final asset = eventIllustrationAsset(events[eventIndex]);
    if (eventIllustrationImages.containsKey(asset)) return;
    final generation = ++eventAssetGeneration;
    for (final image in eventIllustrationImages.values) image.dispose();
    eventIllustrationImages.clear();
    rootBundle
        .load(asset)
        .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
        .then((c) => c.getNextFrame())
        .then((f) {
      if (!mounted || generation != eventAssetGeneration) {
        f.image.dispose();
        return;
      }
      setState(() => eventIllustrationImages[asset] = f.image);
    }).catchError((_) {});
  }

  void loadRosterImage() {
    if (rosterImage != null || rosterLoadStarted) return;
    rosterLoadStarted = true;
    rootBundle
        .load('assets/lumen-character-roster.png')
        .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
        .then((c) => c.getNextFrame())
        .then((f) {
      if (!mounted) {
        f.image.dispose();
        return;
      }
      setState(() => rosterImage = f.image);
    });
  }

  void loadCharacterEmotionImages() {
    if (emotionLoadStarted) return;
    emotionLoadStarted = true;
    final emotionAssets =
        (widget.story['characterArchive'] as List? ?? const [])
            .whereType<Map>()
            .map((entry) => entry['emotionAsset'])
            .whereType<String>()
            .toSet();
    for (final asset in emotionAssets) {
      rootBundle
          .load(asset)
          .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
          .then((c) => c.getNextFrame())
          .then((f) {
        if (!mounted) {
          f.image.dispose();
          return;
        }
        setState(() => characterEmotionImages[asset] = f.image);
      });
    }
  }

  void loadCurrentSideSceneIllustration() {
    final scenes = (widget.story['sideScenes'] as List? ?? const [])
        .whereType<Map>()
        .map((scene) => scene.cast<String, dynamic>())
        .toList();
    if (scenes.isEmpty) return;
    final scene = scenes[sideSceneCursor.clamp(0, scenes.length - 1)];
    final asset = sideSceneIllustrationAsset(scene);
    if (sideSceneIllustrationImages.containsKey(asset)) return;
    final generation = ++sideSceneAssetGeneration;
    for (final image in sideSceneIllustrationImages.values) image.dispose();
    sideSceneIllustrationImages.clear();
    rootBundle
        .load(asset)
        .then((b) => ui.instantiateImageCodec(b.buffer.asUint8List()))
        .then((c) => c.getNextFrame())
        .then((f) {
      if (!mounted || generation != sideSceneAssetGeneration) {
        f.image.dispose();
        return;
      }
      setState(() => sideSceneIllustrationImages[asset] = f.image);
    });
  }

  void next() {
    final a = activities[selected.clamp(0, activities.length - 1)];
    final milestoneCount = milestones.length;
    setState(() {
      session.choose(ActivityChosen(a.stat, a.delta, a.coins, a.fatigue,
          label: a.label, activityId: a.id));
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
          loadCurrentEventIllustration();
          page = 3;
        } else if (milestones.length > milestoneCount) {
          page = 6;
        }
      }
      persistUiState();
    });
  }

  void recordEnding() {
    final d = resolveEnding(JsonStoryAdapter(widget.story), stats,
        bonds: bonds, milestones: milestones, flags: flags);
    final routes = (d['epilogues'] as List? ?? const [])
        .map((route) => '${(route as Map)['id']}')
        .toList();
    collection.record('${d['id']}', (d['rank'] as int?) ?? 1, routes: routes);
    collectionEntries
      ..clear()
      ..addAll(collection.read());
    selectedLegacyId = legacyProfileId();
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
      persistUiState();
    });
  }

  GameSnapshot snapshot() {
    final state = session.snapshot(page: page);
    return GameSnapshot(
      week: state.week,
      coins: state.coins,
      fatigue: state.fatigue,
      selected: state.selected,
      persona: state.persona,
      page: state.page,
      eventIndex: state.eventIndex,
      stats: state.stats,
      bonds: state.bonds,
      milestones: state.milestones,
      flags: state.flags,
      lastResult: state.lastResult,
      lastLine: state.lastLine,
      history: state.history,
      sideSceneCursor: sideSceneCursor,
      companionSceneIndex: companionSceneIndex,
      pendingCompanionSceneId: pendingCompanionSceneId,
      archiveCharacterIndex: archiveCharacterIndex,
      archiveEmotionIndex: archiveEmotionIndex,
      locale: locale,
      selectedLegacyId: selectedLegacyId,
      schema: state.schema,
    );
  }

  void restore(GameSnapshot s) {
    setState(() {
      session.restoreSnapshot(s);
      restoreUiState(s);
      page = s.page;
      sync();
    });
  }

  @override
  void dispose() {
    image?.dispose();
    personaImage?.dispose();
    rosterImage?.dispose();
    for (final asset in characterEmotionImages.values) {
      asset.dispose();
    }
    for (final asset in eventIllustrationImages.values) {
      asset.dispose();
    }
    for (final asset in sideSceneIllustrationImages.values) {
      asset.dispose();
    }
    super.dispose();
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
    if (page == 0 && y < 100 && x > 590) {
      toggleLocale();
    } else if (page == 0 && y < 100 && x >= 420) {
      setState(() => page = 12);
    } else if (page == 1) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y >= 620 && x >= 560)
        setState(() => page = 0);
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
      else if (y >= 600 &&
          y < 655 &&
          widget.story['legacySelection'] is Map &&
          unlockedLegacyProfiles(widget.story, collectionEntries).isNotEmpty) {
        final profiles =
            unlockedLegacyProfiles(widget.story, collectionEntries);
        if (widget.story['legacySelection'] is Map && profiles.isNotEmpty) {
          final index = ((x - 24) ~/ 238).clamp(0, profiles.length - 1);
          setState(() {
            selectedLegacyId = '${profiles[index]['id']}';
            persistUiState();
          });
        }
      } else if (y >= 535 && y < 600 && x >= 365 && x < 665)
        restart();
      else if (y > 490 && y < 680) restart();
    } else if (page == 3) {
      if (y < 100 && x > 590)
        toggleLocale();
      else if (y > 260 && y < 470) chooseEvent((x ~/ 380).clamp(0, 1));
    } else if (page == 4) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y > 390 && y < 470 && x < 365) {
        Clipboard.setData(ClipboardData(text: snapshot().encode()));
        persistUiState();
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
          persistUiState();
        });
    } else if (page == 7) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y > 640) {
        setState(() => page = 0);
      } else if (y >= 106 && y < 632 && x >= 20 && x < 740) {
        final col = ((x - 20) ~/ 144).clamp(0, 4),
            row = ((y - 106) ~/ 134).clamp(0, 3),
            index = row * 5 + col,
            characters = archiveCharacters(widget.story);
        if (index < characters.length) {
          setState(() {
            archiveCharacterIndex = index;
            archiveEmotionIndex = 0;
            page = 10;
            persistUiState();
          });
          loadRosterImage();
          loadCharacterEmotionImages();
        }
      }
    } else if (page == 8) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y > 610 && x >= 400 && x < 600) {
        openSideScenes();
      } else if (y > 640) {
        setState(() => page = 0);
      }
    } else if (page == 9) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y > 285 && y < 510) {
        chooseSideScene((x ~/ 253).clamp(0, 2));
      } else if (y > 575 && x < 210) {
        setState(() {
          sideSceneCursor =
              (sideSceneCursor - 1).clamp(0, sideScenes.length - 1);
          persistUiState();
        });
        loadCurrentSideSceneIllustration();
      } else if (y > 575 && x > 550) {
        setState(() {
          sideSceneCursor =
              (sideSceneCursor + 1).clamp(0, sideScenes.length - 1);
          persistUiState();
        });
        loadCurrentSideSceneIllustration();
      } else if (y > 620) {
        setState(() => page = 0);
      }
    } else if (page == 10) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y >= 520 && y < 610 && x >= 316 && x < 716) {
        final index = ((x - 316) ~/ 80).clamp(0, 4);
        setState(() {
          archiveEmotionIndex = index;
          persistUiState();
        });
      } else if (y > 640) {
        setState(() => page = 7);
      }
    } else if (page == 11) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y >= 500 && y < 560 && x >= 20 && x < 740) {
        openCompanionScenes(((x - 24) ~/ 238).clamp(0, 2));
      } else if (y > 640 && x < 220) {
        setState(() => page = 5);
      } else if (y > 640) {
        setState(() => page = 0);
      }
    } else if (page == 12) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (y > 640) {
        setState(() => page = 0);
      }
    } else if (page == 13) {
      if (y < 100 && x > 590) {
        toggleLocale();
      } else if (CompanionSceneLayout.containsInclusive(
          CompanionSceneLayout.backRect, logical)) {
        setState(() {
          pendingCompanionSceneId = null;
          page = 11;
          persistUiState();
        });
      } else if (CompanionSceneLayout.containsInclusive(
          CompanionSceneLayout.previousHitRect, logical)) {
        if (pendingCompanionSceneId != null) {
          setState(() {
            pendingCompanionSceneId = null;
            persistUiState();
          });
        } else {
          setState(() {
            companionSceneIndex = (companionSceneIndex - 1).clamp(0, 2);
            persistUiState();
          });
        }
      } else if (CompanionSceneLayout.containsInclusive(
          CompanionSceneLayout.nextHitRect, logical)) {
        if (pendingCompanionSceneId != null) {
          setState(() {
            pendingCompanionSceneId = null;
            persistUiState();
          });
        } else {
          setState(() {
            companionSceneIndex = (companionSceneIndex + 1).clamp(0, 2);
            persistUiState();
          });
        }
      } else if (pendingCompanionSceneId != null) {
        final scenes = companionScenesForCurrent(),
            pendingIndex = scenes.indexWhere(
                (scene) => '${scene['id']}' == pendingCompanionSceneId);
        final choiceIndex = pendingIndex < 0
            ? null
            : CompanionSceneLayout.choiceIndexAt(logical, pendingIndex);
        if (choiceIndex != null) {
          choosePendingCompanionScene(choiceIndex);
        }
      } else {
        final scenes = companionScenesForCurrent(),
            index = CompanionSceneLayout.cardIndexAt(logical, scenes.length);
        if (index != null) chooseCompanionScene(index);
      }
    } else if (y > 655 && x >= 590) {
      setState(() => page = 11);
    } else if (y > 655 && x >= 200 && x < 410) {
      setState(() => page = 7);
      loadRosterImage();
    } else if (y > 655 && x >= 410 && x < 590) {
      setState(() => page = 8);
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
    final lineage = selectedLegacyId ?? widget.legacyId ?? legacyProfileId();
    setState(() {
      session = GameSession(JsonStoryAdapter(widget.story), createSaveAdapter(),
          legacyUnlocked: lineage != null || collectionEntries.isNotEmpty,
          legacyId: lineage);
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
      selectedLegacyId = null;
    });
  }

  String semanticCanvasLabel() {
    if (page == 13) {
      final scenes = companionScenesForCurrent(),
          person = session.story.companions[companionSceneIndex
              .clamp(0, session.story.companions.length - 1)],
          done = scenes.where((scene) => scene['completed'] == true).length;
      return '${tr('${person['nameKey']}', '${person['name']}')} · ${tr('ui.companionScenes.title', '동행 장면 기록')} · ${formatUi('ui.companionScenes.progress', '기록 {done}/{total}', {'done': done, 'total': scenes.length})}';
    }
    if (page == 3) {
      final event = session.story.events[eventIndex.clamp(
          0, session.story.events.isEmpty ? 0 : session.story.events.length - 1)];
      return '${tr('${event['titleKey']}', '${event['title']}')} · ${tr('ui.event.small', 'A small event · week {week}').replaceAll('{week}', '${event['week']}')}';
    }
    return tr('ui.accessibility.canvas', 'Lumen game screen');
  }

  Rect semanticPhysicalRect(ui.Rect logical, Size viewport) {
    final frame = CanvasViewport.frame(viewport);
    return Rect.fromLTWH(frame.offset.dx + logical.left * frame.scale,
        frame.offset.dy + logical.top * frame.scale,
        logical.width * frame.scale, logical.height * frame.scale);
  }

  Widget semanticButton(Size viewport, ui.Rect logical, String label,
          VoidCallback onTap) =>
      Positioned.fromRect(
          rect: semanticPhysicalRect(logical, viewport),
          child: Semantics(
              button: true,
              label: label,
              onTap: onTap,
              child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: const SizedBox.expand())));

  List<Widget> semanticControls(Size viewport) {
    if (page != 13 || session.story.companions.isEmpty) return const [];
    final controls = <Widget>[], scenes = companionScenesForCurrent();
    controls.add(semanticButton(
        viewport,
        CompanionSceneLayout.previousRect,
        tr('ui.companionScenes.previous', '← 이전 동행'),
        () => setState(() {
              pendingCompanionSceneId = null;
              companionSceneIndex = (companionSceneIndex - 1).clamp(0, 2);
              persistUiState();
            })));
    controls.add(semanticButton(
        viewport,
        CompanionSceneLayout.nextRect,
        tr('ui.companionScenes.next', '다음 동행 →'),
        () => setState(() {
              pendingCompanionSceneId = null;
              companionSceneIndex = (companionSceneIndex + 1).clamp(0, 2);
              persistUiState();
            })));
    controls.add(semanticButton(
        viewport,
        CompanionSceneLayout.backRect,
        tr('ui.companionScenes.back', '← 관계 기록'),
        () => setState(() {
              pendingCompanionSceneId = null;
              page = 11;
              persistUiState();
            })));
    for (var i = 0; i < scenes.length && i < 6; i++) {
      final scene = scenes[i], id = '${scene['id']}';
      if (scene['available'] != true) continue;
      final choices =
          (scene['choices'] as List? ?? const []).cast<Map<String, dynamic>>();
      if (pendingCompanionSceneId == id && choices.length >= 2) {
        for (var choiceIndex = 0; choiceIndex < 2; choiceIndex++) {
          final choice = choices[choiceIndex];
          controls.add(semanticButton(
              viewport,
              CompanionSceneLayout.choiceRect(i, choiceIndex),
              '${tr('${scene['titleKey']}', '${scene['title']}')} · ${tr('${choice['labelKey']}', '${choice['label']}')}',
              () => choosePendingCompanionScene(choiceIndex)));
        }
      } else {
        controls.add(semanticButton(
            viewport,
            CompanionSceneLayout.cardRect(i),
            '${tr('${scene['titleKey']}', '${scene['title']}')} · ${tr('ui.companionScenes.status.available', '기록하기')}',
            () => chooseCompanionScene(i)));
      }
    }
    return controls;
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
                child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: semanticCanvasLabel(),
                    liveRegion: lastResult.isNotEmpty,
                    child: Stack(children: [
                  CustomPaint(
                      key: ValueKey(
                          '$page-$week-$persona-$eventIndex${pendingCompanionSceneId == null ? (lastResult.startsWith('companion-scene-rejected:') ? '-rejected-${lastResult.split(':').last}' : '') : '-pending'}${locale == 'ko' ? '' : '-$locale'}'),
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
                          rosterImage,
                          characterEmotionImages,
                          eventIllustrationImages,
                          sideSceneIllustrationImages,
                          history,
                          eventIndex,
                          sideSceneCursor,
                          archiveCharacterIndex,
                          archiveEmotionIndex,
                          snapshot().encode(),
                          activities,
                          collectionEntries,
                          selectedLegacyId,
                          session.legacyId,
                          companionSceneIndex,
                          pendingCompanionSceneId,
                          locale,
                          widget.locales),
                      size: viewport),
                  if (rosterImage != null)
                    const SizedBox(key: ValueKey('roster-ready')),
                  if (characterEmotionImages.isNotEmpty)
                    const SizedBox(key: ValueKey('character-emotion-ready')),
                  ...semanticControls(viewport),
                ])));
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
      this.rosterImage,
      this.characterEmotionImages,
      this.eventIllustrationImages,
      this.sideSceneIllustrationImages,
      this.history,
      this.eventIndex,
      this.sideSceneCursor,
      this.archiveCharacterIndex,
      this.archiveEmotionIndex,
      this.saveCode,
      this.activities,
      this.collectionEntries,
      this.selectedLegacyId,
      this.legacyId,
      this.companionSceneIndex,
      this.pendingCompanionSceneId,
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
      sideSceneCursor,
      archiveCharacterIndex,
      archiveEmotionIndex,
      stats,
      bonds,
      milestones,
      flags,
      lastResult,
      lastLine,
      image?.hashCode,
      personaImage?.hashCode,
      rosterImage?.hashCode,
      characterEmotionImages.entries
          .map((entry) => [entry.key, entry.value.hashCode])
          .toList(),
      eventIllustrationImages.entries
          .map((entry) => [entry.key, entry.value.hashCode])
          .toList(),
      sideSceneIllustrationImages.entries
          .map((entry) => [entry.key, entry.value.hashCode])
          .toList(),
      history,
      saveCode,
      activities
          .map((a) => [a.label, a.icon, a.stat, a.delta, a.fatigue, a.coins])
          .toList(),
      collectionEntries,
      selectedLegacyId,
      legacyId,
      companionSceneIndex,
      pendingCompanionSceneId,
      locale,
      locales.hashCode,
    ]);
  }
  final Map<String, dynamic> s;
  final int week,
      coins,
      fatigue,
      selected,
      page,
      persona,
      eventIndex,
      sideSceneCursor,
      archiveCharacterIndex,
      archiveEmotionIndex;
  final Map<String, int> stats, bonds;
  final Map<String, bool> milestones, flags;
  final String lastResult, lastLine;
  final ui.Image? image, personaImage, rosterImage;
  final Map<String, ui.Image> characterEmotionImages;
  final Map<String, ui.Image> eventIllustrationImages;
  final Map<String, ui.Image> sideSceneIllustrationImages;
  final List<String> history;
  final String saveCode;
  final List<Activity> activities;
  final List<Map<String, dynamic>> collectionEntries;
  final String? selectedLegacyId;
  final String? legacyId;
  final int companionSceneIndex;
  final String? pendingCompanionSceneId;
  final String locale;
  final Map<String, Map<String, String>> locales;
  late final String repaintKey;
  void txt(Canvas c, String v, Offset p, double z, Color color,
      {bool bold = false, double maxWidth = 330, int? maxLines}) {
    final t = TextPainter(
        text: TextSpan(
            text: v,
            style: TextStyle(
                fontFamily: 'NotoSansKR',
                fontSize: z,
                color: color,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        ellipsis: maxLines == null ? null : '…')
      ..layout(maxWidth: maxWidth);
    t.paint(c, p);
  }

  String formatUi(String key, String fallback, Map<String, Object?> values) {
    var value = localized(key, fallback);
    for (final entry in values.entries)
      value = value.replaceAll('{${entry.key}}', '${entry.value}');
    return value;
  }

  Map<String, dynamic>? legacyProfile() {
    if (legacyId == null) return null;
    final profile = (s['legacyProfiles'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .firstWhere((item) => '${item['id']}' == legacyId,
            orElse: () => <String, dynamic>{});
    return profile.isEmpty ? null : profile;
  }

  String readableHistory(String entry) {
    final head = entry.split('|').first;
    if (head.startsWith('activity:')) {
      final value = head.substring('activity:'.length),
          parts = value.split('+');
      final stat = parts.first, delta = parts.length > 1 ? parts[1] : '0';
      return formatUi('ui.save.activity', 'Activity · {stat} {delta}', {
        'stat': localizedStat(stat),
        'delta':
            delta.startsWith('-') || delta.startsWith('+') ? delta : '+$delta',
      });
    }
    if (head.startsWith('event:')) {
      return formatUi('ui.save.event', 'Event · {label}', {
        'label': localizedHistoryLabel(s, head.substring('event:'.length)),
      });
    }
    if (head.startsWith('side-scene:')) {
      final id = head.substring('side-scene:'.length);
      final scene = (s['sideScenes'] as List? ?? const [])
          .whereType<Map>()
          .cast<Map<String, dynamic>>()
          .firstWhere((item) => '${item['id']}' == id,
              orElse: () => <String, dynamic>{});
      return formatUi('ui.save.sideScene', 'Side scene · {title}', {
        'title': scene.isEmpty
            ? id
            : localized('${scene['titleKey']}', '${scene['title']}'),
      });
    }
    if (head.startsWith('relationship:')) {
      final id = head.substring('relationship:'.length).split('|').first;
      return formatUi('ui.save.relationship', 'Relationship record · {name}', {
        'name': localized('ui.relationship.state.$id', id),
      });
    }
    if (head.startsWith('location:')) {
      final id = head.substring('location:'.length);
      final location = (s['locations'] as List? ?? const [])
          .whereType<Map>()
          .cast<Map<String, dynamic>>()
          .firstWhere((item) => '${item['id']}' == id,
              orElse: () => <String, dynamic>{});
      return formatUi('ui.save.location', 'Location discovered · {name}', {
        'name': location.isEmpty
            ? id
            : localized('${location['nameKey']}', '${location['name']}'),
      });
    }
    return localized('ui.save.record', 'A record was updated.');
  }

  String localizedResult() {
    if (activeLocale == 'ko' || lastResult.isEmpty) return lastResult;
    final activity = localizedActivityResultFromStory(s, lastResult);
    if (activity != lastResult) return activity;
    for (final event in [
      ...(s['events'] as List? ?? const []),
      ...(s['sideScenes'] as List? ?? const []),
    ]) {
      for (final choice in ((event as Map)['choices'] as List? ?? const [])) {
        final item = (choice as Map).cast<String, dynamic>();
        if ('${item['line']}' == lastLine) {
          return '${localized('${item['labelKey']}', '${item['label']}')} · ${localizedChoiceEffect(item)}';
        }
      }
    }
    return localized('ui.home.result', 'The record was updated.');
  }

  String localizedLine() {
    if (activeLocale == 'ko' || lastLine.isEmpty) return lastLine;
    final activity = localizedActivityLineFromStory(s, lastLine);
    if (activity != lastLine) return activity;
    for (final event in [
      ...(s['events'] as List? ?? const []),
      ...(s['sideScenes'] as List? ?? const []),
    ]) {
      for (final choice in ((event as Map)['choices'] as List? ?? const [])) {
        final item = (choice as Map).cast<String, dynamic>();
        if ('${item['line']}' == lastLine)
          return localized('${item['lineKey']}', lastLine);
      }
    }
    return lastLine;
  }

  void box(Canvas c, Rect r, Color color,
      {double radius = DesignTokens.radiusCard,
      Color? stroke,
      bool shadow = false}) {
    CanvasUiKit.panel(c, r,
        fill: color, stroke: stroke, radius: radius, shadow: shadow);
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
    CanvasUiKit.panel(
        c,
        Rect.fromLTWH(
            x, 157, DesignTokens.statPillWidth, DesignTokens.statPillHeight),
        fill: Colors.white.withValues(alpha: .08),
        radius: DesignTokens.radiusBadge);
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

  Map<String, dynamic> get relationshipState =>
      resolveRelationshipDynamics(storyModel, bonds, flags);

  Map<String, dynamic> get relationshipFollowup =>
      resolveRelationshipFollowup(storyModel, relationshipState);

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
        .take(6)
        .toList();
    txt(c, activeLocale == 'ko' ? '발견 경로' : 'Route atlas', origin, 10, teal,
        bold: true);
    final startX = origin.dx + 18.0, step = 170.0;
    for (var i = 0; i < locations.length; i++) {
      final location = locations[i],
          row = i ~/ 3,
          col = i % 3,
          x = startX + col * step,
          nodeY = origin.dy + 28 + row * 34,
          found = flags['place:${location['id']}'] == true,
          color = found ? teal : ink.withValues(alpha: .18);
      if (col < 2 && i < locations.length - 1) {
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

  void dialoguePortrait(Canvas c, Rect d, Map choice) {
    final sheet = personaImage, n = speakerPortraitFrame(s, choice);
    if (sheet != null) {
      final w = sheet.width / 3.0;
      c.drawImageRect(
          sheet, Rect.fromLTWH(n * w, 0, w, sheet.height * .9), d, Paint());
    } else {
      chibi(c, d, n);
    }
    txt(c, localizedSpeaker(s, choice), Offset(d.left, d.bottom + 4), 9, teal,
        bold: true, maxWidth: d.width);
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
      event(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 4) {
      savePage(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
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
    if (page == 7) {
      characterArchive(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 8) {
      environmentArchive(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 9) {
      sideScene(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 10) {
      characterArt(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 11) {
      relationshipArchive(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 12) {
      final scenes = (s['activityScenes'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
      ActivityJournalPainter(scenes, history, localized).paint(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    if (page == 13) {
      CompanionSceneArchivePainter(
        story: s,
        bonds: bonds,
        flags: flags,
        portraitSheet: personaImage,
        persona: persona,
        companionIndex: companionSceneIndex,
        pendingSceneId: pendingCompanionSceneId,
        lastResult: lastResult,
        lastLine: lastLine,
        currentChapter: ((week + 2) ~/ 3).clamp(1, 16),
      ).paint(c);
      drawLocaleToggle(c, activeLocale, activeCatalog);
      c.restore();
      return;
    }
    home(c);
    drawLocaleToggle(c, activeLocale, activeCatalog);
    drawFeedbackBanner(c, localizedResult(), localizedLine(),
        emptyLabel: localized(
            'ui.home.prompt', 'Choose an activity to spend the day.'));
    seasonProgress(c);
    c.restore();
  }

  void characterArt(Canvas c) => CharacterArtPainter(
        story: s,
        sheet: rosterImage,
        emotionSheets: characterEmotionImages,
        characterIndex: archiveCharacterIndex,
        emotionIndex: archiveEmotionIndex,
        locale: activeLocale,
      ).paint(c);

  void relationshipArchive(Canvas c) => RelationshipArchivePainter(
        story: s,
        bonds: bonds,
        flags: flags,
        portraitSheet: personaImage,
        persona: persona,
        locale: activeLocale,
      ).paint(c);

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
            : formatUi(
                'ui.home.chapter', '{chapter} · {week}/{total} · {persona}', {
                'chapter': chapterIndex + 1,
                'week': week,
                'total': campaignWeeks,
                'persona': localized('personality.${person?['id']}.name',
                    '${person?['name'] ?? ''}'),
              });
    txt(c, chapterTitle, const Offset(24, 228), 10, teal, bold: true);
    CanvasUiKit.progress(c, const Rect.fromLTWH(155, 231, 555, 5), progress);
  }

  void home(Canvas c) {
    final condition = fatigue >= 10
            ? localized('ui.home.condition.strained', 'Do not push today')
            : fatigue >= 8
                ? localized('ui.home.condition.tired', 'A little tired')
                : localized('ui.home.condition.clear', 'A clear mind'),
        rawGoals = (s['milestones'] as List? ?? const []),
        pending = rawGoals
            .where((g) => !milestones.containsKey(g['id']) && g['week'] >= week)
            .toList(),
        goal = pending.isEmpty ? null : pending.first,
        people = (s['personalities'] as List? ?? const []),
        talent =
            people.isEmpty ? null : people[persona.clamp(0, people.length - 1)],
        relation = relationshipState,
        lineage = legacyProfile();
    txt(c, localized('ui.home.title', '${s['title']}'), const Offset(24, 24),
        30, ink,
        bold: true);
    box(c, const Rect.fromLTWH(420, 24, 160, 40), Colors.white,
        radius: 14, stroke: teal);
    txt(c, localized('ui.home.journal', 'Reflection journal'),
        const Offset(442, 37), 11, teal,
        bold: true, maxWidth: 132);
    txt(c, localized('ui.home.setting', '${s['setting']}'),
        const Offset(25, 65), 14, teal);
    box(c, const Rect.fromLTWH(24, 105, 712, 120), ink,
        radius: 22, shadow: true);
    box(c, const Rect.fromLTWH(44, 125, 76, 76), sun, radius: 18);
    portrait(c, const Rect.fromLTWH(45, 122, 74, 80), persona);
    if (lineage != null)
      txt(
          c,
          formatUi('ui.home.legacy', 'Inherited · {title} · {stat} +{bonus}', {
            'title': localized('${lineage['titleKey']}',
                '${lineage['title'] ?? lineage['id']}'),
            'stat': localizedStat('${lineage['stat']}'),
            'bonus': lineage['bonus'] ?? 0,
          }),
          const Offset(140, 109),
          9,
          sun,
          bold: true,
          maxWidth: 560,
          maxLines: 1);
    txt(
        c,
        formatUi('ui.home.week', '{hero} · week {week}', {
          'hero': localized('hero.name', '${s['hero']}'),
          'week': week,
        }),
        const Offset(140, 128),
        20,
        Colors.white,
        bold: true);
    statPill(c, localizedStat('지혜'), stats['지혜'] ?? 0, 140, sun);
    statPill(
        c, localizedStat('공감'), stats['공감'] ?? 0, 252, const Color(0xff9fe0c9));
    statPill(
        c, localizedStat('용기'), stats['용기'] ?? 0, 364, const Color(0xffff9a7a));
    txt(
        c,
        formatUi('ui.home.status',
            'Coins {coins} · Fatigue {fatigue}/12 · {condition}', {
          'coins': coins,
          'fatigue': fatigue,
          'condition': condition,
        }),
        const Offset(140, 190),
        14,
        fatigue > 9 ? const Color(0xffff8b6b) : sun,
        maxWidth: 560);
    txt(
        c,
        formatUi('ui.home.bonds',
            'Bonds · Lumi {lumi} · Bora {bora} · Taro {taro} · {state}', {
          'lumi': bonds['lumi'] ?? 0,
          'bora': bonds['bora'] ?? 0,
          'taro': bonds['taro'] ?? 0,
          'state': localized('${relation['key']}', '${relation['fallback']}'),
        }),
        const Offset(140, 208),
        10,
        Colors.white70,
        maxWidth: 570);
    txt(
        c,
        goal == null
            ? localized(
                rawGoals.isEmpty
                    ? 'ui.home.goal.free'
                    : 'ui.home.goal.complete',
                rawGoals.isEmpty
                    ? 'Begin this run without a seasonal goal.'
                    : 'Every seasonal goal has been recorded.')
            : formatUi('ui.home.goal.next',
                'Next goal · {title} · {stat} {value}/{min}', {
                'title': localized('${goal['titleKey']}', '${goal['title']}'),
                'stat': localizedStat('${goal['stat']}'),
                'value': stats[goal['stat']],
                'min': goal['min'],
              }),
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
              ? ' · ${formatUi('ui.home.talent', 'Talent +{bonus}', {
                      'bonus': talent['focusBonus']
                    })}'
              : '',
          label = localizedActivityLabel(a.id, a.label),
          hint = '${localizedActivityHint(a.id, a.hint)}$bonus',
          forecast = forecastActivity(a,
              week: week,
              fatigue: fatigue,
              coins: coins,
              focusStat: talent?['focusStat'] as String?,
              focusBonus: (talent?['focusBonus'] as int?) ?? 0,
              events: (s['events'] as List? ?? const [])
                  .whereType<Map>()
                  .map((event) => event.cast<String, dynamic>())
                  .toList(),
              milestones: (s['milestones'] as List? ?? const [])
                  .whereType<Map>()
                  .map((goal) => goal.cast<String, dynamic>())
                  .toList()),
          forecastText = localizedActivityForecast(forecast);
      CanvasUiKit.statePanel(
          c,
          Rect.fromLTWH(x, y, DesignTokens.activityCardWidth,
              DesignTokens.activityCardHeight),
          state: on ? CanvasUiState.selected : CanvasUiState.idle,
          shadow: true);
      c.drawCircle(Offset(x + 34, y + 40), 24,
          Paint()..color = on ? Colors.white.withValues(alpha: .16) : paper);
      mark(c, a.icon, Offset(x + 16, y + 22), on ? Colors.white : teal);
      txt(c, label, Offset(x + 52, y + 12), 14, on ? Colors.white : ink,
          bold: true, maxWidth: 160, maxLines: 1);
      txt(c, hint, Offset(x + 52, y + 40), 9,
          on ? Colors.white70 : ink.withValues(alpha: .55));
      txt(c, forecastText, Offset(x + 52, y + 62), 8,
          on ? Colors.white70 : teal,
          maxWidth: 160, maxLines: 1);
    }
    box(c, const Rect.fromLTWH(260, 500, 150, 54), Colors.white,
        radius: 15, stroke: teal, shadow: true);
    txt(c, localized('ui.home.save', 'Save / restore'), const Offset(282, 517),
        14, teal,
        bold: true);
    box(c, const Rect.fromLTWH(430, 500, 150, 54), Colors.white,
        radius: 15, stroke: teal, shadow: true);
    txt(c, localized('ui.home.illustration', 'Illustration'),
        const Offset(458, 517), 16, teal,
        bold: true);
    CanvasUiKit.button(c, const Rect.fromLTWH(590, 500, 146, 54),
        localized('ui.home.spend', 'Spend the day →'),
        state: CanvasUiState.selected,
        fontSize: activeLocale == 'ko' ? 14 : 12);
    trackerLine(c, const Offset(24, 565));
    routeAtlas(c, origin: const Offset(24, 580));
    box(c, const Rect.fromLTWH(24, 660, 170, 30), Colors.white,
        radius: 12, stroke: teal);
    txt(c, localized('ui.home.ledger', 'Fate ledger'), const Offset(62, 668),
        12, teal,
        bold: true);
    box(c, const Rect.fromLTWH(210, 660, 180, 30), Colors.white,
        radius: 12, stroke: teal);
    txt(c, localized('ui.home.characters', 'Character archive'),
        const Offset(238, 668), 12, teal,
        bold: true, maxWidth: 130);
    box(c, const Rect.fromLTWH(410, 660, 180, 30), Colors.white,
        radius: 12, stroke: teal);
    txt(c, localized('ui.home.environments', 'Environment atlas'),
        const Offset(438, 668), 12, teal,
        bold: true, maxWidth: 130);
    box(c, const Rect.fromLTWH(608, 660, 128, 30), Colors.white,
        radius: 12, stroke: teal);
    txt(c, localized('ui.home.bondsButton', 'Bonds'), const Offset(624, 668),
        11, teal,
        bold: true, maxWidth: 98);
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

  void characterArchive(Canvas c) {
    final characters = archiveCharacters(s);
    txt(c, activeLocale == 'ko' ? '루멘 캐릭터 도감' : 'Lumen character archive',
        const Offset(24, 22), 28, ink,
        bold: true, maxWidth: 520);
    txt(
        c,
        activeLocale == 'ko'
            ? '서로 다른 하루를 살아가는 20명의 루멘 주민'
            : 'Twenty Lumen residents, each carrying a different kind of day',
        const Offset(25, 60),
        13,
        teal,
        maxWidth: 540);
    txt(c, '${characters.length} / 20 · twilight / mist / sun / paper',
        const Offset(25, 84), 10, ink.withValues(alpha: .55),
        bold: true);

    final sheet = rosterImage,
        sourceWidth = sheet == null ? 1.0 : sheet.width / 5.0,
        sourceHeight = sheet == null ? 1.0 : sheet.height / 4.0;
    for (var i = 0; i < characters.length; i++) {
      final character = characters[i],
          col = i % 5,
          row = i ~/ 5,
          x = 20.0 + col * 144.0,
          y = 106.0 + row * 134.0,
          accent = Color(character.accent),
          card = Rect.fromLTWH(x, y, 136, 126);
      box(c, card, Colors.white,
          radius: 16, stroke: accent.withValues(alpha: .52), shadow: true);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 10, y + 6, 116, 3), const Radius.circular(2)),
          Paint()..color = accent);
      if (sheet != null) {
        final source = Rect.fromLTWH(
            (character.sheetIndex % 5) * sourceWidth,
            (character.sheetIndex ~/ 5) * sourceHeight,
            sourceWidth,
            sourceHeight);
        c.drawImageRect(
            sheet, source, Rect.fromLTWH(x + 10, y + 9, 116, 88), Paint());
      } else {
        chibi(c, Rect.fromLTWH(x + 28, y + 15, 80, 76), i % 3);
      }
      txt(c, character.title(activeLocale), Offset(x + 12, y + 98), 11, ink,
          bold: true, maxWidth: 112);
      txt(c, character.subtitle(activeLocale), Offset(x + 12, y + 113), 8.5,
          accent,
          bold: true, maxWidth: 112);
    }
    txt(c, activeLocale == 'ko' ? '← 홈으로' : '← Back to home',
        const Offset(24, 665), 13, teal,
        bold: true);
  }

  void environmentSurface(Canvas c, Rect rect, LumenEnvironment environment) {
    c.save();
    c.clipRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    c.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topLeft, rect.bottomRight, [
            environment.primary,
            environment.secondary.withValues(alpha: .72)
          ]));
    final horizon = rect.top + rect.height * .68,
        inkPaint = Paint()..color = ink.withValues(alpha: .78),
        pale = Paint()..color = paper.withValues(alpha: .82);
    if (environment.id == 'archive') {
      c.drawCircle(Offset(rect.right - 42, rect.top + 30), 20, pale);
      for (final star in [
        Offset(rect.left + 42, rect.top + 27),
        Offset(rect.left + 86, rect.top + 49),
        Offset(rect.right - 92, rect.top + 22),
      ]) {
        c.drawCircle(star, 3, Paint()..color = sun);
      }
      for (var i = 0; i < 4; i++) {
        final y = horizon - i * 13.0;
        c.drawLine(
            Offset(rect.left + 24, y),
            Offset(rect.right - 22, y),
            Paint()
              ..color = paper.withValues(alpha: .55)
              ..strokeWidth = 3);
      }
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left + 54, horizon - 44, 72, 44),
              const Radius.circular(6)),
          Paint()..color = ink.withValues(alpha: .32));
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(rect.left + 142, horizon - 31, 58, 31),
              const Radius.circular(5)),
          Paint()..color = ink.withValues(alpha: .26));
    } else if (environment.id == 'greenhouse') {
      final glass = Paint()
        ..color = paper.withValues(alpha: .54)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      final house = Path()
        ..moveTo(rect.left + 44, horizon)
        ..lineTo(rect.left + 64, rect.top + 31)
        ..lineTo(rect.right - 60, rect.top + 31)
        ..lineTo(rect.right - 40, horizon)
        ..close();
      c.drawPath(house, glass);
      c.drawLine(Offset(rect.center.dx, rect.top + 31),
          Offset(rect.center.dx, horizon), glass);
      for (final x in [rect.left + 90, rect.left + 150, rect.left + 216]) {
        c.drawLine(Offset(x, horizon), Offset(x, horizon - 30), glass);
        c.drawCircle(Offset(x - 7, horizon - 30), 8,
            Paint()..color = const Color(0xffd7efb4).withValues(alpha: .8));
        c.drawCircle(Offset(x + 7, horizon - 24), 7,
            Paint()..color = const Color(0xffc0df9f).withValues(alpha: .8));
      }
      c.drawLine(Offset(rect.left + 28, horizon + 2),
          Offset(rect.right - 24, horizon + 2), inkPaint);
    } else if (environment.id == 'market') {
      final awning = Paint()..color = paper.withValues(alpha: .78);
      for (var i = 0; i < 4; i++) {
        c.drawRect(
            Rect.fromLTWH(rect.left + 18 + i * 64, rect.top + 30, 54, 18),
            Paint()..color = i.isEven ? awning.color : environment.primary);
      }
      for (final x in [rect.left + 44, rect.left + 146, rect.left + 250]) {
        c.drawLine(Offset(x, rect.top + 48), Offset(x, horizon), inkPaint);
        c.drawCircle(Offset(x, rect.top + 22), 9,
            Paint()..color = sun.withValues(alpha: .9));
      }
      c.drawRect(Rect.fromLTWH(rect.left + 30, horizon, rect.width - 60, 8),
          Paint()..color = ink.withValues(alpha: .3));
      for (final x in [rect.left + 90, rect.left + 170, rect.left + 238]) {
        c.drawCircle(Offset(x, horizon + 24), 10,
            Paint()..color = sun.withValues(alpha: .9));
        c.drawCircle(
            Offset(x, horizon + 24),
            10,
            Paint()
              ..color = ink.withValues(alpha: .34)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      }
    } else if (environment.id == 'observatory') {
      final telescope = Paint()
        ..color = paper.withValues(alpha: .82)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5;
      c.drawCircle(Offset(rect.center.dx, horizon - 12), 18, telescope);
      c.drawLine(Offset(rect.center.dx - 12, horizon - 24),
          Offset(rect.center.dx + 42, rect.top + 22), telescope);
      c.drawLine(Offset(rect.center.dx + 12, horizon + 2),
          Offset(rect.center.dx - 24, rect.bottom - 6), telescope);
      c.drawLine(Offset(rect.center.dx + 12, horizon + 2),
          Offset(rect.center.dx + 42, rect.bottom - 6), telescope);
      for (final star in [
        Offset(rect.left + 42, rect.top + 20),
        Offset(rect.right - 54, rect.top + 18),
        Offset(rect.right - 94, rect.top + 42),
      ]) {
        c.drawCircle(star, 3, Paint()..color = sun);
      }
      c.drawLine(Offset(rect.left + 20, rect.bottom - 12),
          Offset(rect.right - 20, rect.bottom - 12), telescope);
    } else if (environment.id == 'quarry') {
      final rock = Paint()..color = paper.withValues(alpha: .58);
      for (var i = 0; i < 4; i++) {
        final x = rect.left + 36.0 + i * 78;
        c.drawPath(
          Path()
            ..moveTo(x - 26, rect.bottom - 10)
            ..lineTo(x - 18, horizon - 16 - (i.isEven ? 5 : 0))
            ..lineTo(x + 10, horizon - 28)
            ..lineTo(x + 30, rect.bottom - 10)
            ..close(),
          rock,
        );
      }
      final pick = Paint()
        ..color = ink.withValues(alpha: .72)
        ..strokeWidth = 5;
      c.drawLine(Offset(rect.right - 86, rect.top + 18),
          Offset(rect.right - 38, rect.bottom - 10), pick);
      c.drawLine(Offset(rect.right - 101, rect.top + 30),
          Offset(rect.right - 70, rect.top + 12), pick);
    } else {
      final water = Paint()
        ..color = const Color(0xffb9d5db).withValues(alpha: .65)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke;
      for (var i = 0; i < 3; i++) {
        final path = Path()..moveTo(rect.left, horizon + 16 + i * 15);
        for (var x = rect.left; x < rect.right; x += 32) {
          path.quadraticBezierTo(
              x + 8, horizon + 8 + i * 15, x + 16, horizon + 16 + i * 15);
        }
        c.drawPath(path, water);
      }
      final bridge = Paint()
        ..color = ink.withValues(alpha: .62)
        ..strokeWidth = 7;
      c.drawLine(Offset(rect.left + 30, horizon - 20),
          Offset(rect.right - 32, horizon - 20), bridge);
      for (final x in [
        rect.left + 64,
        rect.left + 132,
        rect.left + 202,
        rect.right - 68
      ]) {
        c.drawLine(Offset(x, horizon - 20), Offset(x, horizon + 5), bridge);
      }
      c.drawLine(
          Offset(rect.right - 58, rect.top + 24),
          Offset(rect.right - 40, rect.top + 48),
          Paint()
            ..color = sun.withValues(alpha: .8)
            ..strokeWidth = 3);
      c.drawCircle(
          Offset(rect.right - 58, rect.top + 24), 5, Paint()..color = sun);
    }
    c.restore();
  }

  void environmentArchive(Canvas c) {
    final environments = environmentsFromStory(s);
    txt(c, activeLocale == 'ko' ? '루멘 환경 아틀라스' : 'Lumen environment atlas',
        const Offset(24, 22), 28, ink,
        bold: true, maxWidth: 560);
    txt(
        c,
        activeLocale == 'ko'
            ? '장소는 배경이 아니라, 선택이 작동하는 방식입니다.'
            : 'A place is not a backdrop; it is how a choice works.',
        const Offset(25, 60),
        13,
        teal,
        maxWidth: 570);
    txt(
        c,
        localized('ui.environment.summary',
            '6 places · choices, rewards, and memories connect'),
        const Offset(25, 84),
        10,
        ink.withValues(alpha: .55),
        bold: true);

    for (var i = 0; i < environments.length && i < 6; i++) {
      final environment = environments[i],
          col = i % 2,
          row = i ~/ 2,
          x = 24.0 + col * 356.0,
          y = 106.0 + row * 188.0,
          card = Rect.fromLTWH(x, y, DesignTokens.environmentCardWidth,
              DesignTokens.environmentCardHeight),
          title = localized(environment.nameKey, environment.name);
      box(c, card, Colors.white,
          radius: 20,
          stroke: environment.primary.withValues(alpha: .5),
          shadow: true);
      environmentSurface(
          c,
          Rect.fromLTWH(x + 16, y + 16, DesignTokens.environmentCardWidth - 32,
              DesignTokens.environmentSurfaceHeight),
          environment);
      txt(c, title, Offset(x + 18, y + 82), 14, ink, bold: true, maxWidth: 292);
      txt(c, environment.kindLabel(activeLocale), Offset(x + 18, y + 101), 8.5,
          environment.primary,
          bold: true, maxWidth: 292);
      txt(c, environment.motifLabel(activeLocale), Offset(x + 18, y + 116), 7.5,
          ink.withValues(alpha: .58),
          maxWidth: 292);
      txt(c, environment.affordanceLabel(activeLocale), Offset(x + 18, y + 131),
          8.5, ink,
          bold: true, maxWidth: 292);
      box(c, Rect.fromLTWH(x + 18, y + 148, 178, 16),
          environment.primary.withValues(alpha: .12),
          radius: 9);
      txt(
          c,
          '${environment.statLabel(activeLocale)} · ${environment.activityLabel(activeLocale)}',
          Offset(x + 26, y + 151),
          7,
          environment.primary,
          bold: true,
          maxWidth: 160);
    }
    box(c, const Rect.fromLTWH(430, 610, 220, 38), Colors.white,
        radius: 14, stroke: teal, shadow: true);
    txt(c, activeLocale == 'ko' ? '사이드 장면 열기 →' : 'Open side scenes →',
        const Offset(470, 621), 12, teal,
        bold: true, maxWidth: 160);
    txt(c, activeLocale == 'ko' ? '← 홈으로' : '← Back to home',
        const Offset(24, 665), 13, teal,
        bold: true);
  }

  void sideScene(Canvas c) {
    final scenes =
            (s['sideScenes'] as List? ?? const []).cast<Map<String, dynamic>>(),
        scene = scenes.isEmpty
            ? <String, dynamic>{}
            : scenes[sideSceneCursor.clamp(0, scenes.length - 1)],
        choices = (scene['choices'] as List? ?? const [])
            .cast<Map<String, dynamic>>(),
        locations =
            (s['locations'] as List? ?? const []).cast<Map<String, dynamic>>(),
        location = locations.firstWhere(
            (item) => item['id'] == scene['locationId'],
            orElse: () => {'name': scene['locationId']}),
        requirements =
            (scene['requiresCompanions'] as List? ?? const []).cast<String>(),
        companionReady = requirements.every((id) => (bonds[id] ?? 0) > 0),
        completed = flags['side-scene:${scene['id']}'] == true,
        unlocked = scene.isNotEmpty &&
            (scene['unlockWeek'] as int? ?? 1) <= week &&
            companionReady &&
            !completed;
    txt(c, localized('ui.sideScene.title', 'Side scene archive'),
        const Offset(24, 22), 28, ink,
        bold: true, maxWidth: 540);
    txt(c, localized('ui.sideScene.subtitle', 'Side scenes leave traces.'),
        const Offset(25, 60), 12, teal,
        maxWidth: 670);
    if (scene.isEmpty) {
      txt(c, localized('ui.sideScene.empty', 'No side scenes yet.'),
          const Offset(48, 180), 18, ink,
          bold: true);
      return;
    }
    final title = localized('${scene['titleKey']}', '${scene['title']}'),
        body = localized('${scene['bodyKey']}', '${scene['body']}'),
        prompt = localized('${scene['promptKey']}', '${scene['prompt']}'),
        consequence =
            localized('${scene['consequenceKey']}', '${scene['consequence']}'),
        locationName =
            localized('${location['nameKey']}', '${location['name']}'),
        typeName = localized(
            'ui.sideScene.type.${scene['sceneType']}', '${scene['sceneType']}'),
        mechanicName = localized('ui.sideScene.mechanic.${scene['mechanic']}',
            '${scene['mechanic']}'),
        state = completed
            ? localized('ui.sideScene.status.completed', 'COMPLETED')
            : unlocked
                ? localized('ui.sideScene.status.available', 'AVAILABLE')
                : localized('ui.sideScene.status.locked', 'LOCKED'),
        sideAsset = sideSceneIllustrationAsset(scene),
        sideImage = sideSceneIllustrationImages[sideAsset],
        choiceTop = sideImage == null ? 275.0 : 298.0;
    txt(c, '$locationName · $typeName · $mechanicName · $state',
        const Offset(25, 88), 10, unlocked ? teal : ink.withValues(alpha: .45),
        bold: true, maxWidth: 710);
    if (sideImage == null) {
      txt(c, title, const Offset(25, 112), 20, ink, bold: true, maxWidth: 650);
      box(c, const Rect.fromLTWH(24, 145, 712, 94), ink, radius: 20);
      txt(c, body, const Offset(46, 166), 15, Colors.white,
          bold: true, maxWidth: 665, maxLines: 2);
      txt(c, '$prompt · $consequence', const Offset(25, 248), 10,
          ink.withValues(alpha: .6),
          maxWidth: 700, maxLines: 1);
    } else {
      drawSideSceneIllustration(
          c, sideImage, const Rect.fromLTWH(24, 108, 330, 165),
          frame: sideSceneIllustrationFrame(scene));
      box(c, const Rect.fromLTWH(366, 108, 370, 165), ink, radius: 20);
      txt(c, title, const Offset(386, 124), 18, Colors.white,
          bold: true, maxWidth: 330, maxLines: 2);
      txt(c, body, const Offset(386, 167), 13, Colors.white,
          bold: true, maxWidth: 330, maxLines: 3);
      txt(c, '$prompt · $consequence', const Offset(386, 235), 9,
          const Color(0xffc6e3d9),
          maxWidth: 330, maxLines: 2);
    }
    for (var i = 0; i < choices.length && i < 3; i++) {
      final choice = choices[i],
          req = choice['requiresStat'] as String?,
          min = choice['requiresMin'] as int? ?? 0,
          bondReq = choice['requiresBondId'] as String?,
          bondMin = choice['requiresBondMin'] as int? ?? 0,
          flagReq = choice['requiresFlag'] as String?,
          locked = completed ||
              !unlocked ||
              (req != null && (stats[req] ?? 0) < min) ||
              (bondReq != null && (bonds[bondReq] ?? 0) < bondMin) ||
              (flagReq != null && flags[flagReq] != true),
          x = 24 + i * 242.0;
      CanvasUiKit.statePanel(c, Rect.fromLTWH(x, choiceTop, 226, 228),
          state: locked ? CanvasUiState.disabled : CanvasUiState.idle,
          shadow: !locked);
      txt(c, '${i + 1}', Offset(x + 18, choiceTop + 17), 12,
          locked ? ink.withValues(alpha: .35) : teal,
          bold: true);
      txt(
          c,
          localized('${choice['labelKey']}', '${choice['label']}'),
          Offset(x + 18, choiceTop + 45),
          13,
          locked ? ink.withValues(alpha: .42) : ink,
          bold: true,
          maxWidth: 188,
          maxLines: 2);
      final lockLabel = completed
          ? localized('ui.sideScene.lock.completed', 'Already complete')
          : requirements.isNotEmpty && !companionReady
              ? localized(
                  'ui.sideScene.lock.companion', 'Companion bond needed')
              : flagReq != null
                  ? localized('ui.sideScene.lock.memory', 'Memory clue needed')
                  : req != null
                      ? formatUi(
                          'ui.sideScene.lock.stat',
                          '{stat} {min} needed',
                          {'stat': localizedStat(req), 'min': min})
                      : localized('ui.sideScene.lock.generic', 'Locked');
      txt(
          c,
          locked ? lockLabel : localizedChoiceEffect(choice),
          Offset(x + 18, choiceTop + 130),
          10,
          locked ? ink.withValues(alpha: .4) : teal,
          maxWidth: 185,
          maxLines: 2);
      txt(
          c,
          localized('${choice['lineKey']}', '${choice['line']}'),
          Offset(x + 18, choiceTop + 163),
          9,
          locked ? ink.withValues(alpha: .35) : ink,
          maxWidth: 185,
          maxLines: 3);
    }
    box(c, const Rect.fromLTWH(24, 570, 180, 42), Colors.white,
        radius: 14, stroke: teal);
    txt(c, localized('ui.sideScene.previous', '← Previous scene'),
        const Offset(62, 584), 12, teal,
        bold: true);
    txt(c, '${sideSceneCursor + 1}/${scenes.length}', const Offset(350, 584),
        12, teal,
        bold: true);
    box(c, const Rect.fromLTWH(550, 570, 186, 42), Colors.white,
        radius: 14, stroke: teal);
    txt(c, localized('ui.sideScene.next', 'Next scene →'),
        const Offset(594, 584), 12, teal,
        bold: true);
    txt(c, localized('ui.sideScene.back', '← Back to home'),
        const Offset(24, 665), 13, teal,
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
            '${passed ? goal['pass'] : goal['fail']}'),
        scene = (chapter['relationshipScene'] as Map? ?? const {}).cast(),
        relation = relationshipState,
        followup = relationshipFollowup;
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
    txt(
        c,
        '${localizedStat('${goal['stat']}')} ${stats[goal['stat']] ?? 0}/${goal['min']}',
        const Offset(365, 338),
        14,
        passed ? teal : const Color(0xffa84f3c),
        bold: true);
    trackerLine(c, const Offset(340, 405), maxWidth: 360);
    txt(c, activeLocale == 'ko' ? lastResult : localizedResult(),
        const Offset(340, 440), 11, ink.withValues(alpha: .6),
        maxWidth: 360);
    box(c, const Rect.fromLTWH(340, 510, 360, 64), teal,
        radius: 18, shadow: true);
    txt(c, localized('ui.closure.nextPage', '다음 장으로 →'), const Offset(445, 531),
        17, Colors.white,
        bold: true);
    txt(c, localized('ui.closure.link', '결과는 시스템 영수증과 다음 선택에 연결됩니다.'),
        const Offset(340, 686), 10, teal,
        maxWidth: 360);
    if (scene.isNotEmpty) {
      txt(
          c,
          '${localized('ui.closure.scene', '동행의 한마디')} · ${localized('${relation['key']}', '${relation['fallback']}')}',
          const Offset(340, 590),
          10,
          teal,
          bold: true,
          maxWidth: 360);
      box(c, const Rect.fromLTWH(340, 606, 360, 72), Colors.white,
          radius: 14, stroke: teal, shadow: true);
      dialoguePortrait(c, const Rect.fromLTWH(350, 612, 44, 52), scene);
      txt(c, localized('${scene['titleKey']}', '${scene['title']}'),
          const Offset(410, 612), 10, ink,
          bold: true, maxWidth: 270);
      txt(c, localized('${scene['lineKey']}', '${scene['line']}'),
          const Offset(410, 633), 9, ink.withValues(alpha: .65),
          maxWidth: 270);
      if (followup.isNotEmpty) {
        txt(
            c,
            '${localized('ui.relationship.followup', '상태별 후속 기록')} · ${localized('${followup['titleKey']}', '${followup['title']}')}',
            const Offset(410, 650),
            8,
            teal,
            bold: true,
            maxWidth: 270);
        txt(c, localized('${followup['lineKey']}', '${followup['line']}'),
            const Offset(410, 662), 8, ink.withValues(alpha: .6),
            maxWidth: 270);
      }
    }
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
    final eventAsset = eventIllustrationAsset(e);
    final eventImage = eventIllustrationImages[eventAsset];
    final locations = (s['locations'] as List? ?? const []).cast<Map>(),
        location = locations.firstWhere((l) => l['id'] == e['locationId'],
            orElse: () => {'name': e['locationId'] ?? ''}),
        locationName = activeLocale == 'ko'
            ? '${location['name']}'
            : localized('${location['nameKey']}', '${location['name']}');
    txt(
        c,
        formatUi('ui.event.small', 'A small event · week {week}',
            {'week': e['week']}),
        const Offset(24, 28),
        30,
        ink,
        bold: true);
    txt(c, locationName, const Offset(25, 66), 11, teal, bold: true);
    txt(c, localized('${e['titleKey']}', '${e['title']}'), const Offset(25, 84),
        16, teal);
    final choiceTop = eventImage == null ? 270.0 : 278.0;
    if (eventImage != null) {
      box(c, const Rect.fromLTWH(24, 120, 330, 138), Colors.white,
          radius: 22, shadow: true);
      drawEventIllustration(
          c, eventImage, const Rect.fromLTWH(24, 120, 330, 138));
      box(c, const Rect.fromLTWH(366, 120, 370, 138), ink, radius: 18);
      txt(c, localized('${e['bodyKey']}', '${e['body']}'),
          const Offset(388, 143), 14, Colors.white,
          bold: true, maxWidth: 326, maxLines: 5);
    } else {
      box(c, const Rect.fromLTWH(24, 120, 712, 110), ink, radius: 22);
      txt(c, localized('${e['bodyKey']}', '${e['body']}'),
          const Offset(48, 158), 18, Colors.white,
          bold: true, maxWidth: 640, maxLines: 3);
    }
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
          lockedLabel = localized(
              'ui.event.locked', activeLocale == 'ko' ? '잠김' : 'Locked'),
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
                  .replaceAll('{stat}', localizedStat('${legacyBonus['stat']}'))
                  .replaceAll('{delta}', '${legacyBonus['delta']}')
              : '';
      CanvasUiKit.statePanel(c, Rect.fromLTWH(x, choiceTop, 332, 210),
          state: locked ? CanvasUiState.disabled : CanvasUiState.idle,
          shadow: !locked);
      txt(
          c,
          locked
              ? lockedLabel
              : formatUi('ui.event.choice', 'Choice {index}', {'index': i + 1}),
          Offset(x + 22, choiceTop + 24),
          14,
          locked ? ink.withValues(alpha: .45) : teal,
          bold: true);
      txt(
          c,
          localized('${ch['labelKey']}', '${ch['label']}'),
          Offset(x + 22, choiceTop + 68),
          17,
          locked ? ink.withValues(alpha: .45) : ink,
          bold: true,
          maxWidth: 190);
      txt(
          c,
          locked
              ? '$lockedLabel · ${localizedChoiceCondition(ch)}'
              : '${localizedChoiceEffect(ch)}$legacyText',
          Offset(x + 22, choiceTop + 122),
          13,
          locked ? ink.withValues(alpha: .45) : ink.withValues(alpha: .6),
          maxWidth: 198,
          maxLines: 2);
      dialoguePortrait(c, Rect.fromLTWH(x + 230, choiceTop + 28, 82, 102), ch);
      drawChoiceEcho(c, ch, Offset(x + 22, choiceTop + 170));
      drawChoiceImpact(c, Rect.fromLTWH(x + 22, choiceTop + 188, 198, 8), ch);
    }
    final reflection = activityReflectionForLine(
        (s['activityScenes'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(),
        lastLine);
    if (reflection != null) {
      box(c, const Rect.fromLTWH(24, 548, 712, 72), Colors.white,
          radius: 16, stroke: teal.withValues(alpha: .3), shadow: true);
      txt(
          c,
          localized('ui.event.activityReflection',
                  'Activity reflection · {title}')
              .replaceFirst(
                  '{title}',
                  localized(
                      '${reflection['titleKey']}', '${reflection['title']}')),
          const Offset(42, 560),
          11,
          teal,
          bold: true,
          maxWidth: 670);
      txt(c, localizedLine(), const Offset(42, 582), 11, ink,
          maxWidth: 670, maxLines: 2);
    } else {
      txt(
          c,
          flags['legacy-star'] == true
              ? localized('ui.event.legacy', '계승의 기록이 새로운 선택을 열었습니다.')
              : lastResult.startsWith('조건') ||
                      lastResult.startsWith('관계 조건') ||
                      lastResult.startsWith('기억 조건')
                  ? lastResult
                  : localized('ui.event.continue',
                      'Choose one path to continue the story.'),
          const Offset(24, 570),
          14,
          flags['legacy-star'] == true ||
                  lastResult.startsWith('조건') ||
                  lastResult.startsWith('관계 조건') ||
                  lastResult.startsWith('기억 조건')
              ? const Color(0xffa84f3c)
              : ink.withValues(alpha: .55));
    }
  }

  void savePage(Canvas c) {
    final publicRecords =
            history.where((entry) => !entry.startsWith('approval:')).toList(),
        recent = publicRecords.reversed.map(readableHistory).take(3).toList(),
        endings = (s['endings'] as List? ?? const []).cast<Map>(),
        known = endings.length,
        discovered = collectionEntries.map((entry) {
          final e = endings.firstWhere(
              (candidate) => candidate['id'] == entry['id'],
              orElse: () => {'title': entry['id']});
          return '${localized('${e['titleKey']}', '${e['title']}')} ★${entry['rank']}';
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
        routeNames = routeIds.map((id) {
          final companion = companions.firstWhere((c) => c['id'] == id,
              orElse: () => {'name': id});
          return localized('${companion['nameKey']}', '${companion['name']}');
        }).join(' · ');
    txt(c, localized('ui.save.title', 'Save archive'), const Offset(24, 28), 32,
        ink,
        bold: true);
    txt(
        c,
        localized('ui.save.subtitle',
            'Keep the current state as a safe code and restore it in another run.'),
        const Offset(25, 70),
        14,
        teal,
        maxWidth: 660);
    box(c, const Rect.fromLTWH(24, 120, 712, 240), Colors.white,
        radius: 20, stroke: ink.withValues(alpha: .12), shadow: true);
    txt(
        c,
        formatUi('ui.save.replay', 'Records {count} · goals {done}/{total}', {
          'count': publicRecords.length,
          'done': milestones.values.where((v) => v).length,
          'total': (s['milestones'] as List? ?? const []).length,
        }),
        const Offset(48, 155),
        15,
        ink);
    txt(
        c,
        formatUi('ui.save.bonds',
            'Companion bonds · Lumi {lumi} · Bora {bora} · Taro {taro}', {
          'lumi': bonds['lumi'] ?? 0,
          'bora': bonds['bora'] ?? 0,
          'taro': bonds['taro'] ?? 0,
        }),
        const Offset(48, 180),
        13,
        teal);
    txt(c, localized('ui.save.recent', 'Recent records'), const Offset(48, 208),
        10, teal,
        bold: true);
    for (var i = 0; i < recent.length; i++)
      txt(c, recent[i], Offset(48, 228 + i * 20), 10,
          ink.withValues(alpha: .65),
          maxWidth: 650, maxLines: 1);
    txt(
        c,
        localized('ui.save.codeHint',
            'The original save code is handled only through the copy button.'),
        const Offset(48, 285),
        10,
        ink.withValues(alpha: .45),
        maxWidth: 650);
    txt(
        c,
        '${formatUi('ui.save.endings', 'Ending archive {done}/{total}', {
              'done': collectionEntries.length,
              'total': known,
            })} · ${discovered.isEmpty ? localized('ui.save.noEndings', 'No endings discovered yet.') : discovered}',
        const Offset(48, 320),
        11,
        teal);
    txt(
        c,
        '${formatUi('ui.save.routes', 'Relationship archive {done}/{total}', {
              'done': routeIds.length,
              'total': companions.length,
            })} · ${routeNames.isEmpty ? localized('ui.save.noRoutes', 'No companion routes discovered yet.') : routeNames}',
        const Offset(48, 343),
        11,
        teal);
    trackerLine(c, const Offset(48, 368), maxWidth: 650);
    box(c, const Rect.fromLTWH(24, 390, 300, 64), teal,
        radius: 18, shadow: true);
    txt(c, localized('ui.save.copy', 'Copy save code'), const Offset(100, 412),
        16, Colors.white,
        bold: true);
    box(c, const Rect.fromLTWH(365, 390, 300, 64), sun,
        radius: 18, shadow: true);
    txt(c, localized('ui.save.restore', 'Restore save code'),
        const Offset(440, 412), 16, ink,
        bold: true);
    txt(c, localized('ui.save.back', '← Back to home'), const Offset(24, 570),
        14, teal,
        bold: true);
  }

  void ending(Canvas c) {
    final d = resolveEnding(JsonStoryAdapter(s), stats,
            bonds: bonds, milestones: milestones, flags: flags),
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
    if (d['variantTitle'] != null)
      txt(c, '${d['variantTitle']} · ${d['variantBody']}',
          const Offset(365, 245), 11, teal,
          maxWidth: 300);
    txt(c, '지혜 ${stats['지혜']}   공감 ${stats['공감']}   용기 ${stats['용기']}',
        const Offset(365, 305), 15, teal);
    txt(
        c,
        '은화 $coins · 피로 $fatigue · 목표 $goalCount/${(s['milestones'] as List? ?? const []).length} · 유대 ${bonds.values.reduce((a, b) => a + b)}',
        const Offset(365, 340),
        15,
        ink);
    txt(c, '루멘 기록 등급 · ${List.filled(rank, '★').join()}',
        const Offset(365, 370), 15, teal,
        bold: true);
    if (epilogues.isNotEmpty || d['epilogue'] != null)
      txt(c, epilogues.isEmpty ? '${d['epilogue']}' : epilogues,
          const Offset(365, 398), 11, teal);
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
    legacyPicker(c);
  }

  void legacyPicker(Canvas c) {
    if (s['legacySelection'] is! Map) return;
    final profiles = unlockedLegacyProfiles(s, collectionEntries);
    if (profiles.isEmpty) return;
    txt(
        c,
        localized('ui.ending.legacyTitle',
            activeLocale == 'ko' ? '다음 회차 계승 선택' : 'Choose a next-run legacy'),
        const Offset(24, 578),
        10,
        teal,
        bold: true,
        maxWidth: 330);
    for (var i = 0; i < profiles.length && i < 3; i++) {
      final profile = profiles[i],
          id = '${profile['id']}',
          selected = id == selectedLegacyId,
          x = 24 + i * 238.0,
          companion = (s['companions'] as List? ?? const [])
              .whereType<Map>()
              .firstWhere(
                  (item) => '${item['id']}' == '${profile['companionId']}',
                  orElse: () => <String, dynamic>{}),
          title =
              localized('${profile['titleKey']}', '${profile['title'] ?? id}'),
          companionName = localized('${companion['nameKey']}',
              '${companion['name'] ?? profile['companionId'] ?? ''}'),
          stat = localizedStat('${profile['stat']}');
      box(c, Rect.fromLTWH(x, 600, 226, 54), selected ? teal : Colors.white,
          radius: 14, stroke: teal, shadow: selected);
      txt(c, '${selected ? '✦ ' : ''}$title', Offset(x + 12, 610), 9,
          selected ? Colors.white : ink,
          bold: true, maxWidth: 202, maxLines: 1);
      txt(c, '$companionName · $stat +${profile['bonus'] ?? 0}',
          Offset(x + 12, 630), 8, selected ? Colors.white70 : teal,
          maxWidth: 202, maxLines: 1);
    }
  }

  @override
  bool shouldRepaint(Scene o) => o.repaintKey != repaintKey;
}
