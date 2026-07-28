<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: 31a9008f17d505a4d9217c20951d92109e0ae80a3e4567c54b37ab7e4e6c5e3b -->
<!-- source-ref: story/story.json#root -->

# 프린스 메이커 · 스토리 SSOT

바람과 별빛이 공존하는 작은 영지 루멘에서 노아는 12주 동안 스스로 선택한 내일을 걷는다.

## 12주 진행도

- **별씨앗의 도착** (`arrival`): 1–3주 · 낯선 기록과 첫 편지가 루멘의 평온을 흔든다. → 누구의 목소리를 먼저 믿을지 정한다. · 사건 2, 3주 · 목표 `spring`
  - 막 계약: 공개 별씨앗 기록과 첫 동료의 목소리를 공개한다. · 압력 stat·coins·bond · 선택 2, 3주 · 결산 `spring`
- **흔들리는 다리** (`crossing`): 4–6주 · 성장한 마음은 혼자 빠른 것보다 함께 건너는 법을 배운다. → 속도와 용기 중 오늘의 균형을 선택한다. · 사건 4, 5, 6주 · 목표 `summer`
  - 막 계약: 공개 온실과 강 건너의 협력 규칙을 공개한다. · 압력 stat·coins·bond · 선택 4, 5, 6주 · 결산 `summer`
- **먼 곳의 답장** (`reply`): 7–9주 · 루멘 밖에서 온 부탁이 노아의 안전한 일상을 부른다. → 기록할지 떠날지, 선택의 대가를 감당한다. · 사건 7, 8, 9주 · 목표 `autumn`
  - 막 계약: 공개 지도 밖의 신호와 먼 영지의 요청을 공개한다. · 압력 stat·coins·bond · 선택 7, 8, 9주 · 결산 `autumn`
- **겨울의 문턱** (`threshold`): 10–12주 · 축제의 빛 아래에서 지난 선택들이 하나의 방향으로 모인다. → 왕좌 대신 스스로 고른 내일의 문을 연다. · 사건 10, 11주 · 목표 `winter`
  - 막 계약: 공개 축제와 마지막 진로의 무대를 공개한다. · 압력 stat·coins·bond · 선택 10, 11주 · 결산 `winter`

## 대사 구성 기준

- locale 최소 키: **123** · 한 캠페인 최소 대사 줄: **7** · 최소 노출 서사 단위: **27** · 전체 authored 대사 줄: **29**
- 산식: catalog 123 = UI 13 + personality name/voice/line 9 + event title/body 20 + choice label/line 40 + companion greeting/epilogue 6 + companion route titles 3 + location names 4 + ending title/body 12 + chapter beats 12 + milestone titles 4; one route exposes at least 7 dialogue lines and 27 narrative units

## 시나리오 완전성 표본

참조 모델: **장기 성장·관계·선택·결산이 하나의 반복 가능한 생활 루프를 이루는 시나리오** (`life-sim-scenario-v1`)

| 차원 | 목표 | 현재 증적 | 검증 ref |
| --- | --- | --- | --- |
| 장기 아크 | 도입·성장·전환·결산의 4막이 시간축을 덮고 각 막에 사건과 목표가 있다 | 4 chapters / 10 events / 4 locations / 4 milestones / 4 chapter contracts / ending week 12 | `story/story.json#progression.contract` |
| 선택의 행위성 | 모든 authored choice가 스탯·은화·유대·조건 중 하나 이상을 바꾸고 trace에 남는다 | 20 event choices; outing choices trade time-budget coins for stat and bond; memory flags carry consequences | `test/story_integration_test.dart#every-authored-ending-and-event-choice-is-reachable` |
| 관계 아크 | 등장·대화·유대 임계·엔딩 에필로그의 계층이 존재한다 | 3 companions / rival conflict / reciprocal mediation flag / bond threshold / all-threshold epilogues | `story/story.json#companions` |
| 상태 피드백 | 일정의 결과가 다음 선택·계절 목표·엔딩 조건에 되돌아온다 | stats, coins, fatigue, 4 milestones and 6 endings | `test/game_core_test.dart#rules` |
| 조건과 공개 | 조건부 사건과 목표가 숨은 단절이 아니라 재플레이할 실마리로 기능한다 | 6 locked choices including bond, memory and legacy gates / 4 chapter contracts / 4 closing milestones / milestone-gated master endings | `tool/verify_game.dart#scenario-contract` |
| 재플레이 가치 | 동일 입력은 동일 결과, 다른 성장축·정책은 다른 authored 결과를 만든다 | 5 schedule policies / 4 distinct signatures / 6 endings / 3 bond route goals / route-aware collection-driven legacy unlock | `test/gameplay_metrics_test.dart#route-variety` |
| 장면 결산 | 도입·중반 사건·엔딩을 Canvas Golden으로 고정하고 대사 locale을 통과한다 | 21 Goldens / ko+en catalogs / canonical week-4 event / outing choice / rival loss and mediation recovery / bond, memory, legacy gates / ending retrospective board | `test/golden_test.dart#mediation-choice-shows-reciprocal-relationship-recovery` |
| 종결과 회고 | 엔딩이 terminal 상태·기록·새 캠페인으로 닫히며 성능 benchmark가 같은 루프를 재생한다 | terminal input contract / save v7 with memory flags / collection / deterministic event-cause retrospective / missing-goal next-run clue / SSOT campaign benchmark | `test/golden_test.dart#twelve-week-loop-resolves-to-an-ending` |

## 생성 이미지 자산

- [`assets/noa-sprite-sheet.png#hero-2-head-frames`](../assets/noa-sprite-sheet.png) · SHA-256 `1ed524abb6e4eda65e651e25ea008d31efcdebaab28b39086bb1f67a4b32581d`
- [`assets/noa-sprite-sheet-source.png#hero-chroma-key-source`](../assets/noa-sprite-sheet-source.png) · SHA-256 `5dd8207030fb83554ed7e8b420995a4d2dc8cf8a00f9ae8f54770fef61c90dd9`
- [`assets/lumen-personality-sheet.png#personality-frames`](../assets/lumen-personality-sheet.png) · SHA-256 `4f0529df6b24415f44bf18284d6ba15492838dc5bff5f6dab2c620eb97e6fb28`
- [`assets/lumen-personality-sheet-source.png#chroma-key-source`](../assets/lumen-personality-sheet-source.png) · SHA-256 `0e652df6e6a35f67bd8623c15ba23fb88d745a82ac8f083a32ea14a715b706d8`

## 폰트

- [`assets/fonts/NotoSansKR-Regular.ttf#canvas-korean-font`](../assets/fonts/NotoSansKR-Regular.ttf) · SHA-256 `c733940a7dc687142848b30a491e97138ed58dc58c4cae33c44e3ee52da411cb`

## 대사 로케일

- [`story/locales/ko.json#catalog`](../story/locales/ko.json) · SHA-256 `530b5991563279310bba3a1c9574a4e11daa0887a4de86f09f14c225558d2e87`
- [`story/locales/en.json#catalog`](../story/locales/en.json) · SHA-256 `e9b1a56d32599705b50882d88385ccdbf7306e9ae32b0730b9549d37062f1448`

## 성격

- **고요한 관찰자** (`quiet`): 짧고 신중하게 말한다. “별은 서두르지 않아. 나도 오늘은 천천히 볼래.” · 지혜 재능 +1 · frame 0 · `assets/lumen-personality-sheet.png` · indigo-lavender / moon
- **다정한 연결자** (`kind`): 상대의 마음을 먼저 살핀다. “네가 웃으면 정원도 조금 더 환해지는 것 같아.” · 공감 재능 +1 · frame 1 · `assets/lumen-personality-sheet.png` · teal-cream / flower
- **용감한 개척자** (`bold`): 실수해도 먼저 움직인다. “길이 없다면, 오늘 한 걸음으로 만들면 돼!” · 용기 재능 +1 · frame 2 · `assets/lumen-personality-sheet.png` · coral-ochre / compass

## 동료

- **루미** (`lumi`): 별자리 기록관 · quiet · frame 0 · 유대 8에서 에필로그 · “기록은 마음이 다시 길을 찾게 해.”
- **보라** (`bora`): 온실의 돌봄지기 · kind · frame 1 · 유대 8에서 에필로그 · “함께 가꾼 시간은 쉽게 시들지 않아.”
- **타로** (`taro`): 바람길 수리공 · bold · frame 2 · 유대 8에서 에필로그 · “망가진 길도 손을 대면 다시 이어져!”

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
- **겨울의 문** (`winter`): 12주차 · 지혜 ≥ 20 · 성공 보상 은화 8 · “노아는 루멘의 다음 문을 열었다.” / “문은 닫혔지만 다음 열쇠를 남겼다.”

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

## 엔딩

- **루멘의 별읽기꾼** (`stargazer`): 지혜 ≥ 12 · 노아는 밤하늘의 결을 읽어 영지의 항로를 밝히는 사람이 되었다.
- **새벽을 계산하는 항해사** (`stargazer-master`): 지혜 ≥ 24 · 목표 spring, winter · 노아는 별과 바람의 주기를 기록해 누구나 길을 찾는 지도를 남겼다.
- **마음의 정원사** (`gardener`): 공감 ≥ 12 · 노아는 서로 다른 마음이 함께 피어나는 정원을 만들었다.
- **마을의 온기를 잇는 사람** (`gardener-master`): 공감 ≥ 24 · 목표 summer · 노아는 다툼이 시작되기 전에 서로의 이야기를 건네는 광장을 열었다.
- **새 길의 개척자** (`pathfinder`): 용기 ≥ 12 · 노아는 아직 이름 없는 길에 첫 발자국을 남겼다.
- **경계를 넘어선 선봉장** (`pathfinder-master`): 용기 ≥ 24 · 목표 autumn · 노아는 두려움을 없애지 않고도 앞으로 나아갈 수 있다는 길을 보여주었다.
