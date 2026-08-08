<!-- generated: tool/generate_ssot_docs.dart -->
<!-- ssot-sha256: c16303d779935b8c03d6dc2bc9a578c9086f9298c437502ddd1b27e996e1abf8 -->
<!-- source-ref: story/story.json#root -->

# 프린스 메이커 · 스토리 SSOT

바람과 별빛이 공존하는 작은 영지 루멘에서 노아는 24주 동안 스스로 선택한 내일을 걷는다.

## 시스템 판정과 책임 추적

판정 주체: **Lumen Ledger System** · 모드 `system-adjudicated` · 사람 승인 필요 여부 `false` · 실패 모드 `fail-closed`
책임 증적: 모든 승인·거절을 규칙·입력·결정 영수증으로 추적하고 replay에서 같은 판정을 재현한다.
- `terminal-window` · activity|story-choice · endingWeek 이후 입력은 거절
- `input-contract` · activity|story-choice · 미등록 성장축·조건 미충족 입력은 거절
- `replay-receipt` · accepted decision · 승인 영수증을 immutable trace에 추가

## 24주 진행도

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

## 대사 구성 기준

- locale 최소 키: **216** · 한 캠페인 최소 대사 줄: **23** · 최소 노출 서사 단위: **64** · 전체 authored 대사 줄: **77**
- 산식: catalog 216 = UI 15 + personality name/voice/line 9 + event title/body 44 + choice label/line 88 + companion greeting/epilogue 6 + companion route titles 3 + location names 4 + legacy profile titles 3 + ending title/body 12 + chapter beats 24 + milestone titles 8; one 24-week route exposes at least 23 authored choice lines and 64 narrative units

## 시나리오 완전성 표본

참조 모델: **장기 성장·관계·선택·결산이 하나의 반복 가능한 생활 루프를 이루는 시나리오** (`life-sim-scenario-v1`)

| 차원 | 목표 | 현재 증적 | 검증 ref |
| --- | --- | --- | --- |
| 장기 아크 | 도입·성장·전환·결산이 반복되며 각 막에 사건과 목표가 있다 | 8 chapters / 22 events / 4 locations / 8 milestones / 8 chapter contracts / ending week 24 | `story/story.json#progression.contract` |
| 선택의 행위성 | 모든 authored choice가 스탯·은화·유대·조건 중 하나 이상을 바꾸고 trace에 남는다 | 44 event choices; outing choices trade time-budget coins for stat and bond; memory flags carry consequences | `test/story_integration_test.dart#every-authored-ending-and-event-choice-is-reachable` |
| 관계 아크 | 등장·대화·유대 임계·엔딩 에필로그의 계층이 존재한다 | 3 companions / rival conflict / reciprocal mediation flag / bond threshold / all-threshold epilogues / 3 lineage target companions | `story/story.json#companions` |
| 상태 피드백 | 일정의 결과가 다음 선택·막 목표·엔딩 조건에 되돌아온다 | stats, coins, fatigue, 8 milestones and 6 endings | `test/game_core_test.dart#rules` |
| 조건과 공개 | 조건부 사건과 목표가 숨은 단절이 아니라 재플레이할 실마리로 기능한다 | 8 locked choices including stat, bond, memory and legacy gates / 8 chapter contracts / 8 closing milestones / milestone-gated master endings | `tool/verify_game.dart#scenario-contract` |
| 재플레이 가치 | 동일 입력은 동일 결과, 다른 성장축·정책은 다른 authored 결과를 만든다 | 5 schedule policies / 4 distinct signatures / 6 endings / 3 bond route goals / 3 ending-based legacy profiles / profile-specific week-2 authored bonus / 3 profile route signatures / 3 profile target endings / 3 target companion epilogues | `test/gameplay_metrics_test.dart#three-legacy-profiles-produce-distinct-deterministic-route-signatures` |
| 장면 결산 | 도입·중반 사건·엔딩을 Canvas Golden으로 고정하고 대사 locale을 통과한다 | 26 Goldens / ko+en catalogs / canonical week-4 event / outing choice / rival loss and mediation recovery / bond, memory, legacy gates / lineage resonance choice / ending retrospective board / three companion epilogues | `test/golden_test.dart#all-lineage-companion-epilogues-have-distinct-Canvas-evidence` |
| 종결과 회고 | 엔딩이 terminal 상태·기록·새 캠페인으로 닫히며 성능 benchmark가 같은 루프를 재생한다 | terminal input contract / system decision receipts / save v7 with memory flags / collection / deterministic event-cause retrospective / ending-based lineage bonus / authored lineage choice bonus / target companion epilogues / SSOT campaign benchmark | `test/golden_test.dart#twenty-four-week-loop-resolves-to-an-ending` |

## 생성 이미지 자산

- [`assets/noa-sprite-sheet.png#hero-2-head-frames`](../assets/noa-sprite-sheet.png) · SHA-256 `1ed524abb6e4eda65e651e25ea008d31efcdebaab28b39086bb1f67a4b32581d`
- [`assets/noa-sprite-sheet-source.png#hero-chroma-key-source`](../assets/noa-sprite-sheet-source.png) · SHA-256 `5dd8207030fb83554ed7e8b420995a4d2dc8cf8a00f9ae8f54770fef61c90dd9`
- [`assets/lumen-personality-sheet.png#personality-frames`](../assets/lumen-personality-sheet.png) · SHA-256 `4f0529df6b24415f44bf18284d6ba15492838dc5bff5f6dab2c620eb97e6fb28`
- [`assets/lumen-personality-sheet-source.png#chroma-key-source`](../assets/lumen-personality-sheet-source.png) · SHA-256 `0e652df6e6a35f67bd8623c15ba23fb88d745a82ac8f083a32ea14a715b706d8`

## 폰트

- [`assets/fonts/NotoSansKR-Regular.ttf#canvas-korean-font`](../assets/fonts/NotoSansKR-Regular.ttf) · SHA-256 `c733940a7dc687142848b30a491e97138ed58dc58c4cae33c44e3ee52da411cb`

## 대사 로케일

- [`story/locales/ko.json#catalog`](../story/locales/ko.json) · SHA-256 `27dc32a4def3e168310982630e61ce52553674155e6f3c5e1482661a70b3e7ed`
- [`story/locales/en.json#catalog`](../story/locales/en.json) · SHA-256 `2516594ec47e5da21a831392bc0dc6d8a9a6d15f0bb3964582c1ea4f6b96ee0f`

## 성격

- **고요한 관찰자** (`quiet`): 짧고 신중하게 말한다. “별은 서두르지 않아. 나도 오늘은 천천히 볼래.” · 지혜 재능 +1 · frame 0 · `assets/lumen-personality-sheet.png` · indigo-lavender / moon
- **다정한 연결자** (`kind`): 상대의 마음을 먼저 살핀다. “네가 웃으면 정원도 조금 더 환해지는 것 같아.” · 공감 재능 +1 · frame 1 · `assets/lumen-personality-sheet.png` · teal-cream / flower
- **용감한 개척자** (`bold`): 실수해도 먼저 움직인다. “길이 없다면, 오늘 한 걸음으로 만들면 돼!” · 용기 재능 +1 · frame 2 · `assets/lumen-personality-sheet.png` · coral-ochre / compass

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

## 엔딩

- **루멘의 별읽기꾼** (`stargazer`): 지혜 ≥ 12 · 노아는 밤하늘의 결을 읽어 영지의 항로를 밝히는 사람이 되었다.
- **새벽을 계산하는 항해사** (`stargazer-master`): 지혜 ≥ 48 · 목표 spring, winter · 노아는 별과 바람의 주기를 24주 동안 기록해 누구나 판단을 다시 검증할 수 있는 지도를 남겼다.
- **마음의 정원사** (`gardener`): 공감 ≥ 12 · 노아는 서로 다른 마음이 함께 피어나는 정원을 만들었다.
- **마을의 온기를 잇는 사람** (`gardener-master`): 공감 ≥ 48 · 목표 summer, return · 노아는 다툼이 시작되기 전에 서로의 이야기를 건네고, 모든 판정의 근거를 함께 읽는 광장을 열었다.
- **새 길의 개척자** (`pathfinder`): 용기 ≥ 12 · 노아는 아직 이름 없는 길에 첫 발자국을 남겼다.
- **경계를 넘어선 선봉장** (`pathfinder-master`): 용기 ≥ 48 · 목표 autumn, constellation · 노아는 두려움을 없애지 않고도 앞으로 나아가며, 다음 사람이 같은 길을 재현할 수 있는 표식을 남겼다.
