# 프린스 메이커

독자 세계관 ‘루멘’에서 48주 동안 노아의 방향을 함께 고르는 결정론적 육성 시뮬레이션입니다. 한 회차는 48회 일정, 47개 본편 사건과 24개 사이드 장면, 16막 결산, 16개 막 관계 장면으로 구성되어 보수적 페이싱 기준 156분의 서사 분량을 계산합니다. 동료 유대와 막 진행은 18개 독립 동행 장면을 실제 시스템 기록으로 열고 저장합니다. 원작의 캐릭터·문구·화면을 사용하지 않고, **일정 선택 → 수치 변화 → 서사 판정**이라는 장르의 구조만 새 규칙과 시각 언어로 재구성했습니다.

장편 분량의 권위 있는 기준은 `story/story.jsonl#contentBudget`이며, `tool/verify_game.dart`가 최소 120분·사건/선택지/막 결산 수를 함께 판정합니다.

화면은 Flutter 위젯 카드가 아니라 `CustomPaint`/`Canvas`를 기준으로 그립니다. 입력은 얇은 `GestureDetector`와 재사용 가능한 [`CanvasViewport`](lib/canvas_surface.dart)가 좌표를 게임 상태 전이로 바꾸고, [`canvasSceneFingerprint`](lib/canvas_scene_fingerprint.dart)가 상태 key를 결정론적으로 정규화해 필요한 repaint만 허용합니다. 활동 선택은 [`activity_catalog.dart`](lib/activity_catalog.dart)가 5개 성장·피로·은화 tradeoff를 재활용 가능한 데이터 계약으로 공급합니다.

한글 Golden 재현성을 위해 [Noto Sans KR](https://github.com/google/fonts/tree/main/ofl/notosanskr)을 OFL 폰트 자산으로 번들합니다. 캐릭터와 UI 일러스트는 이 폰트와 독자 PNG 시트만 사용하며 원작의 이미지·문구·캐릭터를 복제하지 않습니다.

## 실행

```bash
flutter pub get
flutter run -d chrome
flutter build web --wasm --release

# 한 번만 설정하면 이후 커밋 때 동일한 검증을 자동 실행합니다.
git config core.hooksPath .githooks
```

## 골든 테스트 증적

`flutter test --update-goldens`로 화면 기준을 갱신하고, 이후 `flutter test --concurrency=1`이 단일 Golden 실행기에서 픽셀 변화를 차단합니다. OS별 Canvas 글꼴 안티앨리어싱 차이는 2.5% 이하의 bounded tolerance만 허용하며, 그 이상은 실패합니다.

![골든 기준 화면](test/goldens/home.png)
![계절 목표가 보이는 계획 화면](test/goldens/milestone.png)
![사건 선택 Golden](test/goldens/event.png)
![대화 상대 상반신이 연결된 사건 Golden](test/goldens/chapter-arrival.png)
![성격별 상반신 일러스트 페이지](test/goldens/illustration.png)
![고요한 관찰자 성격 일러스트 Golden](test/goldens/personality-quiet.png)
![다정한 연결자 성격 일러스트 Golden](test/goldens/personality-kind.png)
![용감한 개척자 성격 일러스트 Golden](test/goldens/personality-bold.png)
![활동 선택 전 결정론적 forecast Golden](test/goldens/activity-forecast.png)
![피로 위험을 설명하는 활동 선택 Golden](test/goldens/activity-risk.png)
![선택 전 authored 기억 제목·원인 설명 forecast Golden](test/goldens/memory-forecast.png)
![English 활동 reflection Golden](test/goldens/activity-reflection-en.png)
![English 활동 회고 일지 Golden](test/goldens/activity-journal-en.png)
![한국어 활동 회고 일지 Golden](test/goldens/activity-journal-ko.png)
![48주 엔딩 화면](test/goldens/ending.png)
![엔딩 원인 회고 보드](test/goldens/ending.png)
![다음 회차 계승 선택 Golden](test/goldens/legacy-picker.png)
![다음 회차 계승 선택 English Golden](test/goldens/legacy-picker-en.png)
![선택한 계승 프로필 Golden](test/goldens/legacy-picker-selected.png)
![새 회차에 적용된 계승 프로필 Golden](test/goldens/legacy-home.png)
![계승 동행 에필로그가 보이는 엔딩 Canvas](test/goldens/companion-epilogue.png)
![별읽기 계승 동행 Golden](test/goldens/companion-stargazer.png)
![정원 계승 동행 Golden](test/goldens/companion-gardener.png)
![길잡이 계승 동행 Golden](test/goldens/companion-pathfinder.png)
![replay 기록 보관소 화면](test/goldens/save.png)
![나비효과·동료 퀘스트 운명 기록 보관소](test/goldens/narrative-ledger.png)
![English fate ledger Golden](test/goldens/narrative-ledger-en.png)
![시스템 승인·거절 영수증 Golden](test/goldens/system-receipt.png)
![루멘 캐릭터 도감 Golden](test/goldens/character-roster.png)
![Lumen character archive Golden](test/goldens/character-roster-en.png)
![루멘 환경 아틀라스 Golden](test/goldens/environment-atlas.png)
![Lumen environment atlas Golden](test/goldens/environment-atlas-en.png)
![Canvas UI 상태 계약 Golden](test/goldens/ui-state-matrix.png)

16막의 첫 canonical 사건 화면도 SSOT에서 결정론적으로 재생해 Golden으로 고정합니다.

![16막 canonical 사건 Golden 행렬 대표](test/goldens/chapter-handoff.png)
![16막 canonical 결산 Golden 행렬 대표](test/goldens/chapter-closure-handoff.png)
![막 결산 관계 장면 Golden](test/goldens/chapter-closure-arrival.png)
![상태별 관계 후속 대화 Golden](test/goldens/relationship-followup.png)
![동행 독립 장면 잠금·기록 Golden](test/goldens/companion-scenes.png)
![동행 장면 기록 완료 Golden](test/goldens/companion-scene-recorded.png)
![English 동행 장면 기록 완료 Golden](test/goldens/companion-scene-recorded-en.png)

전체 행렬은 [`test/chapter_golden_test.dart`](test/chapter_golden_test.dart), [`test/chapter_closure_golden_test.dart`](test/chapter_closure_golden_test.dart)와 [`test/goldens/chapter-*.png`](test/goldens/)에서 확인할 수 있습니다.

Canvas의 실제 보이는 컨트롤과 입력 좌표는 [`test/player_input_contract_test.dart`](test/player_input_contract_test.dart)에서 page 3 사건 EN 토글과 page 1 일러스트 뒤로가기 hitbox를 직접 재생해 고정합니다.
![새 캠페인 재시작 화면](test/goldens/restart.png)
![SSOT에서 직접 렌더링한 canonical 홈](test/goldens/canonical-home.png)
![SSOT 4주차 온실 사건](test/goldens/canonical-event.png)
![SSOT 48주차 다음 사람의 첫걸음 사건](test/goldens/canonical-handoff-event.png)
![엔딩 도감이 보이는 replay 보관소](test/goldens/collection.png)
![실제 SSOT 48주 경로의 canonical 엔딩](test/goldens/canonical-ending.png)
![사건 선택 결과 피드백 배너](test/goldens/feedback.png)
![관계 긴장 선택 결과 피드백](test/goldens/relationship-tension.png)
![관계 중재 선택 결과 피드백](test/goldens/mediation.png)
![관계 상태가 Canvas에 투영된 Golden](test/goldens/relationship-tension.png)
![외출 선택의 은화·유대 교환](test/goldens/outing.png)
![유대 조건 잠금 Golden](test/goldens/relationship-gate.png)
![기억 조건 잠금 Golden](test/goldens/memory-gate.png)
![계승 해금 Golden](test/goldens/legacy-gate.png)
![계승 프로필별 선택 보정 Golden](test/goldens/legacy-profile.png)
![English locale 성격 대화](test/goldens/english-illustration.png)
![English locale 사건 선택](test/goldens/english-event.png)
![English locale 엔딩·동료 에필로그](test/goldens/english-ending.png)

플레이어 표면의 English core-loop·활동 reflection·ko/en 활동 회고 일지·저장 보관소·세 성격별 상반신 일러스트와 활동 forecast/horizon·피로 위험·회복 소요일 예고는 [`test/player_facing_golden_test.dart`](test/player_facing_golden_test.dart)·[`test/activity_forecast_golden_test.dart`](test/activity_forecast_golden_test.dart)·[`test/activity_risk_golden_test.dart`](test/activity_risk_golden_test.dart)·[`test/activity_reflection_golden_test.dart`](test/activity_reflection_golden_test.dart)·[`test/activity_journal_golden_test.dart`](test/activity_journal_golden_test.dart)가 실제 Canvas 상태를 재생해 고정하고, `test/activity_forecast_test.dart#recovery window follows the injected SSOT rest delta`가 같은 규칙을 수치로 재생합니다. 저장 화면은 raw schema/history/hash를 기본 화면에 표시하지 않고, 사람이 읽는 기록 요약과 복사·복원 동작만 노출합니다.

![English core-loop home Golden](test/goldens/player-home-en.png)
![저장 보관소 요약 Golden](test/goldens/player-save.png)
![English 저장 보관소 Golden](test/goldens/player-save-en.png)

## SSOT와 게임성 지표

게임성 KPI는 SSOT의 authored choice를 직접 계산합니다: 166/166 effectful choice, 71/71 divergent scene, 166/166 multi-axis choice, 72/166 trade-off choice(0.4337), 29 gated choice, 36/36 companion choice impact와 36/36 companion choice foresight이며, 활동 카드의 즉시 효과와 다음 사건/목표를 함께 보여 주는 `activityForecastHorizonGolden`, 피로 감쇠·과로·결정론적 회복 소요일을 명시하는 `activityRiskForecastGolden`, 선택 전 authored fate-thread 제목·원인 설명을 고정하는 `memoryImpactGolden`까지 purity 축의 fail-closed 게이트로 연결됩니다. 계승 프로필은 명시된 `targetEndingId`·공명 동료를 다음 회차 선택 전에 예고하고, 5개 SSOT 일정 정책을 각각 재생해 프로필당 관측 4개 엔딩·4개 route signature와 3개 서로 다른 fingerprint를 만들며, 이 증적은 `story/story.jsonl#lineageDistribution`·`test/gameplay_metrics_test.dart`·`tool/benchmark_game.dart`에서 함께 판정하고 `legacy-picker.png` Canvas header에 표시합니다. 성능 축은 home/event/ending/ledger/relationship/companion 6개 대표 Canvas page를 동일 `Scene.paint` 경로로 반복 측정해 평균 8,000µs 미만을 강제하며, `test/canvas_render_perf_test.dart`가 SSOT `contentBudget`와 직접 대조합니다. 상세 계약은 story/story.jsonl의 gameplayKpis·relationshipDesign·contentBudget와 lib/choice_impact.dart·lib/companion_scene_archive_painter.dart·tool/verify_gameplay_fun.dart에 있습니다.

스토리와 활동 정의의 단일 원천은 [`story/story.jsonl`](story/story.jsonl)입니다. 화면은 이 데이터의 제목·배경·주인공·성격별 이름·말투·대사를 읽고, 활동은 동일한 선언형 레지스트리로 렌더링합니다. `characters`는 노아와 세 동료의 역할·이름 key·portrait asset/frame을 선언하며, 94개 사건 선택은 `speakerId → locale key → portrait frame`으로 같은 상반신 대화 컴포넌트를 재사용합니다. `assets/noa-sprite-sheet.png`는 독창적인 2등신 노아의 차분·호기심·결의 표정 시트이며, `assets/lumen-personality-sheet.png`는 고요·다정·용감 성격의 3프레임 상반신 시트입니다. 두 PNG는 SSOT의 `assetRefs`와 각 personality/character의 `portraitAsset`/`portraitFrame`으로 연결되어 Canvas 일러스트와 사건 대화에서 표시됩니다. 핵심 폐쇄루프는 1주 선택, 스탯/은화 변화, 다음 주 피드백이며 테스트가 그 전이를 고정합니다.

캐릭터의 독자 조형 규칙과 자산 provenance는 [`docs/art-provenance.md`](docs/art-provenance.md)에 기록하고, SSOT verifier가 PNG 매핑·성격별 색상·모티프·실루엣 필드를 강제합니다.

### 루멘 캐릭터 도감

홈 화면 하단의 `캐릭터 도감`에서 루멘 주민 20종을 한 번에 확인할 수 있습니다. 도감은 [`story/story.jsonl`](story/story.jsonl)의 `characterArchive`를 [`lib/character_roster.dart`](lib/character_roster.dart)가 읽고, [`assets/lumen-character-roster.png`](assets/lumen-character-roster.png)의 5×4 독자 캐릭터 시트를 같은 `sheetIndex`로 연결해 기존 twilight / mist / sun / paper Canvas 언어 안에서 카드 그리드로 렌더링합니다. 노아·3명 동료의 서사 registry는 그대로 유지하고, 20종은 세계관 확장용 아카이브 캐릭터 디자인 레이어로 분리했습니다.

홈 하단의 `환경 아틀라스`는 6개 장소를 기록관(기억/지혜), 온실(돌봄/공감), 시장(교환/은화), 바람길(횡단/용기), 관측소(발견/지혜), 채석장(자원/용기)으로 설명합니다. 각 환경은 `surface → affordance → memory`를 함께 가지며, 장소 발견 flag와 사건 선택의 의미를 같은 UI 카드와 Canvas 풍경으로 연결합니다. 상세 규칙은 [`docs/design-system.md`](docs/design-system.md)의 환경 게임디자인 시스템을 기준으로 합니다.
한국어·English 도감 화면은 [`test/goldens/character-roster.png`](test/goldens/character-roster.png)와 [`test/goldens/character-roster-en.png`](test/goldens/character-roster-en.png)으로 고정됩니다.

도감 카드에서 주민을 선택하면 `page == 10` 캐릭터 일러스트 설계 화면으로 이동합니다. [`characterArchive`](story/story.jsonl)의 `illustration`·`silhouette`·`gesture`·5종 `emotionNotes`를 [`lib/character_art.dart`](lib/character_art.dart)가 읽고, [`lib/character_art_painter.dart`](lib/character_art_painter.dart)가 같은 PNG sheet와 재사용 가능한 감정 칩으로 렌더링합니다.

![도란 캐릭터 일러스트 설계 Golden](test/goldens/character-art-doran.png)
![도란 걱정 표정 Golden](test/goldens/character-art-doran-concern.png)
![Doran English character art Golden](test/goldens/character-art-doran-concern-en.png)

캐릭터 아트 상세 페이지의 ko/en·표정 전환은 위 3개 Golden과 [`test/character_art_golden_test.dart`](test/character_art_golden_test.dart)로 고정되며, 성격별 상반신 페이지는 `personality-quiet/kind/bold.png`로 고정됩니다. 엔딩 뒤에는 collection과 SSOT 계승 계약이 공개한 프로필을 자동 선택하지 않고 다음 회차 계승 카드에서 직접 고를 수 있으며, 카드에는 순수 `legacyProfileForecast`가 해석한 명시적 target ending과 공명 동료가 함께 보입니다. 선택 결과는 `GameSession.legacyId`와 2주차 authored 보정으로 재생되고 새 회차 홈에 프로필·성장축·보정값이 표시됩니다. 전체 Canvas Golden 증적은 105장입니다.

### 감정·이벤트 일러스트 매트릭스

전체 디자인 이미지 수량은 [`design/image-design-matrix.jsonl`](design/image-design-matrix.jsonl)에 고정합니다. `5종 감정 × 20명 = 100프레임`에 `4명 주요 캐릭터 × 47개 메인 이벤트 = 188프레임`, `6개 위치 × 4개 사이드 씬 = 24프레임`을 더해 총 `312프레임`입니다. 실제 파일은 캐릭터 감정 시트 20장, 이벤트 시트 47장, 재활용 가능한 사이드 씬 위치 시트 6장으로 병합됩니다. 사건 화면은 [`lib/event_art.dart`](lib/event_art.dart)가 SSOT의 `illustrationAsset + illustrationFrame`을 읽어 Canvas에 현재 프레임만 표시합니다. [`test/image_design_matrix_test.dart`](test/image_design_matrix_test.dart)와 [`test/side_scene_art_test.dart`](test/side_scene_art_test.dart)가 73개 PNG 시트의 존재·규격·프레임 수와 312 산식을 검증하고, [`test/goldens/side-scene.png`](test/goldens/side-scene.png) 및 [`test/goldens/side-scene-en.png`](test/goldens/side-scene-en.png)가 한글·영문 화면을 증적합니다.

홈 하단의 `동행 기록`은 `page == 11`에서 `resolveRelationshipDynamics`·`resolveRelationshipFollowup`·`resolveCompanionQuests`를 동일 입력으로 투영합니다. 현재 관계 상태·유대 간격·상태별 후속 기록·루미/보라/타로의 상반신·퀘스트 진행을 [`lib/relationship_archive_painter.dart`](lib/relationship_archive_painter.dart)가 재사용 가능한 패널로 렌더링하고, ko/en 화면과 고요·다정·용감 세 성격의 공명 결과를 [`test/goldens/relationship-archive.png`](test/goldens/relationship-archive.png)·[`test/goldens/relationship-archive-en.png`](test/goldens/relationship-archive-en.png)·[`test/goldens/relationship-archive-kind.png`](test/goldens/relationship-archive-kind.png)·[`test/goldens/relationship-archive-bold.png`](test/goldens/relationship-archive-bold.png)으로 고정합니다. 각 동료 카드는 `page == 13` 독립 장면 기록으로 이어지며, `resolveCompanionScenes`가 `bond > 0 ∧ chapter ≤ currentChapter ∧ not recorded`를 순수하게 계산하고 `GameSession.recordCompanionScene`이 시스템 승인·memory flag·trace·save를 한 번에 남깁니다.

동행 장면은 카드 첫 탭에서 선택을 열고 두 번째 탭에서 2-way 선택을 확정합니다. 확정 전 두 선택 모두 수치 결과 문구와 보상·비용 막대를 보여 주며, 선택은 성장축·피로·유대·memory flag·응답 대사와 엔딩 route signature에 반영됩니다. 잠금·중복·잘못된 입력은 localized reject banner로 남습니다. 대표 Canvas 증거는 [`companion-scenes.png`](test/goldens/companion-scenes.png)·[`companion-scene-choice.png`](test/goldens/companion-scene-choice.png)·[`companion-scene-recorded.png`](test/goldens/companion-scene-recorded.png)·[`companion-scene-recorded-en.png`](test/goldens/companion-scene-recorded-en.png)·세 동료 혼합 상태 [`companion-scene-lumi-mixed.png`](test/goldens/companion-scene-lumi-mixed.png)·[`companion-scene-bora-mixed.png`](test/goldens/companion-scene-bora-mixed.png)·[`companion-scene-taro-mixed.png`](test/goldens/companion-scene-taro-mixed.png)·잠금 피드백 [`companion-scene-locked.png`](test/goldens/companion-scene-locked.png)로 고정합니다.

환경 아틀라스는 [`story/story.jsonl`](story/story.jsonl)의 6개 장소를 `environmentsFromStory`로 재사용해, 모티프·날씨·활동·성장축의 게임플레이 약속을 [`test/goldens/environment-atlas.png`](test/goldens/environment-atlas.png)와 [`test/goldens/environment-atlas-en.png`](test/goldens/environment-atlas-en.png)으로 고정합니다. Canvas UI Kit의 다섯 상태와 사이드 씬 위치·메뉴 카피, 활동 선택 전 forecast·horizon·피로 위험·회복 창·선택 전 authored 기억의 제목·원인 설명·English 활동 reflection·ko/en 활동 회고 일지·명시적 target ending이 보이는 엔딩 뒤 계승 프로필 선택·새 회차 적용 피드백·동행 장면의 선택·잠금·혼합 상태도 각각 Golden으로 고정하며, 전체 Golden 증적은 105장입니다.

### 캐릭터 일러스트·감정표현 설계

도감 카드를 누르면 캐릭터별 일러스트 방향·실루엣·시그니처 동작·5종 감정표현을 확인하는 상세 설계 화면으로 이동합니다. story/story.jsonl의 characterArchive가 20명 각각의 한국어·영어 장면 구상과 calm / joy / concern / resolve / wonder 표정 큐를 선언하고, 20명 전원이 ID별 감정 PNG 시트를 사용하도록 `assetRefs`와 SHA-256 계약으로 고정합니다. lib/character_art.dart와 lib/character_art_painter.dart가 이 시트를 Canvas에 병합하고, 도란·다온 기준 한국어·영어 및 걱정 전환 화면은 test/goldens/character-art-doran*.png와 test/goldens/character-art-daon.png으로 고정합니다.

### 성격 유형 캐릭터 시트

![루멘 성격 유형 3종 캐릭터 시트](assets/lumen-personality-sheet.png)

| SSOT id | 유형 | 디자인 연결 |
| --- | --- | --- |
| `quiet` | 고요한 관찰자 | 인디고·라벤더 / 달 모티프 / frame 0 |
| `kind` | 다정한 연결자 | 틸·크림 / 꽃 모티프 / frame 1 |
| `bold` | 용감한 개척자 | 코랄·황토 / 나침반 모티프 / frame 2 |

현재 지표: 본편 47개 + 사이드 장면 24개 = authored scene 71개, 본편 선택 94개 + 사이드 선택 72개 + 동행 선택 36개, 장소 6개, 활동별 미니 이벤트 10개, 동료 독립 장면 18개(3명×6, 장면당 2-way 기록 루프), 핵심 엔딩 6개 + 실패·중립·관계 변형 18개, SSOT 산식상 narrative backbone 612줄 + 동행 선택 label/response 72줄 = authored dialogue unit 684개, ko/en locale 1170키, 성격×동료 3×3 공명 matrix(매칭 3개·선택 유대 +1), 11개 authored 분기 축의 2,048개 scenario vector와 122,880개 route input, 5개 일정 정책 실험의 distinct ending/signature 3개 이상, 활동 horizon·피로 위험·회복 소요일·계승 target ending 예고 Golden을 CI에서 자동 검증합니다.

계승 관계 회고 지표는 `stargazer→lumi`, `gardener→bora`, `pathfinder→taro` target companion epilogue가 동일 replay와 5,000회 benchmark에서 각각 재현되는지 추가로 확인합니다. 더불어 각 프로필 × 5개 일정 정책의 엔딩·서명 fingerprint가 replay에서 동일하고 서로 달라야 합니다.

대사의 확장 단위는 `key → locale catalog → Canvas`이며, 새로운 언어는 게임 규칙을 건드리지 않고 `story/locales/<locale>.jsonl`과 Golden만 추가합니다. 시각 방향은 기존 작품을 모사하지 않는 독자적 **황혼 운명 기록** 무드(`twilight / mist / sun / paper`)로 확장합니다.

## 장기 설계 기준

초안 이후 기능은 재활용 가능한 [Lumen Canvas Kit](docs/design-system.md)를 먼저 설계한 뒤 구현합니다. 토큰은 [`design/tokens.jsonl`](design/tokens.jsonl)과 [`lib/design_tokens.dart`](lib/design_tokens.dart)에 분리되어 있으며, 화면은 `stat_panel`, `choice_card`, `portrait_page`, `ending_panel` 조합으로 확장합니다.

게임 UI 전체 조합은 [`docs/design-system.md`](docs/design-system.md)의 화면별 조합표와 [`lib/canvas_ui_kit.dart`](lib/canvas_ui_kit.dart)의 공통 상태 surface를 기준으로 합니다. 홈 HUD·활동 카드·진행 바·피로/조건 배지·선택 카드·화자 패널·피드백 배너·저장/복원·운명 기록·막 결산·엔딩 회고·도감·환경·사이드 장면까지 `idle / selected / disabled / success / danger` 상태를 같은 토큰으로 렌더링합니다.

게임 요소 분석과 정량 게이트는 [`docs/game-completeness.md`](docs/game-completeness.md), 시나리오 표본은 [`docs/scenario-completeness.md`](docs/scenario-completeness.md), 정량 개발목표 원장은 [`docs/development-goals.md`](docs/development-goals.md)·[`docs/development-goals.jsonl`](docs/development-goals.jsonl), 결정 증명 계약은 [`docs/decision-proof-contract.jsonl`](docs/decision-proof-contract.jsonl), 기계 판정 계약은 [`docs/trilemma-contract.jsonl`](docs/trilemma-contract.jsonl), 트릴레마 폐쇄루프는 [`docs/trilemma.md`](docs/trilemma.md), CI 강제 검사는 [`tool/ci_gate.dart`](tool/ci_gate.dart), [`tool/trilemma_verdict.dart`](tool/trilemma_verdict.dart), [`tool/verify_game.dart`](tool/verify_game.dart), [`tool/verify_scenario_variants.dart`](tool/verify_scenario_variants.dart), [`tool/verify_decision_proof.dart`](tool/verify_decision_proof.dart), [`tool/verify_development_goals.dart`](tool/verify_development_goals.dart)와 [`tool/benchmark_game.dart`](tool/benchmark_game.dart)에 있습니다. 게이트는 완전성·순수성·성능을 축별로 기록하며, `build/trilemma-verdict.json`에서 하나라도 실패하면 전체 변경을 거부합니다. 완전성 점수가 95% 미만이거나 2,000개 scenario vector·실제 SSOT campaign benchmark·정량 목표 증적·결정 chain 증명이 실패해도 변경을 거부합니다. 각 막은 SSOT의 `reveal → pressureAxes → choiceWeeks → closureMilestone` 계약을 실제 사건·막 목표와 대조합니다. 동일한 일정 예산으로 지혜·공감 경로가 서로 다른 authored 엔딩과 유대를 만드는 순수성 회귀도 고정합니다. SSOT 검사 → 결정 증명 → 시나리오 경우의 수 열거 → 독창성 계약 → 트릴레마 계약 → 해시 매니페스트 → 정적 분석 → 상태/Golden 테스트 → 실제 SSOT campaign benchmark → 정량 개발목표 verdict → Wasm 빌드 순서가 모두 통과해야 저장소 변경이 검증됩니다.

SSOT에서 생성된 문서는 [`docs/story-ssot.md`](docs/story-ssot.md)와 [`docs/ssot-metrics.md`](docs/ssot-metrics.md)이며, 문서 헤더의 SHA-256과 `source-ref`를 CI가 검사합니다. 시나리오 verifier는 2,048개 authored branch vector를 실제 코어에서 재생하고, 성능 benchmark는 `story/story.jsonl`을 실제 `GameSession`에 주입해 47개 사건을 포함한 같은 5,000 campaign workload를 재실행하며 checksum·replayChecksum·activity/companion checksum·endings/signatures/locations/companionScenes의 실제 집합·3개 계승 프로필의 lineage ending/signature/companion 집합과 target ending·target companion epilogue·프로필 × 정책 분포까지 일치해야 통과합니다. 첫 실행과 replay 중 큰 `maxElapsedMillis`가 24초 이내이고 전이당 평균 시간도 verdict에 남습니다. 핵심 변경 파일은 [`docs/review-manifest.jsonl`](docs/review-manifest.jsonl)에 해시와 ref가 있어, 파일을 다시 읽고 검토하지 않은 변경은 통합되지 않습니다. 사람의 승인 대신 [`docs/decision-proof-contract.jsonl`](docs/decision-proof-contract.jsonl)과 [`tool/verify_decision_proof.dart`](tool/verify_decision_proof.dart)가 SSOT·현재 precondition·직전 parent hash를 먼저 검증하고, 이후 `SystemDecisionPolicy`와 `tool/ci_gate.dart`가 terminal 상태·Golden·scenario vector enumeration·benchmark를 fail-closed로 판정해 결정 영수증을 trace에 남깁니다. 운영 규칙은 [`docs/automation-policy.md`](docs/automation-policy.md), 외부 게임의 규칙 단위 분석과 루멘의 독창성 차이는 [`docs/originality-contract.jsonl`](docs/originality-contract.jsonl)에 기록합니다.

성능 폐쇄루프의 benchmark는 5,000 campaign·565,000 transition을 실행하고 `checksum`·`replayChecksum`·`companionSceneChecksum`·결과 집합·계승 집합·첫/replay 최대 시간 재현까지 시스템 판정합니다. 독립 동료 장면은 8개 Golden(선택 대기·기록 후·ko/en·3명 혼합 상태·잠금 피드백)과 코어 기록 테스트를 함께 통과해야 합니다.

런타임 구조는 [architecture.md](docs/architecture.md)에 정의된 ECS/DOD + EDA + Hexagonal 경계를 따릅니다. Canvas는 어댑터이고, `GameSession`은 애플리케이션 포트이며, `GameWorld`는 결정론적 이벤트 시스템입니다.

렌더러 선택 근거는 [`docs/engine-decision.md`](docs/engine-decision.md)와 [`docs/engine-decision.jsonl`](docs/engine-decision.jsonl)에 SSOT 기반으로 생성됩니다. Flutter Canvas/WASM은 현재 Golden·i18n·Canvas 콘텐츠 루프에 최적이며, Bevy ECS/WASM은 비교 대안으로 기록했습니다. 새 엔진은 동일한 Golden·WASM·benchmark 게이트를 통과해야 채택할 수 있습니다.

## 렌더러 검토: Flutter Canvas 우선

| 선택지 | 장점 | 현재 판정 |
| --- | --- | --- |
| Flutter `CustomPaint` | 웹 Wasm, Flutter 골든 테스트, 텍스트·입력·접근성 조합이 한 저장소에 있음 | 채택 |
| Rust Bevy UI | ECS 기반 게임 루프와 대규모 2D/3D 렌더링 확장성 | 보류 |

Bevy의 UI는 Flexbox/CSS Grid 모델과 ECS에 강하지만, 공식 표준 위젯 예제가 아직 실험적이라고 명시되어 있고 이 프로젝트의 핵심 증적(Flutter 골든·저비용 웹 배포)을 다시 구성해야 합니다. 프레임 시간이나 콘텐츠 규모가 병목으로 확인될 때만 Bevy를 별도 실험 브랜치에서 비교합니다.

## 근거와 추적성

- [Flutter Web](https://docs.flutter.dev/platform-integration/web), [Flutter Wasm](https://docs.flutter.dev/platform-integration/web/wasm), [Web renderers](https://docs.flutter.dev/platform-integration/web/renderers), [CustomPaint](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Bevy standard widgets](https://bevy.org/examples/ui-user-interface/standard-widgets/), [Bevy UI API](https://docs.rs/bevy/latest/bevy/ui/index.html)
- 장르 참고: [Princess Maker 1 mechanics overview](https://princessmaker.fandom.com/wiki/Princess_Maker_1), [comparative study](https://uu.diva-portal.org/smash/get/diva2:1966128/FULLTEXT01.pdf)

리뷰 매니페스트의 파일별 SHA-256은 [`docs/review-manifest.jsonl`](docs/review-manifest.jsonl)을 단일 기준으로 사용합니다.
