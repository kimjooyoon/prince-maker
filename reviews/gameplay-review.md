# 프린스 메이커 플레이테스트·적대적 리뷰

- 점검일: 2026-08-09
- 대상: 로컬 Flutter Web build, 1280×720, 한국어 시작
- 플레이 범위: 1주차 시작 → 9주차 막 결산까지
- 확인한 표면: 일정 선택, 본편 사건, 막 결산, 사이드 장면, 저장 보관소, 운명 기록, 일러스트, 캐릭터 도감, 환경 아틀라스, 한국어/English 토글

## 한줄 판정

게임의 상태 전이와 콘텐츠 뼈대는 실제로 작동한다. 이번 재검토에서 P0 입력 계약, 플레이어용 저장 요약, 영문 코어 루프, 긴 효과 카드 레이아웃을 `main`에 반영했고, English 1~9주차 연속 플레이와 전체 CI까지 통과했다.

## 플레이 로그

1. 1주차 활동 선택 후 2주차 사건 진입.
2. 루미·보라·타로와의 사건 선택으로 지혜/공감/용기, 은화, 피로, 유대가 변하는 것을 확인.
3. 3·6·9주차 막 결산에서 목표 판정, 다음 장 이동, 동행 대사를 확인.
4. 환경 아틀라스에서 사이드 장면으로 이동하고 24개 중 첫 장면의 선택을 완료.
5. 저장 보관소와 운명 기록을 각각 열어 저장 코드, 사건 기록, 시스템 판정 영수증을 확인.
6. 캐릭터 도감에서 캐릭터 상세/감정 키 화면으로 진입.
7. 한국어/English를 왕복하며 혼합 언어와 작동하지 않는 사건 화면 토글을 확인.

## 잘 된 부분

- 일정 → 수치 변화 → 사건 결과 → 다음 목표라는 핵심 루프는 9주차까지 끊기지 않았다.
- 선택 카드에 수치·은화·유대 변화가 표시되고, 결과 배너가 직전 선택을 되짚어 준다.
- 막 결산, 사이드 장면, 환경 아틀라스, 캐릭터 도감까지 콘텐츠 표면은 풍부하다.
- Canvas의 색·패널·캐릭터 자산은 일관성이 있고, 기본 화면은 한눈에 읽힌다.
- `flutter analyze`와 전체 Flutter 테스트, 플레이어용 ko/en 저장 Golden, 입력 계약 테스트가 통과했다. 화면 카피와 1~9주차 연속 플레이는 별도 증적으로 계속 추적한다.

## 최우선 이슈

### P0 — 사건 화면의 `EN` 버튼이 장식이다

상태: `main`에 수정 병합 완료. `test/player_input_contract_test.dart`가 실제 탭 좌표를 재생해 통과한다.

**재현:** English archive에서 사건으로 돌아온 뒤 사건 화면 우측 상단 `EN`을 눌렀다. 화면은 계속 한국어였고, 다음 사건에서도 제목·본문·선택지·하단 안내가 한국어로 남았다.

**근거:** 화면은 page 3에서 `drawLocaleToggle`과 localized event painter를 그리지만, 입력 분기인 [`lib/main.dart:331-332`](/Users/alice/games/princess_maker_like/lib/main.dart:331)에는 언어 토글 처리가 없고 선택지 처리만 있다. 반면 버튼은 [`lib/main.dart:915-918`](/Users/alice/games/princess_maker_like/lib/main.dart:915)에 계속 표시된다.

**왜 치명적인가:** 사용자는 버튼을 눌렀다는 피드백조차 받지 못한다. 영어 지원을 약속하는 UI가 핵심 플레이 구간에서 거짓말을 하는 셈이다. 로컬라이징 QA에서 가장 먼저 걸려야 할 기본 상호작용이다.

**수정 요구:** page 3 입력 맨 앞에 `y < 100 && x > 590` 토글을 추가하고, 사건의 제목·본문·선택지·조건·결과 문구를 모두 동일한 catalog 경로로 통일하라. 버튼을 숨기거나 일부만 번역하는 임시 처리는 더 나쁘다.

### P0 — 보이는 `← 돌아가기`가 뒤로가기가 아니다

상태: `main`에 수정 병합 완료. 보이는 라벨 좌표와 `test/player_input_contract_test.dart` 계약이 일치한다.

**재현:** 홈에서 `일러스트`를 열고 우측 하단의 보이는 `← 돌아가기`를 눌렀다. 홈으로 돌아가지 않고 선택 캐릭터가 루미에서 타로로 바뀌었다. 실제로 돌아가려면 라벨 오른쪽의 보이지 않는 영역을 눌러야 했다.

**근거:** 라벨은 [`lib/main.dart:1753`](/Users/alice/games/princess_maker_like/lib/main.dart:1753)의 logical x=610 부근에 그려져 있다. 하지만 page 1 입력은 [`lib/main.dart:315-321`](/Users/alice/games/princess_maker_like/lib/main.dart:315)에서 x<720인 하단 탭을 먼저 캐릭터 선택으로 처리한 뒤에야 뒤로가기를 검사한다.

**왜 치명적인가:** 사용자가 가장 자연스러운 위치를 눌렀을 때 다른 상태가 바뀐다. 이건 발견성 문제가 아니라 내비게이션 계약 위반이며, 화면에 갇힌 것처럼 느끼게 만든다.

**수정 요구:** 뒤로가기 버튼에 명시적 Rect를 만들고 캐릭터 탭 Rect와 겹치지 않게 하라. 화면에 그린 좌표와 입력 좌표를 같은 상수에서 파생시키고, “라벨을 눌렀을 때 페이지가 바뀐다”는 golden/integration test를 추가하라.

### P1 — 저장 보관소가 플레이어 화면에 개발자 덤프를 뿌린다

상태: 플레이어용 요약·복사 전용 코드 경계를 구현했고 `test/player_facing_golden_test.dart`의 ko/en Golden으로 검증했다.

**재현:** `기록 보관소`를 열자 `relationship:followup=...`, `event:...|bond:...`, `{"schema":"lumen-save-v7"...}` 같은 내부 trace와 JSON 조각이 그대로 보였다. English로 바꿔도 raw key와 한국어 사건 문장이 섞였다.

**근거:** [`lib/main.dart:1893-1897`](/Users/alice/games/princess_maker_like/lib/main.dart:1893)는 최근 history 문자열과 save code 앞부분을 그대로 화면에 출력한다.

**왜 문제인가:** 저장 기능의 신뢰를 높여야 할 화면이 오히려 데이터 손상·디버그 모드·개발 중인 제품이라는 인상을 준다. 일반 사용자는 `p#...`, schema, relationship key를 해석할 책임이 없다.

**수정 요구:** 사용자용 요약과 복사용 코드 영역을 분리하라. history는 “보라와 천을 덧댄다 · 공감 +2 · 유대 +2” 같은 사람이 읽는 카드로 변환하고, save code는 접기/복사 전용으로 감춰라. raw trace는 개발자 도구나 debug flag에서만 보여라.

### P1 — English가 핵심 루프를 번역하지 못한다

상태: 홈·활동·목표·상태·사건·일러스트·저장 보관소 표면을 catalog로 연결하고 player-facing Golden을 추가했다. `test/player_facing_golden_test.dart`가 English로 1주차부터 9주차 막 결산까지 실제 입력을 재생해 통과한다.

**재현:** English 상태의 홈에서 버튼은 `Spend the day`, 하단 메뉴는 `Character archive`로 바뀌었지만 제목·주인공·활동 카드·목표·상태 문구는 한국어였다. 일러스트 화면도 제목과 탭은 한국어이고 오른쪽 설명만 English였다. 운명 기록의 English 화면에서도 영수증 안의 `달빛 아래 휴식` 같은 한국어 활동명이 남았다.

**근거:** 홈과 저장 화면은 [`lib/main.dart`](/Users/alice/games/princess_maker_like/lib/main.dart)의 catalog 경로를 사용하고, 영문 illustration overlay와 새 player-facing Golden은 [`lib/i18n.dart`](/Users/alice/games/princess_maker_like/lib/i18n.dart), [`test/player_facing_golden_test.dart`](/Users/alice/games/princess_maker_like/test/player_facing_golden_test.dart)로 고정했다.

**왜 문제인가:** 이건 번역 누락 몇 줄이 아니라 언어 선택의 범위가 정의되지 않은 기획 문제다. 플레이어가 읽어야 하는 목표와 활동만 한국어로 남으면 선택의 의미를 이해하지 못한다.

**수정 요구:** 먼저 “번역 완료 화면”의 범위를 선언하고, core loop 화면을 전부 catalog key로 바꿔라. SSOT에 `titleKey`, `bodyKey`, `labelKey`, `hintKey`, `conditionKey`가 없는 항목은 locale contract가 통과하지 않도록 해야 한다.

### P1 — 긴 선택지의 효과 문구가 카드 아래에서 잘린다

상태: 카드 높이를 220px로 확장하고 효과/legacy/나비효과를 분리했으며, 효과 문구를 최대 2행으로 제한했다. 전체 Golden suite가 통과한다.

**재현:** 8주차 `바람이 멎은 오후` 사건에서 경쟁 유대 변화가 붙은 선택지를 보자 카드 하단 효과 문구가 여러 줄로 겹치거나 카드 경계 아래로 밀렸다. 선택은 가능하지만 읽기 어렵다.

**근거:** [`lib/main.dart`](/Users/alice/games/princess_maker_like/lib/main.dart)와 [`lib/i18n.dart`](/Users/alice/games/princess_maker_like/lib/i18n.dart)가 카드 높이·최대 행 수·하단 효과 바의 위치를 함께 관리한다.

**왜 문제인가:** 이 게임의 핵심은 선택의 비용·보상을 비교하는 것인데, 바로 그 정보가 겹친다. “선택의 의미를 이해하고 고른다”는 설계 목표를 UI가 방해한다.

**수정 요구:** 효과를 2행 구조로 고정하거나 카드 높이를 늘리고, rival/legacy/memory 정보를 별도 badge로 분리하라. 모든 authored choice를 긴 한국어 문자열로 렌더링하는 golden을 추가해야 한다.

## 기획·구조에 대한 적대적 리뷰

### 두 개의 기록 메뉴가 서로 다른 이유를 설명하지 않는다

상태: 홈 버튼을 `저장/복원`과 `운명 도감`으로 분리하고, 저장 화면은 코드 보관 설명, 운명 기록은 선택·판정 영수증 설명을 별도로 보여 준다.

홈에는 중간의 `저장/복원`과 하단의 `운명 도감`이 동시에 있다. 전자는 저장 코드/복원, 후자는 사건·퀘스트·판정 영수증이다. 기능과 설명이 목적을 직접 드러내므로 첫 진입에서 추측할 필요가 없다.

**요구:** `저장/복원`과 `운명 도감`처럼 목적을 이름에 직접 쓰고, 첫 화면에 1줄 설명을 붙여라. 둘을 하나의 기록 허브로 합치는 것도 더 낫다.

### 캐릭터 도감 상세가 보상 화면이 아니라 아트 디렉션 문서다

상태: 상세 화면을 `루멘 사람들`로 바꾸고 `자주 보여 주는 모습`, `기억에 남는 표정`, `이 사람의 하루`처럼 플레이어가 관계를 회고하는 언어로 교체했다. 관련 Golden도 갱신했다.

이건 세계관을 보여 주는 도감이 아니라 제작팀의 art bible를 플레이어에게 읽히는 화면이다. 플레이어가 얻어야 할 것은 “도란이 어떤 사람이며 내가 어떤 선택으로 관계를 만들었는가”이지, 재사용 가능한 포즈 키가 아니다. 내부 설계 언어를 수집 보상으로 포장한 기획을 걷어내고, 발견 조건·관계 회고·짧은 인물 서사로 바꿔야 한다.

### 환경 아틀라스가 세계를 설명하기보다 시스템 용어를 전시한다

상태: 환경 화면 상단을 `6곳 · 사건·보상·기억이 이어지는 장소`로 바꿔 설계 메타데이터를 제거했다. 장소별 사건 연결과 보상 정보는 카드 본문에 남긴다.

## 출시 판정

**현재 판정: 플레이어용 출시 후보.**

P0 두 건과 확인된 P1 화면 문제를 수정·계약·Golden으로 재검증했고, English 상태에서 1주차부터 9주차까지 실제 입력을 연속 재생하는 테스트도 통과했다. 전체 CI와 원격 `main` 반영만 남았다.

## 재검증 체크리스트

- [x] 사건 page 3에서 언어 토글이 실제로 제목/본문/선택지/조건/결과를 바꾼다.
- [x] 일러스트 화면의 보이는 뒤로가기 라벨을 눌렀을 때 반드시 홈으로 돌아간다.
- [x] English 상태로 1주차부터 9주차까지 목표·활동·사건·막 결산을 완주한다.
- [x] 저장 보관소에서 raw schema/history/hash가 기본 화면에 보이지 않는다.
- [x] 긴 rival/legacy 효과를 가진 모든 선택 카드가 경계 안에서 읽힌다.
- [x] 저장 보관소와 운명 기록의 이름/설명이 처음 보는 사용자에게 구분된다.

## 2026-08-09 최신 적대적 재검토 — 동행 장면 폐쇄루프

이번 기록은 위의 초기 플레이 로그를 대체하지 않는다. 새 companion-scene 변경과 102개 Golden, 18개 SSOT 장면, 5,000회 benchmark를 기준으로 현재 위험을 다시 판정한다.

### 통과한 증거

- `resolveCompanionScenes`가 bond·chapter·persisted flag에서 같은 projection을 재생한다.
- 기록 성공은 `companion-scene:<id>` flag, bondDelta, 시스템 승인 영수증, trace를 함께 남긴다.
- 잠긴 입력·중복 입력은 fail-closed로 거절되며 중복 보상과 중복 trace가 생기지 않는다.
- `companion_scene_test.dart`와 `companion_scene_golden_test.dart`가 최초 화면·기록 후 화면·English 전환을 고정한다.
- CI benchmark는 5,000 campaigns / 565,000 transitions / 18 scenes에서 checksum·forecast checksum·companion-scene checksum replay가 일치했다. Wasm release와 전체 Golden도 같은 실행에서 승인됐다.

### 남은 P1 — “독립 장면”이 사실상 클릭형 수집 체크리스트다

현재 카드에는 제목·대사·`기록하기`가 있지만, 플레이어가 고르는 authored choice나 대립·비용·실패 상태가 없다. 클릭 한 번으로 bond가 +1 되고 완료 색상만 바뀌므로, 18개의 장면이 서사 선택이 아니라 보상 수집으로 축소된다. `gameplay-fun`의 166개 선택 통계에는 이 장면들의 선택 깊이가 포함되지 않는다.

**수정 요구:** 최소한 장면별 2-way question/response 또는 bond·fatigue·flag 중 하나를 선택하는 작은 갈림을 도입하고, 선택 결과가 다음 chapter/ending route에 영향을 주는 Golden과 route-signature 증거를 추가하라. 현재의 단순 기록 보상은 “콘텐츠가 늘었다”는 완전성 증거이지 “재미가 늘었다”는 순수성 증거가 아니다.

### 남은 P1 — 잠긴 카드 탭의 실패 피드백이 화면에 보이지 않는다

도메인 테스트에서는 조건 부족을 거절하고 `lastResult`와 reject receipt를 남기지만, page 13 painter는 카드의 `LOCKED` 상태만 다시 그린다. 잠긴 카드를 눌렀을 때 왜 실패했는지, 현재 막이 부족한지 bond가 부족한지 플레이어가 즉시 알 수 있는 result banner/toast가 없다. 이 문제는 `companion_scene_golden_test.dart`가 available 카드의 성공만 탭하고 locked 카드의 시각적 거절을 캡처하지 않아 놓치기 쉽다.

**수정 요구:** 거절된 scene id와 이유를 localized banner로 page 13에 노출하고, locked tap·chapter 부족·bond 부족·중복 기록을 각각 Golden 또는 widget assertion으로 고정하라.

### 남은 P1 — Golden 범위가 18개 장면 전체를 대표하지 않는다

현재 전용 Golden 3장은 Lumi의 첫 archive·첫 기록·English 기록 후 상태만 고정한다. Bora/Taro, 3·5·7·11막 이후 장면, 마지막 장면, 이전/다음 동행 버튼, 잠김/완료 혼합 행의 layout은 직접 검증하지 않는다. benchmark checksum은 상태 재현을 증명하지만 Canvas clipping·locale overflow·입력 hitbox를 증명하지 않는다.

**수정 요구:** 각 companion의 첫/중간/마지막 장면과 잠김·기록됨·기록 가능 혼합 상태를 최소 한 장씩 추가하고, 이전/다음/관계 기록 back hitbox를 실제 탭으로 검증하라. 특히 한 카드의 prompt·line·reward가 2행 안에 들어가는지 Golden pixel diff로 확인해야 한다.

### 남은 P2 — 성능 증거와 체감 렌더링 증거가 분리되어 있다

campaign benchmark는 domain transition과 replay checksum을 측정하며 24초 상한 안에 통과한다. 그러나 companion archive의 Canvas paint 비용, 이미지 decode, locale 전환 프레임은 benchmark에 포함되지 않는다. 따라서 “성능 통과”를 “page 13이 저사양 브라우저에서도 부드럽다”로 확대 해석하면 안 된다.

**다음 골든 리뷰 기준:** 위 P1 세 항목 중 장면 선택 깊이와 잠긴 입력 피드백이 해결되기 전까지는 전체 완성도·성능 승인을 게임 재미의 최종 승인으로 표현하지 않는다. 현재 상태는 `SYSTEM_APPROVAL`은 통과했지만, 플레이어 경험 관점에서는 조건부 출시 후보이다.

## 2026-08-09 P1 후속 조치 및 폐쇄 판정

위 재검토의 P1 요구사항을 다음 증적으로 구현했다.

- [x] 18개 장면 모두 2-way authored choice를 가지며, stat·fatigue·bond·memory flag를 선택별로 적용한다.
- [x] 선택 flag가 `resolveEnding(..., flags:)`의 route signature에 반영되고, `companion_scene_test.dart`가 choice 0/1의 divergent state와 ending route를 검증한다.
- [x] raw SSOT가 아닌 `resolveCompanionScenes` projection으로 UI 입력을 판정한다. 잠금·chapter 부족·bond 부족·중복은 fail-closed stable rejection code와 localized page-13 feedback으로 드러난다.
- [x] 첫 장면·선택 대기·기록 후·English·Lumi/Bora/Taro 혼합 상태·bond 잠금 화면을 포함한 8개 companion Golden과 실제 pending/choice/back navigation 입력 검증을 추가했다.
- [x] benchmark가 campaign/scene index로 choice 0/1을 모두 재생하고, choice trace를 `companionSceneChecksum`과 route signature에 포함한다.

최종 판정은 생성 문서와 review manifest를 갱신한 단일 `tool/ci_gate.dart --ci` 결과에 위임한다. Canvas paint/decode/frame-time은 별도 device benchmark가 아니므로, 성능 판정은 deterministic domain throughput 범위로만 해석한다.

## 2026-08-09 최종 게이트 후속 판정

단일 `tool/ci_gate.dart --ci`가 `SYSTEM_APPROVAL: APPROVE`로 완료됐다. 확인된 수치는 5,000 campaigns / 565,000 transitions / 6.33초 / 18 companion scenes / choice modes `[0, 1]`이며 campaign·forecast·companion-scene checksum replay가 각각 일치한다. 전체 164개 Flutter 테스트와 102개 Golden, Wasm release build, 100% completeness dimensions, quality score 1.0도 통과했다.

적대적 판정을 철회하는 범위는 P1 폐쇄루프까지다. 이 결과를 page 13 저사양 60fps 보증으로 확대하지 않으며, Canvas paint/decode/frame-time 계측과 선택 flag의 후속 authored dialogue 회수는 다음 리뷰의 P2로 남긴다. 따라서 현재 판정은 `SYSTEM_APPROVAL` 기준 승인, 체감 성능·서사 회수 기준 조건부 후속 검증이다.
