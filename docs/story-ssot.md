<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: 1b5bfdd97dccf7661a27761fccb5c7d705b46a2f681530a64e23ac7e84cbea01 -->
<!-- source-ref: story/story.jsonl#root -->

# 프린스 메이커 · 스토리 SSOT

바람과 별빛이 공존하는 작은 영지 루멘에서 노아는 48주 동안 스스로 선택한 내일을 걷는다.

## 시스템 판정과 책임 추적

판정 주체: **Lumen Ledger System** · 모드 `system-adjudicated` · 사람 승인 필요 여부 `false` · 실패 모드 `fail-closed`
책임 증적: 모든 승인·거절을 규칙·입력·결정 영수증으로 추적하고 replay에서 같은 판정을 재현한다.
- `terminal-window` · activity|story-choice · endingWeek 이후 입력은 거절
- `input-contract` · activity|story-choice · 미등록 성장축·조건 미충족 입력은 거절
- `replay-receipt` · accepted decision · 승인 영수증을 immutable trace에 추가

## 48주 진행도

- **별씨앗의 도착** (`arrival`): 1–3주 · 낯선 기록과 첫 편지가 루멘의 평온을 흔든다. → 누구의 목소리를 먼저 믿을지 정한다. · 사건 2, 3주 · 목표 `spring`
  - 막 계약: 공개 별씨앗 기록과 첫 동료의 목소리를 공개한다. · 압력 stat·coins·bond · 선택 2, 3주 · 결산 `spring`
- **흔들리는 다리** (`crossing`): 4–6주 · 성장한 마음은 혼자 빠른 것보다 함께 건너는 법을 배운다. → 속도와 용기 중 오늘의 균형을 선택한다. · 사건 4, 5, 6주 · 목표 `summer`
  - 막 계약: 공개 온실과 강 건너의 협력 규칙을 공개한다. · 압력 stat·coins·bond · 선택 4, 5, 6주 · 결산 `summer`
- **먼 곳의 답장** (`reply`): 7–9주 · 루멘 밖에서 온 부탁이 노아의 안전한 일상을 부른다. → 기록할지 떠날지, 선택의 대가를 감당한다. · 사건 7, 8, 9주 · 목표 `autumn`
  - 막 계약: 공개 지도 밖의 신호와 먼 영지의 요청을 공개한다. · 압력 stat·coins·bond · 선택 7, 8, 9주 · 결산 `autumn`
- **겨울의 문턱** (`threshold`): 10–12주 · 축제의 빛 아래에서 지난 선택들이 하나의 방향으로 모인다. → 왕좌 대신 스스로 고른 내일의 문을 연다. · 사건 10, 11, 12주 · 목표 `winter`
  - 막 계약: 공개 축제·귀환·첫 결산의 무대를 공개한다. · 압력 stat·coins·bond · 선택 10, 11, 12주 · 결산 `winter`
- **얼음 아래의 씨앗** (`frost`): 13–15주 · 첫 결산 뒤에도 루멘의 땅속에는 아직 끝나지 않은 약속이 잠들어 있다. → 멈춤을 실패로 부를지, 다음 발아를 준비할지 정한다. · 사건 13, 14, 15주 · 목표 `frost`
  - 막 계약: 공개 겨울 저장고와 오래된 약속의 비용을 공개한다. · 압력 stat·coins·fatigue·bond · 선택 13, 14, 15주 · 결산 `frost`
- **돌아오는 물길** (`return`): 16–18주 · 멀리 보낸 답장이 돌아오며, 노아의 선택은 루멘 사람들의 얼굴에 새겨진다. → 도움을 받는 법과 돌려주는 법을 함께 배운다. · 사건 16, 17, 18주 · 목표 `return`
  - 막 계약: 공개 답장의 후속 약속과 공동 책임의 범위를 공개한다. · 압력 stat·coins·bond · 선택 16, 17, 18주 · 결산 `return`
- **서로 다른 별자리** (`constellation`): 19–21주 · 각자의 방향이 충돌하는 밤, 함께 만든 지도에도 빈칸이 생긴다. → 정답을 독점할지, 판단의 근거를 모두에게 돌려줄지 선택한다. · 사건 19, 20, 21주 · 목표 `constellation`
  - 막 계약: 공개 공개 기록·공동 판단·이견의 비용을 공개한다. · 압력 stat·coins·bond · 선택 19, 20, 21주 · 결산 `constellation`
- **이름 붙일 수 없는 지평** (`horizon`): 22–24주 · 마지막 지평은 누가 옳았는지가 아니라 어떤 규칙을 남길지 묻는다. → 노아는 자신의 답보다 다음 사람도 다시 검증할 수 있는 길을 남긴다. · 사건 22, 23주 · 목표 `horizon`
  - 막 계약: 공개 새로운 항로와 시스템 기록의 마지막 책임을 공개한다. · 압력 stat·coins·bond · 선택 22, 23주 · 결산 `horizon`
- **돌아온 씨앗** (`seedReturn`): 25–27주 · 첫 결산의 씨앗이 먼 영지와 루멘 사이를 오가며 빚과 약속의 차이를 묻는다. → 받은 것을 누구와 어떤 조건으로 돌려줄지 정한다. · 사건 25, 26, 27주 · 목표 `waterline`
  - 막 계약: 공개 돌아온 씨앗과 강 건너 빈 터를 공개한다. · 압력 stat·coins·bond · 선택 25, 26, 27주 · 결산 `waterline`
- **공정한 몫의 시간** (`fairShare`): 28–30주 · 공방과 온실의 보이지 않는 노동이 장부의 빈칸을 흔든다. → 성장 속도보다 누가 지치고 있는지를 함께 계산한다. · 사건 28, 29, 30주 · 목표 `fair-share`
  - 막 계약: 공개 노동의 영수증과 돌봄의 시간을 공개한다. · 압력 stat·coins·fatigue·bond · 선택 28, 29, 30주 · 결산 `fair-share`
- **기억의 집** (`memoryHouse`): 31–33주 · 이름 없는 상자와 지워진 표식이 기록의 주인을 다시 묻는다. → 보존할 것과 비워 둘 것을 스스로 구분한다. · 사건 31, 32, 33주 · 목표 `memory-house`
  - 막 계약: 공개 기억의 방과 공개 열람 규칙을 공개한다. · 압력 stat·coins·bond · 선택 31, 32, 33주 · 결산 `memory-house`
- **먼 영지의 그림자** (`farShore`): 34–36주 · 루멘의 선택이 다른 마을의 규칙이 되며 의도와 결과가 갈라진다. → 도움을 준다는 말이 누구를 밀어냈는지 확인한다. · 사건 34, 35, 36주 · 목표 `far-shore`
  - 막 계약: 공개 먼 영지의 후속 편지와 두 물길을 공개한다. · 압력 stat·coins·bond · 선택 34, 35, 36주 · 결산 `far-shore`
- **불완전한 지도** (`blankMap`): 37–39주 · 세 장의 지도는 같은 빈칸을 품고, 서로 다른 북쪽을 가리킨다. → 모르는 것을 숨기지 않고 함께 판단할 기준을 만든다. · 사건 37, 38, 39주 · 목표 `blank-map`
  - 막 계약: 공개 빈 지도와 북쪽 문, 공개 나침반 회의를 공개한다. · 압력 stat·coins·fatigue·bond · 선택 37, 38, 39주 · 결산 `blank-map`
- **선택의 의회** (`commons`): 40–42주 · 사람들은 노아에게 책임을 맡기지만, 루멘은 함께 결정하는 법을 배워야 한다. → 합의에 들어오지 못한 목소리까지 규칙의 일부로 남긴다. · 사건 40, 41, 42주 · 목표 `commons`
  - 막 계약: 공개 공동 의회와 침묵의 기록, 공개 규칙을 공개한다. · 압력 stat·coins·bond · 선택 40, 41, 42주 · 결산 `commons`
- **별씨앗의 귀환** (`returningGarden`): 43–45주 · 처음의 씨앗이 꽃이 되어 돌아오며 시작과 소유의 의미가 달라진다. → 떠나는 사람과 남는 사람 모두가 다음 계절의 자리를 얻는다. · 사건 43, 44, 45주 · 목표 `returning-garden`
  - 막 계약: 공개 귀환한 꽃과 떠나는 장터, 이름의 정원을 공개한다. · 압력 stat·coins·bond · 선택 43, 44, 45주 · 결산 `returning-garden`
- **다음 사람의 첫걸음** (`handoff`): 46–48주 · 노아의 기록은 마지막 페이지가 아니라 다음 사람이 다시 검증할 첫 장으로 넘어간다. → 정답 대신 다시 시작할 수 있는 질문과 표식을 남긴다. · 사건 46, 47, 48주 · 목표 `handoff`
  - 막 계약: 공개 다음 여행자와 넘겨지는 장부, 첫 질문을 공개한다. · 압력 stat·coins·bond · 선택 46, 47, 48주 · 결산 `handoff`

## 대사 구성 기준

- locale 최소 키: **923** · 한 캠페인 최소 대사 줄: **63** · 최소 노출 서사 단위: **240** · 전체 authored 대사 줄: **612**
- 산식: authored dialogue 612 = existing campaign 216 + 24 side scenes × 10 lines + 18 companion scenes × 5 lines + 10 activity mini-events × 3 lines + 18 ending variants × 2 lines; mandatory route exposes 63 authored dialogue lines and 240 narrative units

## 최소 플레이타임 계약

- 최소 보장: **120분** · 보수적 1회차 추정: **156분**
- 근거: 48 activity reflections × 75s + 47 story choices × 75s + 24 side scenes × 45s + 16 chapter closures × 30s + 16 relationship beats × 30s + 10 activity mini-events × 20s = 9,365s = 156m; optional side content is counted separately from the mandatory 48-week route.

## 시나리오 경우의 수 계약

- 최소 보장: **2000개** · 실제 재생 검증: **2048개** · 전체 route input: **122880개**
- 분기 주차: 3, 4, 5, 8, 12, 13, 14, 15, 16, 17, 18주
- 산식: 2^11 unconditional authored branch vectors × 5 activity policies × 3 personality routes × 4 legacy contexts = 122,880 route inputs; the CI enumerator replays all 2,048 branch vectors and requires at least 2,000 distinct deterministic scenario traces.

## 게임성 KPI

authored 선택 166개 중 72개가 보상과 비용을 동시에 갖는 교환 선택이다.
- 교환 선택 비율: **0.43373493975903615** · 목표 **0.4** · `choices with at least one positive and one negative numeric axis / choices`
- 선택 영향 1.0 · 사건 분기 1.0 · 다축 영향 1.0 · 조건부 선택 29

## 이벤트 스토밍 증적

전체 authored 단위는 **133개 노드**로 `Trigger → Command → Policy → Domain event → Feedback` 원장에 생성된다. 본편·사이드 선택 166개는 효과·피드백 연결률 1.0을 만족하며, 상세 원장은 [`docs/event-storm.jsonl`](event-storm.jsonl), 기계 판정은 `tool/verify_event_storm.dart#event-storm-gate`가 담당한다.

## 엔딩 설계 행렬

해결 순서: winner-growth-axis → highest-eligible-authored-tier → record-rank → companion-route-set → retrospective-cause-board
- 핵심 엔딩군: stargazer, gardener, pathfinder · 동료 route set 최대 8개 · terminal route card 최대 48개

## 나비효과 기록

선택에서 기록된 기억 flag를 별도 상태로 복제하지 않고, 다음 장의 단서와 엔딩 회고에서 같은 SSOT flag로 재생성한다.
- **ledger-echo** · `first-ledger` · `event.firstLedger.title` · 기록의 선택이 다음 막의 판단 방식으로 되돌아온다. / A choice about the ledger returns as the next chapter's rule.
- **windmill-echo** · `windmill-truce` · `event.windmill.title` · 중재의 선택이 이후 관계의 긴장을 낮춘다. / A mediation choice softens a later relationship conflict.
- **seed-echo** · `return-seed` · `event.seedReturn.title` · 나눔의 선택이 돌아온 씨앗의 의미를 바꾼다. / A choice to share changes what the returning seed means.
- **memory-echo** · `memory-house` · `event.memoryHouse.title` · 기억을 여는 선택이 엔딩 회고의 원인으로 남는다. / Opening the memory house becomes a cause in the ending review.
- **rule-echo** · `public-rule` · `event.publicRule.title` · 공개 규칙을 고른 선택이 다음 사람의 출발점이 된다. / A public rule becomes the next traveller's starting point.
- **question-echo** · `final-question` · `event.finalHorizon.title` · 마지막 질문이 다음 회차의 첫 단서로 이어진다. / The final question becomes the next run's first clue.

## 동료 퀘스트

- **lumi-constellation** · `lumi` · `companion.lumi.routeTitle`
  - `lumi-ledger` · `first-ledger` · 유대 2 · `event.firstLedger.title`
  - `lumi-memory` · `memory-house` · 유대 4 · `event.memoryHouse.title`
  - `lumi-question` · `final-question` · 유대 8 · `event.finalHorizon.title`
- **bora-garden** · `bora` · `companion.bora.routeTitle`
  - `bora-truce` · `windmill-truce` · 유대 2 · `event.windmill.title`
  - `bora-witness` · `witness-garden` · 유대 4 · `event.witness.title`
  - `bora-names` · `named-garden` · 유대 8 · `event.gardenOfNames.title`
- **taro-frontier** · `taro` · `companion.taro.routeTitle`
  - `taro-repair` · `windmill-repair` · 유대 2 · `event.windmill.title`
  - `taro-waterway` · `waterway` · 유대 4 · `event.emptyField.title`
  - `taro-marker` · `final-marker` · 유대 8 · `event.finalHorizon.title`

## 시나리오 완전성 표본

참조 모델: **장기 성장·관계·선택·결산이 하나의 반복 가능한 생활 루프를 이루는 시나리오** (`life-sim-scenario-v1`)

| 차원 | 목표 | 현재 증적 | 검증 ref |
| --- | --- | --- | --- |
| 장기 아크 | 도입·성장·전환·결산이 반복되며 각 막에 사건과 목표가 있다 | 16 chapters / 47 main events + 24 side scenes = 71 authored scenes / 6 locations / 16 milestones / terminal week 49 | `story/story.jsonl#progression.contract` |
| 선택의 행위성 | 모든 authored choice가 스탯·은화·유대·조건 중 하나 이상을 바꾸고 trace에 남는다 | 94 main choices + 72 side-scene choices; crisis, exploration, resource, mini-game and companion-pair mechanics; memory flags carry consequences | `test/story_integration_test.dart#every-authored-ending-and-event-choice-is-reachable` |
| 관계 아크 | 등장·대화·유대 임계·엔딩 에필로그의 계층이 존재한다 | 3 companions / 18 independent companion scenes (6 each) / rival conflict / deterministic relationship states / 3 bond-route epilogues / 16 chapter relationship beats | `story/story.jsonl#companions` |
| 상태 피드백 | 일정의 결과가 다음 선택·막 목표·엔딩 조건에 되돌아온다 | stats, coins, fatigue, 16 milestones, 10 activity mini-events, 6 core endings and 18 ending variants | `test/game_core_test.dart#rules` |
| 조건과 공개 | 조건부 사건과 목표가 숨은 단절이 아니라 재플레이할 실마리로 기능한다 | 16 closing milestones / 16 chapter contracts / locked stat, bond, memory and legacy gates / milestone-gated master endings | `tool/verify_game.dart#scenario-contract` |
| 재플레이 가치 | 동일 입력은 동일 결과, 다른 성장축·정책은 다른 authored 결과를 만든다 | 5 schedule policies / 4 distinct signatures / 6 endings / 3 bond route goals / 3 ending-based legacy profiles / profile-specific week-2 authored bonus / 3 profile route signatures / 3 profile target endings / 3 target companion epilogues | `test/gameplay_metrics_test.dart#three-legacy-profiles-produce-distinct-deterministic-route-signatures` |
| 장면 결산 | 도입·중반 사건·엔딩을 Canvas Golden으로 고정하고 대사 locale을 통과한다 | Canvas event and closure evidence plus 6-location route atlas, 18 companion scenes, 24 side-scene records, 10 activity reflections, 18 ending variants, ko+en catalogs, speaker portrait bindings and system decision receipts | `test/golden_test.dart#all-lineage-companion-epilogues-have-distinct-Canvas-evidence` |
| 종결과 회고 | 엔딩이 terminal 상태·기록·새 캠페인으로 닫히며 성능 benchmark가 같은 루프를 재생한다 | 48-week terminal campaign / system decision receipts / save v7 with memory flags / butterfly ledger / route atlas / collection / deterministic event-cause retrospective / target companion quests and epilogues / SSOT campaign benchmark | `test/golden_test.dart#twenty-four-week-loop-resolves-to-an-ending` |

## 생성 이미지 자산

- [`assets/noa-sprite-sheet.png#hero-2-head-frames`](../assets/noa-sprite-sheet.png) · SHA-256 `1ed524abb6e4eda65e651e25ea008d31efcdebaab28b39086bb1f67a4b32581d`
- [`assets/noa-sprite-sheet-source.png#hero-chroma-key-source`](../assets/noa-sprite-sheet-source.png) · SHA-256 `5dd8207030fb83554ed7e8b420995a4d2dc8cf8a00f9ae8f54770fef61c90dd9`
- [`assets/lumen-personality-sheet.png#personality-frames`](../assets/lumen-personality-sheet.png) · SHA-256 `4f0529df6b24415f44bf18284d6ba15492838dc5bff5f6dab2c620eb97e6fb28`
- [`assets/lumen-personality-sheet-source.png#chroma-key-source`](../assets/lumen-personality-sheet-source.png) · SHA-256 `0e652df6e6a35f67bd8623c15ba23fb88d745a82ac8f083a32ea14a715b706d8`
- [`assets/lumen-character-roster.png#character-archive-sheet`](../assets/lumen-character-roster.png) · SHA-256 `5302f4560c014f619cda1c3de0cf986a8428cec4c005cf29ab6ef62ed5657356`
- [`assets/generated/character-emotions/doran.png#doran-five-emotion-sheet`](../assets/generated/character-emotions/doran.png) · SHA-256 `0ef8e70919cd59879f9e334190fbd0bf37bfaf4b5dbbea1d4f2f41319233b69a`
- [`assets/generated/character-emotions/mira.png#mira-five-emotion-sheet`](../assets/generated/character-emotions/mira.png) · SHA-256 `0acdb7094dadf1ca23185f8b40043cd04a1b0c7c171fd6b3d0ae8743f3750b84`
- [`assets/generated/character-emotions/kai.png#kai-five-emotion-sheet`](../assets/generated/character-emotions/kai.png) · SHA-256 `ddbe4f1d27a7295fba74bdca9569d7ce1369359d9a15f002a764612581cc8c09`
- [`assets/generated/character-emotions/ria.png#ria-five-emotion-sheet`](../assets/generated/character-emotions/ria.png) · SHA-256 `148f96190a24d8cc1577f85026d721c57b3fc726970ed43cf171d2c13100df84`
- [`assets/generated/character-emotions/or.png#or-five-emotion-sheet`](../assets/generated/character-emotions/or.png) · SHA-256 `68339520d191ff5d88726de0c18aa6bf7082509be1f6afcdd5d25a4afc12abca`
- [`assets/generated/character-emotions/sena.png#sena-five-emotion-sheet`](../assets/generated/character-emotions/sena.png) · SHA-256 `c169ed21c988125ee9a0e2efdf69433acb6148c3dc9e3931e1cf856736f889c8`
- [`assets/generated/character-emotions/bron.png#bron-five-emotion-sheet`](../assets/generated/character-emotions/bron.png) · SHA-256 `82dac30a8bd22912e42e128a2120410ca9d007f14915774e336082436eccf8b3`
- [`assets/generated/character-emotions/elbi.png#elbi-five-emotion-sheet`](../assets/generated/character-emotions/elbi.png) · SHA-256 `d8befe99b664ae2d0972e223f97f6500b7039d6b5d57915a978911391c1220eb`
- [`assets/generated/character-emotions/haon.png#haon-five-emotion-sheet`](../assets/generated/character-emotions/haon.png) · SHA-256 `cedbb083c04b7d327579a4b1c9dc7e55cbd34ccf7cdd572ab708bd762a813250`
- [`assets/generated/character-emotions/navin.png#navin-five-emotion-sheet`](../assets/generated/character-emotions/navin.png) · SHA-256 `d8df08bfe66b16d0ab824f552055044cda2fe35645d40bb3b43850bb1b931ba1`
- [`assets/generated/character-emotions/yoonseul.png#yoonseul-five-emotion-sheet`](../assets/generated/character-emotions/yoonseul.png) · SHA-256 `d2cbeb8bbde4ad6a731e5162117e0def85f415d72b89c4aea0c40210399d6f4f`
- [`assets/generated/character-emotions/moa.png#moa-five-emotion-sheet`](../assets/generated/character-emotions/moa.png) · SHA-256 `efdcfdc03e42f2d41d33d79728e80d522279996e2a001bf8cb1a49c7eb248fca`
- [`assets/generated/character-emotions/sol.png#sol-five-emotion-sheet`](../assets/generated/character-emotions/sol.png) · SHA-256 `a9b564680448ac639b33e440918510cc070f62364bbac13d3797fd639c9b529c`
- [`assets/generated/character-emotions/eil.png#eil-five-emotion-sheet`](../assets/generated/character-emotions/eil.png) · SHA-256 `2ed2999195bec0404133d2ca2543de0bb34f8d83ded0a0d68867ad277814c204`
- [`assets/generated/character-emotions/raon.png#raon-five-emotion-sheet`](../assets/generated/character-emotions/raon.png) · SHA-256 `f942e8279fcc4e153aac195e8a99943a67518876abd67f428a13d80a8598491f`
- [`assets/generated/character-emotions/morin.png#morin-five-emotion-sheet`](../assets/generated/character-emotions/morin.png) · SHA-256 `25d7bda1da9b8eb3bb186fb40afe0481229c500a782db57a275163cfeaed2161`

## 폰트

- [`assets/fonts/NotoSansKR-Regular.ttf#canvas-korean-font`](../assets/fonts/NotoSansKR-Regular.ttf) · SHA-256 `c733940a7dc687142848b30a491e97138ed58dc58c4cae33c44e3ee52da411cb`

## 대사 로케일

- [`story/locales/ko.jsonl#catalog`](../story/locales/ko.jsonl) · SHA-256 `c7f71452465bd75ef543967da97de59228315cab338e7723e9665c0e03cb9951`
- [`story/locales/en.jsonl#catalog`](../story/locales/en.jsonl) · SHA-256 `3a346f216fbc8017e4ded425de7efff55aa43acf8f72c4ba37a9a76cdb51620a`

## 성격

- **고요한 관찰자** (`quiet`): 짧고 신중하게 말한다. “별은 서두르지 않아. 나도 오늘은 천천히 볼래.” · 지혜 재능 +1 · frame 0 · `assets/lumen-personality-sheet.png` · indigo-lavender / moon
- **다정한 연결자** (`kind`): 상대의 마음을 먼저 살핀다. “네가 웃으면 정원도 조금 더 환해지는 것 같아.” · 공감 재능 +1 · frame 1 · `assets/lumen-personality-sheet.png` · teal-cream / flower
- **용감한 개척자** (`bold`): 실수해도 먼저 움직인다. “길이 없다면, 오늘 한 걸음으로 만들면 돼!” · 용기 재능 +1 · frame 2 · `assets/lumen-personality-sheet.png` · coral-ochre / compass

## 캐릭터 일러스트 설계

도감의 20명은 `characterArchive`의 PNG sheetIndex와 일러스트 방향·실루엣·시그니처 동작·5종 감정 키를 같은 SSOT에서 읽는다.
- **도란** (`doran`): 안개 낀 골목에서 작은 등불을 두 손으로 감싸 길을 비추는 장면 · 실루엣 `짧은 망토와 앞으로 기운 등불 중심 실루엣` · 동작 `등불을 가슴 높이 들어 올리기` · frame 0
- **미라** (`mira`): 옥상 기록실에서 주석 책을 펼쳐 별의 움직임을 받아 적는 장면 · 실루엣 `큰 책과 망토 깃이 만드는 세로형 실루엣` · 동작 `책장을 한 손으로 누르고 다른 손으로 별을 가리키기` · frame 1
- **카이** (`kai`): 온실 선반 사이에서 작은 화분의 싹을 손바닥으로 감싸는 장면 · 실루엣 `둥근 화분과 넓은 앞치마가 만드는 안정된 실루엣` · 동작 `화분을 배 앞에 받치고 몸을 살짝 웅크리기` · frame 2
- **리아** (`ria`): 비가 그친 정원에서 꽃 물뿌리개로 잎 끝의 물방울을 이어 주는 장면 · 실루엣 `꽃잎 모자와 물뿌리개가 양옆으로 퍼지는 실루엣` · 동작 `팔을 크게 휘둘러 비의 호를 그리기` · frame 3
- **오르** (`or`): 바람 언덕에서 황동 망원경으로 구름의 길을 재는 장면 · 실루엣 `긴 망원경과 날리는 스카프가 대각선을 만드는 실루엣` · 동작 `망원경을 한쪽 눈에 대고 발끝으로 방향을 잡기` · frame 4
- **세나** (`sena`): 강가 돌계단에서 현악기를 켜 물결의 박자를 맞추는 장면 · 실루엣 `악기와 긴 소매가 물결처럼 흐르는 실루엣` · 동작 `한 발을 계단에 올리고 활을 길게 긋기` · frame 5
- **브론** (`bron`): 낡은 다리 난간에 나무 새를 올려 두고 이음새를 고치는 장면 · 실루엣 `넓은 공구 가방과 낮게 굽힌 어깨의 실루엣` · 동작 `한 손으로 판자를 누르고 다른 손으로 망치를 들기` · frame 6
- **엘비** (`elbi`): 기억 온실에서 말린 잎의 결을 투명한 병에 겹쳐 읽는 장면 · 실루엣 `긴 코트와 잎 묶음이 수직으로 쌓이는 실루엣` · 동작 `잎을 빛 앞에 들고 다른 손으로 기록하기` · frame 7
- **하온** (`haon`): 새벽 화덕 앞에서 빵 바구니를 품고 광장에 온기를 나누는 장면 · 실루엣 `둥근 빵 바구니와 두꺼운 앞치마의 포근한 실루엣` · 동작 `바구니를 앞으로 내밀며 고개를 크게 끄덕이기` · frame 8
- **나빈** (`navin`): 갈림길 게시판에서 접힌 지도를 펴고 여행자의 방향을 다시 잇는 장면 · 실루엣 `접힌 지도와 긴 펜이 십자 형태를 이루는 실루엣` · 동작 `지도를 한 번에 펼치며 손가락으로 길을 짚기` · frame 9
- **윤슬** (`yoonseul`): 노을길을 달려 봉인 편지를 두 손으로 안전하게 전달하는 장면 · 실루엣 `긴 리본과 편지 봉투가 뒤로 흐르는 전진형 실루엣` · 동작 `편지를 가슴에 붙이고 한 발을 크게 내딛기` · frame 10
- **모아** (`moa`): 작업대에서 빛구슬을 돌려 안쪽의 작은 별을 완성하는 장면 · 실루엣 `둥근 고글과 구슬 트레이가 얼굴 주변을 감싸는 실루엣` · 동작 `구슬을 눈높이에 들고 손목으로 천천히 돌리기` · frame 11
- **솔** (`sol`): 바람길 초입에서 바람 바구니의 리본으로 안전한 방향을 읽는 장면 · 실루엣 `바구니와 길게 날리는 리본이 좌우 균형을 만드는 실루엣` · 동작 `바구니를 들어 올리고 몸을 바람 쪽으로 기울이기` · frame 12
- **에일** (`eil`): 서재 바닥에 푸른 지도를 펼치고 아직 없는 길을 연필로 그리는 장면 · 실루엣 `큰 지도 위에 무릎을 꿇은 낮은 삼각형 실루엣` · 동작 `연필을 세워 점을 찍고 지도 가장자리를 잡기` · frame 13
- **라온** (`raon`): 잠든 작은 동물 곁에서 고양이 인형으로 조용한 밤을 지켜 주는 장면 · 실루엣 `큰 후드와 인형 꼬리가 포근한 원을 만드는 실루엣` · 동작 `인형을 품에 안고 몸을 둥글게 말기` · frame 14
- **모린** (`morin`): 작업실 처마에서 바람종과 황동 나침반의 방향을 함께 맞추는 장면 · 실루엣 `종의 수직선과 긴 코트 자락이 리듬을 만드는 실루엣` · 동작 `나침반을 수평으로 들고 종 하나를 살짝 건드리기` · frame 15
- **다온** (`daon`): 구름 찻집에서 유리 병을 흔들어 오늘의 향을 섞는 장면 · 실루엣 `둥근 병과 긴 앞치마 끈이 부드러운 곡선을 만드는 실루엣` · 동작 `병을 귀 옆에서 흔들고 향을 한 번 맡기` · frame 16
- **비오** (`biyo`): 저녁 찻집 문을 열고 찻잔 쟁반으로 지친 손님을 맞이하는 장면 · 실루엣 `넓은 소매와 쟁반이 좌우로 열리는 환대의 실루엣` · 동작 `쟁반을 낮게 내리고 먼저 자리를 권하기` · frame 17
- **루카** (`luka`): 달빛 진료소에서 푸른 약병의 빛으로 밤의 길을 살피는 장면 · 실루엣 `긴 후드와 작은 약병 불빛이 아래를 감싸는 실루엣` · 동작 `약병을 등불처럼 들고 환자의 눈높이에 몸을 낮추기` · frame 18
- **헤즈** (`hez`): 시계탑 작업대에서 작은 찻주전자 모양 부품으로 멈춘 시간을 고치는 장면 · 실루엣 `높은 고글과 톱니 공구가 머리 주변을 만드는 실루엣` · 동작 `한 손에 톱니를 올리고 다른 손으로 시간을 맞추기` · frame 19

## 동료

- **루미** (`lumi`): 별자리 기록관 · quiet · frame 0 · 유대 8에서 에필로그 · “기록은 마음이 다시 길을 찾게 해.”
- **보라** (`bora`): 온실의 돌봄지기 · kind · frame 1 · 유대 8에서 에필로그 · “함께 가꾼 시간은 쉽게 시들지 않아.”
- **타로** (`taro`): 바람길 수리공 · bold · frame 2 · 유대 8에서 에필로그 · “망가진 길도 손을 대면 다시 이어져!”

## 회차 계승 프로필

- **별읽기의 유산** (`stargazer`): 엔딩 stargazer, stargazer-master · 지혜 시작 보너스 +2 · `legacy.stargazer.title`
- **정원의 유산** (`gardener`): 엔딩 gardener, gardener-master · 공감 시작 보너스 +2 · `legacy.gardener.title`
- **길잡이의 유산** (`pathfinder`): 엔딩 pathfinder, pathfinder-master · 용기 시작 보너스 +2 · `legacy.pathfinder.title`

## 활동

- **별 관측** (`observatory`): 지혜 +3 · 피로 +1
- **정원 돌보기** (`garden`): 공감 +3 · 피로 +1
- **공방 돕기** (`workshop`): 용기 +2 · 은화 +4
- **달빛 아래 휴식** (`rest`): 피로 -2 · 성장 없음
- **장터 심부름** (`market`): 은화 +6 · 피로 +1

## 계절 목표

- **봄의 별씨앗** (`spring`): 3주차 · 지혜 ≥ 8 · 성공 보상 은화 3 · “첫 별씨앗이 싹텄다.” / “별씨앗은 아직 잠들어 있다.”
- **여름의 다리** (`summer`): 6주차 · 공감 ≥ 12 · 성공 보상 은화 4 · “서로의 속도가 하나의 다리가 되었다.” / “다리는 아직 흔들리지만 다시 건널 수 있다.”
- **가을의 편지** (`autumn`): 9주차 · 용기 ≥ 16 · 성공 보상 은화 5 · “답장을 바람에 맡길 용기가 생겼다.” / “편지는 아직 서랍 안에서 다음 계절을 기다린다.”
- **겨울의 문** (`winter`): 12주차 · 지혜 ≥ 24 · 성공 보상 은화 8 · “노아는 첫 결산의 문을 열었다.” / “문은 닫혔지만 다음 열쇠를 남겼다.”
- **얼음 아래의 씨앗** (`frost`): 15주차 · 공감 ≥ 30 · 성공 보상 은화 5 · “멈춘 계절에도 돌봄의 기록이 남았다.” / “씨앗은 아직 차가운 흙 아래에서 기다린다.”
- **돌아온 물길** (`return`): 18주차 · 공감 ≥ 36 · 성공 보상 은화 6 · “보낸 마음이 공동의 약속으로 돌아왔다.” / “답장은 아직 다음 물결을 기다린다.”
- **서로 다른 별자리** (`constellation`): 21주차 · 용기 ≥ 42 · 성공 보상 은화 7 · “서로 다른 근거가 하나의 공개 지도가 되었다.” / “지도에는 아직 지워지지 않은 빈칸이 남았다.”
- **이름 붙일 수 없는 지평** (`horizon`): 24주차 · 용기 ≥ 48 · 성공 보상 은화 10 · “노아는 다음 사람이 다시 검증할 지평을 남겼다.” / “지평은 닫히지 않았고 다음 회차의 질문이 되었다.”
- **첫 물길의 약속** (`waterline`): 27주차 · 용기 ≥ 30 · 성공 보상 은화 5 · “빈 터에 첫 물길이 이어졌다.” / “물길은 아직 다음 손을 기다린다.”
- **공정한 몫의 시간** (`fair-share`): 30주차 · 공감 ≥ 40 · 성공 보상 은화 5 · “보이지 않던 노동도 하루의 일부가 되었다.” / “장부의 빈칸이 아직 누군가를 기다린다.”
- **열린 기억의 방** (`memory-house`): 33주차 · 지혜 ≥ 48 · 성공 보상 은화 6 · “기억은 닫힌 상자가 아니라 다시 찾을 길이 되었다.” / “이름 없는 상자는 아직 빛을 기다린다.”
- **건너온 답** (`far-shore`): 36주차 · 용기 ≥ 56 · 성공 보상 은화 6 · “먼 영지의 답이 루멘의 규칙을 다시 고쳤다.” / “두 물길은 아직 서로의 속도를 배우는 중이다.”
- **빈칸의 지도** (`blank-map`): 39주차 · 지혜 ≥ 64 · 성공 보상 은화 7 · “모른다는 표시가 함께 걷는 출발점이 되었다.” / “지도에는 아직 혼자 건너야 할 빈칸이 남았다.”
- **공동의 규칙** (`commons`): 42주차 · 공감 ≥ 72 · 성공 보상 은화 7 · “가장 작은 목소리까지 규칙에 들어왔다.” / “합의 밖의 목소리가 아직 문을 두드린다.”
- **귀환의 정원** (`returning-garden`): 45주차 · 공감 ≥ 80 · 성공 보상 은화 8 · “처음의 씨앗이 다음 사람의 꽃이 되었다.” / “정원은 아직 떠남과 머묾의 자리를 고르는 중이다.”
- **넘겨지는 지평** (`handoff`): 48주차 · 용기 ≥ 88 · 성공 보상 은화 10 · “노아는 다음 사람이 다시 시작할 첫걸음을 남겼다.” / “지평은 닫히지 않았고 다음 기록을 기다린다.”

## 사건

### 2주차 · 새벽 우편함

아직 해가 오르기 전, 낯선 편지 한 장이 도착했다. 누구와 먼저 읽을까?
- 루미에게 별의 이름을 묻는다: 지혜 +1, 은화 0, lumi 유대 +2 · “이름을 부르면 낯선 것도 조금 가까워져.”
- 마을 게시판에 소식을 나눈다: 공감 +1, 은화 1, bora 유대 +2, 기억 legacy-star 필요 · “좋은 소식은 나눌수록 오래 남아.”
### 3주차 · 비가 오던 밤

마을의 등불이 꺼졌다. 노아는 누구의 손을 먼저 잡을까?
- 아이들과 등불을 나눈다: 공감 +2, 은화 -1, bora 유대 +4 · “작은 빛도 함께라면 길이 돼.”
- 별을 읽어 길을 찾는다: 지혜 +2, 은화 0, lumi 유대 +4 · “하늘은 아직 방향을 숨기지 않았어.”
### 4주차 · 온실의 작은 균열

온실 지붕에 작은 금이 갔다. 누구의 방식으로 봄을 지킬까?
- 루미에게 별빛의 각도를 묻는다: 지혜 +1, 은화 0, lumi 유대 +2 · “빛이 머무는 각도를 알면, 금도 길이 될 수 있어.”
- 보라와 천을 덧댄다: 공감 +2, 은화 -1, bora 유대 +2 · “함께 덧댄 자리는 오래 버틸 거야.”
### 5주차 · 달빛 시장 산책

짧은 휴일이 생겼다. 은화를 써서 누구와 루멘 밖의 표정을 만날까?
- 루미와 오래된 지도를 찾는다: 지혜 +1, 은화 -2, lumi 유대 +3 · “지도 가장자리에도 다음 길의 단서가 있어.”
- 보라와 씨앗 장터를 둘러본다: 공감 +1, 은화 -2, bora 유대 +3 · “같은 씨앗을 고르면 내일의 정원도 닮아갈 거야.”
### 6주차 · 강을 건너는 법

낡은 다리가 흔들린다. 이번에는 어떤 마음으로 건널까?
- 먼저 발을 내딛는다: 용기 +2, 은화 0, taro 유대 +4, 조건 용기 ≥ 8 · “떨려도, 한 걸음은 내 것이야.”
- 모두의 속도를 맞춘다: 공감 +2, 은화 1, bora 유대 +4 · “같은 박자로 걸으면 강도 덜 무서워.”
### 7주차 · 지도에 없는 종

저녁마다 지도 밖에서 종소리가 들린다. 노아는 어디에 귀를 기울일까?
- 루미와 소리의 간격을 기록한다: 지혜 +2, 은화 1, lumi 유대 +2 · “간격을 기록하면 보이지 않는 길도 드러날 거야.”
- 타로와 종이 있는 곳을 찾아간다: 용기 +2, 은화 -1, taro 유대 +3, 조건 용기 ≥ 8 · “들리는 곳까지 직접 가보자!”
### 8주차 · 바람이 멎은 오후

풍차가 멈춰 온실의 창이 닫히지 않는다. 누구와 손을 맞출까?
- 타로와 풍차를 고친다: 용기 +2, 은화 1, taro 유대 +2, 기억 windmill-repair 기록 · “멈춘 바람도 손을 대면 다시 움직여.”
- 보라와 타로의 말을 함께 듣는다: 공감 +1, 은화 -2, bora 유대 +1, 기억 windmill-truce 기록 · “서로의 바람을 들으면 다시 같은 길을 만들 수 있어.”
### 9주차 · 바람의 편지

먼 영지에서 도움을 청하는 편지가 도착했다. 노아는 어떤 답을 보낼까?
- 답장을 꼼꼼히 기록한다: 지혜 +2, 은화 1, lumi 유대 +4 · “정확한 말은 먼 곳에서도 길이 될 거야.”
- 직접 찾아가겠다고 약속한다: 용기 +2, 은화 -2, taro 유대 +4, 조건 용기 ≥ 14 · “기다리게 하지 않을게. 내가 갈게!”
### 10주차 · 축제 전야

마을 축제의 마지막 준비가 남았다. 노아는 무엇을 먼저 챙길까?
- 모두가 쉴 자리를 만든다: 공감 +2, 은화 -1, bora 유대 +4 · “즐거운 날일수록 쉬어갈 자리도 필요해.”
- 새로운 무대를 직접 세운다: 용기 +2, 은화 0, taro 유대 +4, 조건 용기 ≥ 12, 기억 windmill-repair 필요 · “조금 삐뚤어도 우리 손으로 세워보자.”
### 11주차 · 바람 언덕의 약속

엔딩 전 마지막 휴일이다. 누구와 걸은 시간이 다음 계절의 방향이 될까?
- 타로와 이름 없는 길을 걷는다: 용기 +1, 은화 -2, taro 유대 +3, 관계 taro 유대 ≥ 2 · “길의 이름은 걸은 뒤에 붙여도 늦지 않아.”
- 루미와 별빛 표식을 남긴다: 지혜 +1, 은화 -2, lumi 유대 +3 · “돌아올 표식이 있으면 멀리 가도 길을 잃지 않아.”
### 12주차 · 첫 결산의 밤

첫 열두 주의 기록이 한 장의 장부로 묶였다. 숫자만 남길지, 그 숫자를 만든 목소리까지 남길지 결정해야 한다.
- 루미와 근거의 순서를 기록한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 first-ledger 기록 · “결과만 적지 말고, 그 결과에 닿은 발걸음도 적자.”
- 보라와 모두의 목소리를 장부에 남긴다: 공감 +2, 은화 0, bora 유대 +3, 기억 first-ledger 기록 · “기록에 이름을 올리면 누구도 혼자 책임지지 않아도 돼.”
### 13주차 · 얼음 아래의 온실

밤새 내린 서리가 온실의 유리를 희게 만들었다. 안쪽의 씨앗은 빛보다 먼저 기다리는 법을 가르친다.
- 보라와 온도를 낮춰 씨앗을 지킨다: 공감 +2, 은화 -1, bora 유대 +3 · “살리는 일에는 때로 자라지 않게 기다리는 용기도 필요해.”
- 타로와 얼음 틀을 고친다: 용기 +2, 은화 1, taro 유대 +3 · “멈춘 장치도 한 조각씩 보면 다시 움직일 수 있어.”
### 14주차 · 겨울 시장의 빈 의자

시장 한가운데 빈 의자가 놓였다. 떠난 사람을 기다리는 자리인지, 새로 올 사람을 위한 자리인지 아직 아무도 모른다.
- 타로와 의자의 주인을 찾아 나선다: 용기 +2, 은화 -2, taro 유대 +3 · “빈자리를 두려워하지 말고 먼저 물어보자.”
- 루미와 기다림의 시간을 기록한다: 지혜 +2, 은화 1, lumi 유대 +3 · “기다린 시간도 누군가 돌아올 수 있게 하는 지도야.”
### 15주차 · 씨앗 저장고의 문

강 건너 저장고의 문에는 누구의 도장도 찍혀 있지 않다. 노아는 문을 열기보다 먼저, 열어도 되는 이유를 함께 찾아야 한다.
- 루미와 공개 조건을 적어 둔다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 seed-vault 기록 · “열쇠보다 먼저, 누구나 확인할 수 있는 조건을 만들자.”
- 보라와 저장고의 씨앗을 나눈다: 공감 +2, 은화 -1, bora 유대 +3, 기억 seed-vault 기록 · “나눌 기준을 함께 정하면 씨앗은 한 사람의 것이 아니야.”
### 16주차 · 돌아온 편지의 뒷면

먼 영지에서 답장이 돌아왔다. 고맙다는 인사 뒤에는 루멘의 선택이 예상보다 많은 사람에게 닿았다는 소식이 적혀 있다.
- 보라와 받은 도움을 목록으로 만든다: 공감 +2, 은화 1, bora 유대 +3 · “도움을 받은 이름을 기억해야 다음 도움도 공평해져.”
- 타로와 답장의 길을 직접 확인한다: 용기 +2, 은화 -1, taro 유대 +3 · “편지가 도착했다면 그 길도 다시 걸을 수 있어.”
### 17주차 · 두 손으로 드는 문

온실의 새 문은 혼자 들기에는 무겁다. 서로 다른 방식으로 고친 사람들이 같은 손잡이를 잡을 수 있을까?
- 타로와 경첩을 다시 맞춘다: 용기 +2, 은화 1, taro 유대 +3 · “잘못 맞춘 나사는 빼고, 다시 맞추면 돼.”
- 루미와 두 설계의 차이를 남긴다: 지혜 +2, 은화 0, lumi 유대 +3 · “다른 설계는 오류가 아니라 다음 선택의 근거가 될 수 있어.”
### 18주차 · 공동 우물의 약속

시장은 공동 우물의 물을 누구에게 먼저 줄지로 술렁인다. 규칙을 정하는 사람과 물을 길어 올리는 사람의 목소리가 모두 필요하다.
- 루미와 배분 순서를 공개한다: 지혜 +2, 은화 1, lumi 유대 +3 · “순서를 모두가 볼 수 있으면 기다림도 약속이 돼.”
- 보라와 가장 급한 집부터 살핀다: 공감 +2, 은화 -1, bora 유대 +3 · “같은 규칙도 지금 가장 목마른 사람을 볼 수 있어야 해.”
### 19주차 · 열린 기록의 날

첫 결산 장부를 모두에게 보여 주는 날이 왔다. 기록을 읽는 사람마다 다른 빈칸을 발견하고, 노아는 그 빈칸을 숨길지 질문으로 남길지 선택한다.
- 보라와 빈칸을 함께 채울 모임을 연다: 공감 +2, 은화 -1, bora 유대 +3, 기억 first-ledger 필요 · “모르는 것을 함께 말할 수 있어야 기록이 살아 있어.”
- 타로와 빈칸까지 표시한 지도를 배포한다: 용기 +2, 은화 0, taro 유대 +3, 기억 first-ledger 필요 · “모두가 빈칸을 보면 다음 길은 혼자 찾지 않아도 돼.”
### 20주차 · 세 장의 지도

루미의 별지도, 보라의 씨앗지도, 타로의 바람지도가 한 테이블 위에 놓였다. 서로 맞지 않는 선을 지우지 않고 겹쳐 읽어야 한다.
- 타로와 실제 길의 표식을 확인한다: 용기 +2, 은화 -1, taro 유대 +3 · “지도는 발밑의 돌과 만날 때 비로소 길이 돼.”
- 루미와 겹친 선의 공통점을 찾는다: 지혜 +2, 은화 1, lumi 유대 +3 · “다른 선이 만나는 곳에는 함께 확인할 이유가 있어.”
### 21주차 · 서로 다른 별자리의 밤

완성된 지도라고 믿었던 장부에서 세 사람의 판단이 갈라진다. 누구의 답을 고르는 대신, 각 답이 어디서 시작됐는지 살펴야 한다.
- 루미와 판단의 근거를 나란히 놓는다: 지혜 +2, 은화 1, lumi 유대 +3 · “정답보다 먼저, 서로 같은 별을 보고 있는지 확인하자.”
- 보라와 가장 작은 합의를 실험한다: 공감 +2, 은화 -1, bora 유대 +3 · “큰 약속은 작은 합의가 안전하게 이어질 때 자라나.”
### 22주차 · 지평선 시장

루멘의 가장자리에서 새 항로를 여는 장터가 열린다. 떠나는 사람과 남는 사람이 같은 가격표를 읽을 수 있어야 한다.
- 보라와 남는 사람의 자리를 마련한다: 공감 +2, 은화 -1, bora 유대 +3 · “떠남이 가능하려면 남아 있는 자리도 안전해야 해.”
- 타로와 새 항로의 첫 표식을 세운다: 용기 +2, 은화 0, taro 유대 +3 · “첫 표식은 목적지가 아니라 다시 찾을 수 있다는 약속이야.”
### 23주차 · 마지막 표식

엔딩 전 마지막 밤, 강 건너 바람길에 표식을 하나만 남길 수 있다. 노아는 자신의 이름보다 다음 사람이 확인할 규칙을 선택한다.
- 타로와 누구나 볼 수 있는 표식을 세운다: 용기 +2, 은화 -1, taro 유대 +3, 기억 horizon-mark 기록 · “내가 없어도 다시 찾을 수 있는 길이어야 해.”
- 루미와 마지막 근거를 별자리로 남긴다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 horizon-mark 기록 · “마지막 기록은 끝맺음이 아니라 다음 검증의 시작이야.”
### 24주차 · 첫 지평의 표식

첫 결산의 끝에서, 노아는 다음 계절로 건너갈 표식을 남긴다.
- 루미와 근거의 별자리를 새긴다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 first-horizon 기록 · “첫 지평은 결론이 아니라 다시 읽을 수 있는 방향이어야 해.”
- 타로와 강 건너 표식을 세운다: 용기 +2, 은화 -1, taro 유대 +3, 기억 first-horizon 기록 · “다음 사람의 발이 닿을 곳을 먼저 약속하자.”
### 25주차 · 씨앗이 된 답장

먼 영지의 답장에는 감사 대신 씨앗 한 봉지가 들어 있다. 빚일까, 약속일까?
- 루미와 답장의 조건을 기록한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 first-ledger 필요, 기억 return-debt 기록 · “선물도 조건을 읽어야 오래 지킬 수 있어.”
- 보라와 씨앗을 마을에 나눈다: 공감 +2, 은화 -1, bora 유대 +3, 기억 return-seed 기록 · “받은 것을 나누면 빚은 함께 지는 약속이 돼.”
### 26주차 · 강 건너 빈 터

강 건너의 빈 터에는 오래된 말뚝만 남았다. 누가 무엇을 다시 시작할까?
- 타로와 새 물길을 시험한다: 용기 +2, 은화 -1, taro 유대 +3, 조건 용기 ≥ 20, 기억 waterway 기록 · “빈 터는 실패한 곳이 아니라 아직 시험하지 않은 곳이야.”
- 보라와 먼저 머물 사람을 묻는다: 공감 +2, 은화 1, bora 유대 +3 · “땅보다 먼저, 여기서 살아갈 사람의 목소리를 들어야 해.”
### 27주차 · 새싹의 증인

첫 씨앗이 싹을 틔웠지만, 누구의 손이 이 장면을 만들었는지는 서로 다르게 기억된다.
- 루미와 손의 순서를 기록한다: 지혜 +1, 은화 1, lumi 유대 +3, 기억 return-debt 필요, 기억 witness-ledger 기록 · “한 사람의 공이 아니라 이어진 손을 남기자.”
- 보라와 함께 첫 수확을 나눈다: 공감 +2, 은화 0, bora 유대 +4, 기억 return-seed 필요, 기억 witness-garden 기록 · “기억이 달라도 함께 먹은 맛은 다음 약속이 될 수 있어.”
### 28주차 · 작업장의 영수증

공방의 장부에서 사라진 시간 세 칸이 발견된다. 기록하지 않은 노동도 빚으로 남을까?
- 루미와 빈 시간을 공개한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 first-ledger 필요, 기억 labor-audit 기록 · “비어 있는 칸도 숨기지 않아야 다음 계산이 정직해져.”
- 타로와 직접 작업량을 다시 잰다: 용기 +2, 은화 -1, taro 유대 +3 · “틀린 계산은 손으로 다시 확인할 수 있어.”
### 29주차 · 비어 있는 수레

시장에 도착한 수레가 비어 있다. 모두가 필요한 것을 말하지만, 은화는 하나뿐이다.
- 보라와 가장 급한 집을 먼저 찾는다: 공감 +2, 은화 -1, bora 유대 +4, 기억 need-first 기록 · “같은 양을 나누는 것과 같은 마음으로 보는 것은 다를 수 있어.”
- 타로와 다음 수레를 직접 부른다: 용기 +2, 은화 0, taro 유대 +3, 기억 next-cart 기록 · “이번에 부족했다면 다음 길을 지금 만들자.”
### 30주차 · 돌봄의 노동

온실의 가장 늦은 시간에 누군가의 손이 먼저 지쳐 있었다. 돌봄은 누구의 일정에 적힐까?
- 보라와 돌봄 시간을 일정에 넣는다: 공감 +2, 은화 -1, bora 유대 +4, 기억 care-counted 기록 · “보이지 않는 일도 하루를 바꾼다면 기록되어야 해.”
- 루미와 늦은 손의 패턴을 찾는다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 labor-audit 필요 · “반복되는 피로에는 개인의 약함이 아닌 규칙이 있을 수 있어.”
### 31주차 · 기억의 집

기록관 뒤편에서 오래된 방이 열린다. 이름 없는 상자들이 루멘의 과거를 기다리고 있다.
- 루미와 상자마다 날짜를 붙인다: 지혜 +2, 은화 0, lumi 유대 +4, 기억 memory-house 기록 · “기억은 완벽하지 않아도 다시 찾을 표식이 필요해.”
- 보라와 상자의 주인을 기다린다: 공감 +2, 은화 -1, bora 유대 +4, 기억 memory-table 기록 · “이름을 대신 정하지 않는 것도 기억을 돌보는 일이야.”
### 32주차 · 지워진 이름

강 건너 표식 하나에서 이름만 지워져 있다. 지운 사람과 남겨진 사람의 이유가 다르다.
- 타로와 새 이름을 묻는다: 용기 +2, 은화 -1, taro 유대 +4, 기억 memory-house 필요 · “지워진 자리에 내 이름을 덧쓰지 말고 먼저 물어보자.”
- 보라와 빈 표식을 그대로 보존한다: 공감 +2, 은화 1, bora 유대 +3, 기억 blank-name 기록 · “빈칸도 누군가 돌아올 수 있는 자리로 남겨 두자.”
### 33주차 · 기록관의 등불

등불이 꺼지면 같은 장부도 서로 다르게 읽힌다. 노아는 빛의 책임을 정해야 한다.
- 루미와 공개 열람 시간을 만든다: 지혜 +2, 은화 -1, lumi 유대 +4, 조건 지혜 ≥ 30, 기억 open-reading 기록 · “빛을 독점하지 않으면 판단도 서로 확인할 수 있어.”
- 타로와 등불을 여러 곳에 나눈다: 용기 +2, 은화 1, taro 유대 +3, 기억 many-lanterns 기록 · “한 등불이 꺼져도 길 전체가 어두워지지 않게 하자.”
### 34주차 · 먼 영지의 그림자

두 번째 편지는 도움을 청하지 않는다. 루멘의 선택이 다른 마을의 규칙으로 번졌다는 소식이다.
- 타로와 현장을 직접 확인한다: 용기 +2, 은화 -2, taro 유대 +4, 기억 waterway 필요, 기억 far-shore 기록 · “우리의 규칙이 누구를 밀어냈는지 직접 봐야 해.”
- 루미와 규칙의 전달 경로를 추적한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 rule-shadow 기록 · “좋은 의도도 전달되는 동안 다른 뜻이 될 수 있어.”
### 35주차 · 두 물결의 교차

새 물길과 오래된 물길이 만나는 곳에서, 어느 쪽도 혼자서는 마을을 채우지 못한다.
- 보라와 물을 나누는 순서를 정한다: 공감 +2, 은화 -1, bora 유대 +4, 기억 shared-water 기록 · “두 물결이 만나는 곳에는 먼저 마실 사람도 함께 정해야 해.”
- 타로와 수문을 다시 설계한다: 용기 +2, 은화 0, taro 유대 +3, 기억 sluice-plan 기록 · “흐름을 바꾸려면 막힌 곳부터 손으로 찾아야 해.”
### 36주차 · 돌아온 씨앗

첫 씨앗의 일부가 다시 루멘으로 돌아왔다. 수확은 소유가 아니라 순환의 증거가 된다.
- 보라와 귀환한 씨앗을 심는다: 공감 +2, 은화 1, bora 유대 +4, 기억 witness-garden 필요, 기억 returning-garden 기록 · “돌아온 것은 끝난 일이 아니라 다음 사람의 시작이야.”
- 루미와 씨앗의 이동을 지도에 남긴다: 지혜 +2, 은화 0, lumi 유대 +3, 기억 seed-route 기록 · “순환을 보이게 하면 다음 약속도 다시 확인할 수 있어.”
### 37주차 · 불완전한 지도

세 장의 지도에는 모두 같은 빈칸이 있다. 지우지 않고 함께 읽는 방법을 선택해야 한다.
- 루미와 빈칸을 측정값으로 남긴다: 지혜 +2, 은화 1, lumi 유대 +4, 기억 first-ledger 필요, 기억 blank-map 기록 · “모른다는 표시도 다음 판단의 정확한 출발점이야.”
- 타로와 빈칸까지 직접 걸어 본다: 용기 +2, 은화 -1, taro 유대 +3, 기억 horizon-mark 필요, 기억 blank-walk 기록 · “지도가 끝난 곳에서 길이 시작될 수도 있어.”
### 38주차 · 북쪽 문지기

새 항로의 문 앞에서 문지기는 목적지가 아니라 돌아오는 방법을 묻는다.
- 타로와 돌아올 표식을 세운다: 용기 +2, 은화 -1, taro 유대 +4, 조건 용기 ≥ 35, 기억 return-marker 기록 · “떠나는 용기에는 돌아와 확인할 약속이 따라야 해.”
- 보라와 남는 사람의 문을 연다: 공감 +2, 은화 1, bora 유대 +3, 기억 stay-gate 기록 · “모든 사람이 떠날 수 없다면 남는 선택도 길이어야 해.”
### 39주차 · 나침반의 회의

세 사람의 나침반이 서로 다른 북쪽을 가리킨다. 하나를 고르는 대신 기준을 공개할 수 있을까?
- 루미와 측정 기준을 공개한다: 지혜 +2, 은화 0, lumi 유대 +3, 기억 public-map 기록 · “나침반보다 먼저, 나침반을 읽는 법을 함께 보여 주자.”
- 보라와 서로 다른 북쪽을 들어 본다: 공감 +2, 은화 -1, bora 유대 +4 · “같은 곳을 보지 않아도 함께 서 있을 수 있어.”
### 40주차 · 선택의 의회

사람들은 노아에게 결정을 맡기려 한다. 노아는 대신 결정하는 법이 아니라 함께 결정하는 장면을 연다.
- 보라와 가장 작은 합의를 시험한다: 공감 +2, 은화 -1, bora 유대 +4, 기억 first-ledger 필요, 기억 small-agreement 기록 · “모두를 만족시키기 전에 함께 지킬 한 문장을 찾자.”
- 타로와 결정권을 분산한다: 용기 +2, 은화 1, taro 유대 +3, 기억 shared-rule 기록 · “책임을 나누려면 판단할 자리도 나눠야 해.”
### 41주차 · 가장 작은 목소리

회의가 끝난 뒤에도 한 사람은 말하지 못했다. 합의가 침묵을 세어 주는지 확인해야 한다.
- 보라와 말하지 못한 사람을 기다린다: 공감 +2, 은화 0, bora 유대 +4, 기억 quiet-voice 기록 · “답을 재촉하지 않는 시간도 돌봄의 규칙에 넣자.”
- 루미와 침묵이 생긴 순간을 기록한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 silence-record 기록 · “침묵의 원인을 모르면 합의의 숫자도 믿을 수 없어.”
### 42주차 · 공동 규칙의 날

새 규칙을 벽에 붙이는 날이다. 규칙은 강할수록 짧아야 하고, 짧을수록 다시 읽혀야 한다.
- 루미와 검증 절차를 한 줄로 쓴다: 지혜 +2, 은화 1, lumi 유대 +4, 기억 first-ledger 필요, 기억 public-rule 기록 · “누구나 다시 확인할 수 있어야 규칙이 사람보다 오래 살아.”
- 타로와 규칙을 현장에서 시험한다: 용기 +2, 은화 -1, taro 유대 +4, 기억 field-rule 기록 · “벽의 문장은 발밑의 돌을 만날 때 진짜가 돼.”
### 43주차 · 별씨앗의 귀환

처음 도착했던 씨앗들이 마침내 같은 온실에서 꽃이 되었다. 시작의 의미가 바뀐다.
- 보라와 꽃을 모두의 이름으로 부른다: 공감 +2, 은화 -1, bora 유대 +4, 기억 witness-garden 필요, 기억 flower-names 기록 · “시작을 기억하는 가장 좋은 방법은 다음 사람의 이름을 함께 부르는 거야.”
- 루미와 발아의 조건을 공개한다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 flower-record 기록 · “기적처럼 보인 일도 조건을 나누면 다시 만날 수 있어.”
### 44주차 · 떠나는 장터

새 항로를 따라 떠날 사람들의 장터가 열린다. 떠남을 돕는 일에도 남겨진 물건이 필요하다.
- 타로와 여행 짐의 기준을 세운다: 용기 +2, 은화 -2, taro 유대 +4, 기억 departure-pack 기록 · “가볍게 떠나는 것과 안전하게 떠나는 것은 함께 계산해야 해.”
- 보라와 남은 물건의 새 주인을 찾는다: 공감 +2, 은화 1, bora 유대 +3, 기억 left-behind 기록 · “떠난 자리도 누군가 다시 살아갈 수 있는 자리로 남겨 두자.”
### 45주차 · 이름을 다시 심는 날

기억의 집에서 돌아온 이름들이 온실의 작은 표지판이 된다. 이름은 소유가 아니라 초대가 된다.
- 보라와 이름의 주인에게 먼저 묻는다: 공감 +2, 은화 0, bora 유대 +4, 기억 memory-table 필요, 기억 named-garden 기록 · “불러 주는 일도 허락을 기다릴 때 더 따뜻해져.”
- 루미와 이름이 바뀐 기록을 남긴다: 지혜 +2, 은화 1, lumi 유대 +3, 기억 name-history 기록 · “변한 이름까지 남겨야 한 사람을 한 모습에 가두지 않아.”
### 46주차 · 다음 여행자의 짐

노아보다 어린 여행자가 길의 표식을 읽고 있다. 누군가의 답을 대신 정해 주지 않는 법을 배운다.
- 타로와 길의 위험을 숨기지 않는다: 용기 +2, 은화 -1, taro 유대 +4, 기억 horizon-mark 필요, 기억 risk-shared 기록 · “안전한 길은 위험이 없는 길이 아니라 위험을 함께 아는 길이야.”
- 루미와 읽는 순서만 건넨다: 지혜 +2, 은화 0, lumi 유대 +3, 기억 reading-order 기록 · “답을 건네는 대신 다시 판단할 순서를 건네자.”
### 47주차 · 넘겨지는 장부

장부를 다음 기록관에게 넘기는 날이다. 마지막 페이지보다 첫 페이지를 다시 읽어야 한다.
- 루미와 틀린 기록도 함께 넘긴다: 지혜 +2, 은화 1, lumi 유대 +4, 기억 public-rule 필요, 기억 handoff-open 기록 · “다음 사람이 다시 확인하려면 우리가 틀린 자리도 필요해.”
- 보라와 장부를 읽을 사람을 초대한다: 공감 +2, 은화 -1, bora 유대 +4, 기억 handoff-circle 기록 · “장부가 혼자 닫히지 않도록 읽는 사람을 함께 남기자.”
### 48주차 · 다음 사람의 첫걸음

마지막 주의 강바람이 분다. 노아가 남길 것은 정답이 아니라 다시 시작할 수 있는 첫걸음이다.
- 타로와 첫걸음의 표식을 세운다: 용기 +2, 은화 -1, taro 유대 +4, 기억 final-marker 기록 · “내가 없어도 다시 찾을 수 있다면, 이 길은 끝나지 않아.”
- 루미와 첫 질문을 남긴다: 지혜 +2, 은화 1, lumi 유대 +4, 기억 public-map 필요, 기억 final-question 기록 · “좋은 기록은 마지막 답보다 다음 질문을 오래 살려.”

## 사이드 장면·활동 미니 이벤트·동료 독립 장면

본편 47개와 사이드 장면 24개를 합쳐 71개의 authored scene을 보유한다. 사이드 장면은 본편 주차를 덮어쓰지 않고 독립 선택·기억 trace로 연결된다.
- **꺼진 등불의 색인** (`sideArchiveLantern`) · archive · exploration / `clue-sort` · 단서를 색·시간·사람 중 하나의 순서로 정렬한다. · 정렬 방식은 이후 기록을 읽는 루틴으로 남는다.
- **비가 늦은 온실** (`sideGreenhouseRain`) · greenhouse · resource-crisis / `water-ration` · 물의 양보다 기다린 시간과 회복 가능성을 비교한다. · 물 배분표가 자원 위기에서 다시 쓸 수 있는 규칙이 된다.
- **한 닢의 표식** (`sideMarketToken`) · market · resource-crisis / `token-budget` · 지금의 만족보다 다음 주의 선택 가능성을 계산한다. · 마지막 한 닢을 쓴 방향이 자원관리 사건의 기준선이 된다.
- **비어 있는 서랍** (`sideArchiveIndex`) · archive · resource-crisis / `resource-draft` · 은화와 보존 공간을 함께 계산해야 한다. · 무엇을 먼저 보존했는지가 기록의 빈칸으로 표시된다.
- **구름 뒤의 작은 별** (`sideObservatoryCloud`) · observatory · exploration / `cloud-window` · 보이는 것과 보이지 않는 것을 같은 지도에 표시한다. · 가려진 별도 관측 가능한 대상이라는 기준을 남긴다.
- **끊어진 밧줄의 지도** (`sideRiverRope`) · river-road · exploration / `route-memory` · 물살·거리·돌아올 표식을 함께 기억해야 한다. · 선택한 매듭이 강 건너 탐험의 첫 기준점이 된다.
- **씨앗 이름 맞추기** (`sideGreenhouseSeed`) · greenhouse · mini-game / `seed-match` · 단서 두 개만 사용해 씨앗과 자리를 맞춘다. · 맞춘 단서가 이후 수확의 이름과 보상에 남는다.
- **채석장의 메아리** (`sideQuarryEcho`) · quarry · exploration / `echo-map` · 소리의 간격과 발걸음의 위치를 겹쳐 본다. · 메아리의 간격이 탐험 지도의 새로운 눈금이 된다.
- **저울의 세 칸** (`sideMarketScale`) · market · mini-game / `fair-scale` · 세 번의 측정 중 두 번 이상 같은 기준을 찾아야 한다. · 측정 기준은 장터의 가격과 신뢰를 함께 바꾼다.
- **두 목소리의 여백** (`sideArchiveNight`) · archive · companion-pair / `paired-reading` · 두 동료의 해석을 겹치지 않게 남긴다. · 한 문장에 두 개의 근거가 붙어 다음 사건의 조건이 된다.
- **물결의 세 박자** (`sideRiverTide`) · river-road · mini-game / `tide-timing` · 멈춤·건넘·귀환의 박자를 기억하는 미니게임이다. · 맞춘 박자가 이후 위기 상황의 피로 비용을 낮춘다.
- **금 간 렌즈** (`sideObservatoryLens`) · observatory · resource-crisis / `lens-repair` · 정확도와 기록의 연속성을 자원으로 비교한다. · 금 간 시야의 한계가 판정 영수증에 표시된다.
- **흙 아래의 편지** (`sideGreenhouseCompost`) · greenhouse · exploration / `soil-layer` · 흙의 층과 편지의 접힌 방향을 함께 조사한다. · 편지의 출처는 기억이 아니라 조사 가능한 단서로 남는다.
- **무거운 돌 하나** (`sideQuarryLift`) · quarry · resource-crisis / `load-balance` · 힘·피로·돌아올 자원을 함께 배분한다. · 돌을 옮긴 순서가 동료 조합의 위기 대응 기록으로 남는다.
- **소문이 지나간 자리** (`sideMarketQuiet`) · market · exploration / `rumour-map` · 소문을 믿음·피해·확인 요청의 세 표식으로 나눈다. · 소문을 다루는 표식이 이후 공개 회의의 입구가 된다.
- **증인의 자리** (`sideArchiveWitness`) · archive · exploration / `witness-chain` · 증언의 순서를 세 명의 증인에게 다시 확인한다. · 증인의 순서가 누락을 찾는 탐험 규칙이 된다.
- **표식에 쓸 재료** (`sideRiverMarker`) · river-road · resource-crisis / `marker-budget` · 은화와 탐험 가능성을 한 번에 비교한다. · 재료 선택은 지도의 빈칸을 공개하는 방식으로 되돌아온다.
- **두 번 울린 신호** (`sideObservatorySignal`) · observatory · companion-pair / `signal-pattern` · 신호의 순서와 실제 발걸음의 순서를 맞춘다. · 짝을 이룬 신호는 후반 탐험의 분기 조건이 된다.
- **돌의 무늬 읽기** (`sideQuarryLedger`) · quarry · mini-game / `stone-pattern` · 무늬·소리·빛 중 두 단서를 선택한다. · 고른 단서가 채석장 탈출 경로의 공개 기준이 된다.
- **새벽 종의 순서** (`sideGreenhouseBell`) · greenhouse · companion-pair / `care-rotation` · 일어나는 순서와 회복 시간을 작은 표로 맞춘다. · 돌봄의 순환표가 동료 조합의 독립 기록이 된다.
- **시장 끝의 계약서** (`sideMarketReturn`) · market · companion-pair / `shared-contract` · 계약의 공통 조항과 서로 양보할 수 없는 조항을 분리한다. · 합쳐지지 않은 조항도 다음 사람의 협상 기록으로 남는다.
- **새벽의 별자리 잇기** (`sideObservatoryDawn`) · observatory · mini-game / `constellation-trace` · 세 점 중 두 점의 근거를 선택하고 마지막 점은 열어 둔다. · 완성하지 않은 점 하나가 다음 사람의 탐험 초대가 된다.
- **강 건너 첫 질문** (`sideRiverQuestion`) · river-road · companion-pair / `handoff-crossing` · 돌아올 사람도 다시 물을 수 있는 문장을 만든다. · 첫 질문은 넘겨지는 지평의 독립 에필로그로 남는다.
- **세 손의 돌무더기** (`sideQuarryExit`) · quarry · companion-pair / `handoff-cairn` · 세 돌의 위치·이름·돌아올 방향을 함께 기록한다. · 세 손의 돌무더기가 여섯 장소를 잇는 마지막 탐험 증거가 된다.

활동 미니 이벤트 10개:
- **안개 속 첫 별** (`observatory`): 관측소의 지붕이 안개에 잠겼다. · “보이지 않는 날도 하늘의 일부로 적어 두자.”
- **늦은 별자리** (`observatory`): 별 하나가 예상보다 늦게 나타났다. · “늦었다는 사실이 틀렸다는 뜻은 아니야.”
- **얇은 잎의 방향** (`garden`): 얇은 잎 하나가 바람을 거슬러 자랐다. · “약한 방향도 계속되면 정원이 기억해.”
- **함께 든 물통** (`garden`): 물통의 손잡이를 두 사람이 함께 잡았다. · “무게가 반으로 줄지 않아도 혼자 들지 않을 수 있어.”
- **느슨한 못** (`workshop`): 작은 못 하나가 계속 흔들렸다. · “작은 흔들림을 고치면 다음 실패가 덜 커져.”
- **남은 조각** (`workshop`): 버려질 조각에서 맞는 모서리를 찾았다. · “남은 것은 낭비가 아니라 다음 설계의 단서가 될 수 있어.”
- **창가의 쉼표** (`rest`): 창가의 빛이 하루의 속도를 늦췄다. · “멈춤도 다음 선택을 오래 보게 하는 활동이야.”
- **읽지 않은 쪽** (`rest`): 읽지 않은 쪽을 남겨 둔 채 책을 덮었다. · “모든 빈칸을 오늘 채우지 않아도 기록은 이어져.”
- **작은 거스름돈** (`market`): 상인이 거스름돈을 한 번 더 세었다. · “다시 세는 습관이 은화보다 오래 남아.”
- **따뜻한 빵의 방향** (`market`): 빵 하나가 가장 늦게 온 사람에게 먼저 갔다. · “순서를 바꾸는 작은 친절도 장터의 규칙이 돼.”

동료 독립 장면 18개:
- **첫 여백을 접는 법** (`lumi`): 루미와 노아는 빈칸을 지우지 않고 모서리를 접는다. · “빈칸이 있어야 다음 사람이 어디를 봐야 하는지 알 수 있어.”
- **느린 별의 이름** (`lumi`): 루미와 노아는 예측보다 늦게 뜬 별을 오래 바라본다. · “늦게 도착한 사실도 사실의 자리를 가질 수 있어.”
- **열린 장부의 첫 줄** (`lumi`): 루미와 노아는 누구나 읽을 수 있는 장부의 첫 줄을 비워 둔다. · “공개는 다 보여 주는 일이 아니라 다시 물을 자리를 남기는 일이야.”
- **구름의 측정값** (`lumi`): 루미와 노아는 숫자로 잡히지 않는 구름의 한계를 표시한다. · “측정 한계를 보이는 것도 정확함의 일부야.”
- **두 번 울린 신호** (`lumi`): 루미와 노아는 두 신호 사이의 간격을 지도에 남긴다. · “삭제된 시작도 다음 판단의 원인이 될 수 있어.”
- **다음 사람의 질문** (`lumi`): 루미와 노아는 마지막 장에 답 대신 질문 하나를 남긴다. · “좋은 기록은 답을 닫지 않고 다음 손을 초대해.”
- **같이 든 물통** (`bora`): 보라와 노아는 같은 물통을 두 사람이 들 수 있도록 손잡이를 고친다. · “무게가 줄지 않아도 혼자 들지 않게 만들 수 있어.”
- **기다리는 자리** (`bora`): 보라와 노아는 늦게 오는 사람이 앉을 의자를 온실 문 앞에 둔다. · “기다리는 시간도 함께 만든 하루의 일부야.”
- **첫 수확의 몫** (`bora`): 보라와 노아는 작은 첫 수확을 누구에게 먼저 건넬지 멈춰 선다. · “공정함은 모두에게 같은 조각이 아니라 기준을 함께 읽는 일이야.”
- **돌봄의 영수증** (`bora`): 보라와 노아는 보이지 않는 돌봄 시간을 장부의 빈칸에서 꺼낸다. · “기록되지 않은 수고는 없는 일이 되기 쉬워.”
- **비를 기다리는 순서** (`bora`): 보라와 노아는 비가 늦어진 온실에서 기다린 순서를 다시 부른다. · “순서도 사람의 상태를 만날 때 다시 읽어야 해.”
- **열린 정원의 문** (`bora`): 보라와 노아는 정원의 문을 잠그는 대신 누구나 볼 표식을 단다. · “열어 두는 일에도 다시 닫을 수 있는 기준이 필요해.”
- **끊어진 밧줄의 매듭** (`taro`): 타로와 노아는 강 건너 밧줄의 가장 닳은 매듭을 먼저 잡는다. · “먼저 고친 곳이 다음 사람이 믿을 발판이 돼.”
- **공방의 첫 못** (`taro`): 타로와 노아는 느슨한 못 하나를 버리지 않고 다시 박는다. · “고치는 시간도 만드는 시간의 일부로 세어 줘.”
- **지붕 위의 선** (`taro`): 타로와 노아는 구름 뒤의 별을 보기 위해 지붕 위에 선을 긋는다. · “경계는 멈추게도 하지만 어디서 다시 시작할지도 알려 줘.”
- **빈 터의 표식** (`taro`): 타로와 노아는 누군가 돌아올 높이로 빈 터에 돌을 쌓는다. · “표식은 만드는 사람보다 돌아오는 사람의 몸을 먼저 생각해야 해.”
- **돌의 무게를 나누기** (`taro`): 타로와 노아는 채석장의 돌을 혼자 들려다 다른 손을 부른다. · “용기는 혼자 버티는 힘이 아니라 손을 부르는 힘이기도 해.”
- **다음 발판** (`taro`): 타로와 노아는 마지막 길에 답 대신 발을 놓을 곳을 표시한다. · “끝난 길도 다음 발이 닿으면 다시 시작할 수 있어.”

엔딩 변형 18개:
- **흐린 별의 기록** (`stargazer.failure`): 별을 다 읽지는 못했지만, 어디가 흐렸는지는 남겼다.
- **다시 보는 별자리** (`stargazer.neutral`): 노아는 해답보다 다음 관측의 기준을 남겼다.
- **둘이 읽은 새벽** (`stargazer.relationship`): 루미와 노아는 같은 하늘을 다른 근거로 읽으며 기록을 이어 갔다.
- **계산 밖의 새벽** (`stargazer-master.failure`): 지도는 완성되지 않았고, 다음 사람이 고칠 빈칸을 남겼다.
- **열린 항로** (`stargazer-master.neutral`): 별과 바람의 주기는 누구나 다시 검증할 수 있는 길이 되었다.
- **루미의 별표** (`stargazer-master.relationship`): 루미는 마지막 장에 노아와 함께 다시 읽을 별표를 남겼다.
- **아직 마르지 않은 흙** (`gardener.failure`): 정원은 피지 않았지만, 물이 부족했던 날의 이름은 남았다.
- **함께 쉬는 정원** (`gardener.neutral`): 노아는 성장 속도보다 서로 회복할 시간을 정원에 심었다.
- **보라의 계절표** (`gardener.relationship`): 보라와 노아는 매 계절 돌봄의 순서를 다시 읽는 정원을 만들었다.
- **닫힌 온실의 불빛** (`gardener-master.failure`): 광장은 열리지 않았지만, 누구를 기다렸는지는 다음 장에 남았다.
- **공동의 온기** (`gardener-master.neutral`): 서로 다른 속도가 함께 쉴 수 있는 규칙이 되었다.
- **보라와 열린 문** (`gardener-master.relationship`): 보라와 노아는 닫아야 할 때와 열어 둘 때를 함께 기록했다.
- **길 앞의 멈춤** (`pathfinder.failure`): 첫 발은 늦었지만, 멈춰야 했던 이유가 표식으로 남았다.
- **이름 없는 길** (`pathfinder.neutral`): 노아는 모든 길에 이름을 붙이지 않고 다시 찾을 기준을 남겼다.
- **타로와 다음 발판** (`pathfinder.relationship`): 타로와 노아는 지도 밖에서도 서로 확인할 발판을 만들었다.
- **아직 건너지 않은 경계** (`pathfinder-master.failure`): 경계를 넘지 못했지만, 위험한 곳과 돌아올 곳은 표시했다.
- **다시 건널 표식** (`pathfinder-master.neutral`): 두려움이 사라지지 않아도 다음 사람이 길을 재현할 수 있게 되었다.
- **타로가 남긴 방향** (`pathfinder-master.relationship`): 타로와 노아는 마지막 표식을 다음 여행자의 출발점으로 넘겼다.

## 엔딩

- **루멘의 별읽기꾼** (`stargazer`): 지혜 ≥ 12 · 노아는 밤하늘의 결을 읽어 영지의 항로를 밝히는 사람이 되었다.
- **새벽을 계산하는 항해사** (`stargazer-master`): 지혜 ≥ 48 · 목표 spring, winter · 노아는 별과 바람의 주기를 48주 동안 기록해 누구나 판단을 다시 검증할 수 있는 지도를 남겼다.
- **마음의 정원사** (`gardener`): 공감 ≥ 12 · 노아는 서로 다른 마음이 함께 피어나는 정원을 만들었다.
- **마을의 온기를 잇는 사람** (`gardener-master`): 공감 ≥ 48 · 목표 summer, return · 노아는 다툼이 시작되기 전에 서로의 이야기를 건네고, 모든 판정의 근거를 함께 읽는 광장을 열었다.
- **새 길의 개척자** (`pathfinder`): 용기 ≥ 12 · 노아는 아직 이름 없는 길에 첫 발자국을 남겼다.
- **경계를 넘어선 선봉장** (`pathfinder-master`): 용기 ≥ 48 · 목표 autumn, constellation · 노아는 두려움을 없애지 않고도 앞으로 나아가며, 다음 사람이 같은 길을 재현할 수 있는 표식을 남겼다.
