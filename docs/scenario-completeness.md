# 시나리오 완전성 표본

이 문서는 `story/story.jsonl#scenarioCompleteness`의 설계 근거와 검증 기준이다. 프린세스 메이커 5의 공개 소개·리뷰에서 관찰되는 구조를 장르 설계의 표본으로만 분석하고, 고유명사·대사·캐릭터·이미지를 복제하지 않는다.

## 1. 공개 자료에서 추출한 구조적 표본

| 관찰 가능한 구조 | 시나리오 설계로 번역한 질문 |
| --- | --- |
| 약 8년의 성장 기간과 월별 교육 방침, 주간 일정이 함께 작동한다 | 장기 시간축의 각 단계가 새로운 목표·관계·규칙을 공개하는가? |
| 학교·습관·아르바이트가 능력·수입·스트레스에 서로 다른 영향을 준다 | 모든 선택이 이득만 주지 않고 다음 선택의 비용도 만드는가? |
| 휴일 외출이 능력·스트레스·아이템·관계를 동시에 건드린다 | 자원·시간·관계가 한 행동에서 교차하는가? |
| 친구가 조건에 따라 등장하고 친밀도가 사건과 장래에 영향을 준다 | 관계가 장식이 아니라 접근 가능한 장면과 결말을 바꾸는가? |
| 친밀 관계 사이의 질투·소원함으로 모두와 친해지는 전략이 항상 최적이 아니다 | 관계 그래프에 긴장·배제·기회비용이 있어 재플레이 판단이 생기는가? |
| 중반 이후 다른 세계의 모험과 세계 확장이 열린다 | 중반 전환이 단순히 수치 상승이 아니라 플레이 공간을 바꾸는가? |
| 능력·성격·조건에 따라 다수의 엔딩이 갈리고, 반복 실험이 핵심이다 | 엔딩 조건이 명시적이고, 다른 정책이 추적 가능한 결과 차이를 만드는가? |
| 장시간 반복과 정보량이 재플레이의 마찰이 될 수 있다 | 완전성뿐 아니라 한 회차의 밀도와 스킵 가능한 피드백도 측정하는가? |

근거는 [Game Watch의 시스템 리뷰](https://game.watch.impress.co.jp/docs/20070330/prime5.htm), [4Gamer의 시스템·관계 리뷰](https://www.4gamer.net/review/pm5/pm5.shtml), [4Gamer의 사전 소개](https://www.4gamer.net/preview/pm5/pm5.shtml), [Steam 공식 소개](https://store.steampowered.com/app/724250/5/?l=japanese)를 참조했다. 이는 기능 목록을 복사하기 위한 자료가 아니라, 생활 시뮬레이션에서 서사 완전성을 판단하는 관찰 표본이다.

## 2. 프린스 메이커 적용 기준

### 막 단위 계약

각 막은 SSOT의 `contract`에 다음 네 가지를 모두 선언하고, 검증기가 실제 사건·목표와 대조해야 한다.

1. 공개: 새로운 장소·관계·규칙 중 하나가 열린다.
2. 압력: 스탯·은화·피로·유대 중 둘 이상이 충돌한다.
3. 선택: 최소 2개의 authored 선택이 서로 다른 상태를 만든다.
4. 결산: 사건 또는 계절 목표가 다음 막과 엔딩 조건에 기록을 남긴다.

`reveal`은 공개된 장면의 근거, `pressureAxes`는 충돌하는 자원(통계·은화·피로·유대), `choiceWeeks`는 실제 authored 사건 주차, `closureMilestone`은 막의 마지막 주에 해결되는 계절 목표를 뜻한다. 따라서 텍스트가 존재하는지만 세지 않고, 선택 주차마다 두 선택지가 있고 결산 목표의 주차가 막의 끝과 일치하는지 CI가 계산한다.

현재 48주 campaign은 16막, 47사건, 16개 막 목표로 이 계약을 고정한다. 열여섯 막 모두 공개·압력 2축 이상·authored 선택·막 종료 목표를 통과하며, 각 사건 선택은 `stat`, `coins`, `bondDelta`, `line`을 가지고 `GameSession`과 replay trace를 통해 검증한다. 12주차 첫 결산 이후에도 씨앗의 귀환·기억의 집·먼 영지·선택의 의회·다음 사람의 첫걸음으로 서사 압력을 장편으로 이어간다.

### 2,000개 이상 시나리오 경우의 수

`scenarioVariantBudget`는 3·4·5·8·12·13·14·15·16·17·18주차를 독립 authored 분기 축으로 선언한다. 각 주차의 두 선택지는 조건 없이 열려 있으므로 CI가 모든 `2^11 = 2,048` 벡터를 실제 `GameSession`에 주입해 서로 다른 사건 replay trace를 확인할 수 있다. 여기에 5개 활동 정책·3개 성격·4개 계승 컨텍스트를 곱한 전체 route input은 `2,048 × 5 × 3 × 4 = 122,880개`다. 경우의 수는 입력 벡터만 세지 않고 core ending, 동료 route set, 스탯, 유대, 막 목표, 기억 flag까지 포함한 결정론적 signature로 기록한다.

엔딩 행렬은 `winner-growth-axis → highest-eligible-authored-tier → record-rank → companion-route-set → retrospective-cause-board` 순서로 닫힌다. 지혜·공감·용기 각각의 seed/master 2단계가 6개 core ending을 이루고, 동료 3명의 부분집합 8개가 solo·single-companion·ensemble route modifier로 합성되어 최대 48개 terminal route card를 만든다. 따라서 2,000개 시나리오가 같은 화면으로 뭉개지지 않고, 선택 trace와 관계·기억 회고가 다른 엔딩 결과로 남는다.

### 시스템 승인과 책임 추적

사람이 선택을 승인하거나 결과의 책임을 수동 체크하는 구조를 사용하지 않는다. SSOT의 `decisionSystem`이 `system-adjudicated`·`fail-closed` 계약을 선언하고, `SystemDecisionPolicy`가 각 활동·사건 입력을 결정론적으로 승인하거나 거절한다. 승인된 입력은 `kind`, `subject`, `week`, `rule`, `contract`, `decisionHash`, `owner`를 가진 immutable replay trace 영수증으로 먼저 기록된 뒤 ECS 이벤트로 전파된다. 거절된 입력도 같은 영수증과 이유를 남기므로, 시스템이 어떤 규칙으로 결정을 내렸는지 재현 가능하다. 이는 법적 책임을 자동화한다는 주장이 아니라 게임 규칙·CI 품질의 계산 가능한 책임 소재를 고정하는 장치다.

## 프린세스 메이커 5에서 추출한 시나리오 표본

프린세스 메이커 5는 평일 학교와 방과 후·휴일 계획을 분리하고, 주간 스케줄·아르바이트·스트레스·친구 관계를 장기 성장에 연결하는 구조로 소개된다. [4Gamer의 당시 소개](https://www.4gamer.net/preview/pm5/pm5.shtml)는 평일 낮 학교와 방과 후·휴일 육성을 설명하고, [Steam 소개](https://store.steampowered.com/app/724250/Princess_Maker_5/?l=english)는 학교 일정·방과 후 활동·아르바이트·스트레스의 교환을 요약한다. 여기서 가져오는 것은 시스템 관계의 표본이지, 원작의 캐릭터·문구·이미지·수치가 아니다.

| PM5에서 관찰한 축 | `프린스 메이커`의 독자적 압축 표본 | 완전성 증적 |
|---|---|---|
| 시간 예산 | 48주 × 하루 활동 1회, 사건 47개가 매 주차의 결과와 관계를 갱신 | `tool/benchmark_game.dart` 5,000 campaign / 475,000 transitions |
| 상태 피드백 | 성장 3축·피로·은화·계절 목표가 다음 사건과 엔딩에 되돌아옴 | `test/game_core_test.dart` 규칙·trace |
| 관계 아크 | 3명 동료, rival bond 손실·상호 중재, bond-gap 긴장/소원함/휴전 상태, 상태별 상호 배타 후속 대화, 임계 유대 에필로그, 관계 게이트 | `relationship-gate.png`·`relationship-tension.png`·`mediation.png`·`relationship-followup.png`·`test/relationship_dynamics_test.dart` |
| 감정/기억 | 이전 사건의 `setsFlag`가 후속 선택을 열고 회고 보드에 원인으로 남음 | `memory-gate.png`·`ending.png` |
| 장기 재플레이 | 2,048개 실제 분기 벡터, 122,880개 route input, 6개 authored core 엔딩, 최대 48개 terminal route card, 엔딩 도감, 엔딩 계열별 3개 회차 계승 프로필이 다음 회차 성장·기억·선택 보정을 해금 | `tool/verify_scenario_variants.dart`·`legacy-gate.png`·collection Golden·legacy trace |
| 장면 결산 | 결말명만이 아니라 최대 3개 사건과 달성 목표 수를 결정론적으로 표시 | `ending.png`·`canonical-ending.png` |

따라서 현재 표본의 시나리오 완전성 최소 단위는 `계획 → 상태 변화 → 조건 공개 → 관계/기억 결과 → authored ending → 원인 회고 → 다음 회차 해금`의 7단 연결이다. 각 연결은 SSOT, 코어 trace, Canvas Golden, benchmark 중 둘 이상으로 교차 증명하며, 회고 보드는 마지막 연결을 시각 증거로 고정한다.

### 나비효과·동료 퀘스트·발견 경로

조사한 선택형 서사의 재미 요소를 루멘 고유 규칙으로 압축한다. 사건 선택이 남긴 6개의 authored memory flag는 `resolveFateThreads`가 나비효과 기록으로 투영하고, 같은 flag가 후속 조건·회고·저장 trace에서 다시 읽힌다. 세 동료는 각각 `bondMin`이 올라가는 3단계 개인 퀘스트와 6개 독립 장면을 가지며, 총 9개 퀘스트 단계의 완료 여부는 유대 수치와 사건 flag의 교집합으로 시스템이 판정한다. 여섯 장소의 `place:<id>` 발견 flag는 홈의 route atlas에 이어져, 플레이어가 이미 열린 경로와 아직 닿지 않은 경로를 한눈에 볼 수 있다.

이 요소들은 특정 외부 게임의 캐릭터·생존 규칙·여행 맵을 복제하지 않는다. `story/story.jsonl#narrativeLoop`가 원천과 판정 주체를 선언하고, `lib/game_core.dart#resolveFateThreads`·`resolveCompanionQuests`가 동일한 입력에서 동일한 결과를 만들며, `test/narrative_ledger_test.dart`와 `test/narrative_ledger_golden_test.dart`가 결정론적 projection과 화면 증거를 고정한다. 따라서 플레이어에게는 선택이 “다음 장에 남는 기록”으로 보이고, CI에는 사람의 해석 없이 재현 가능한 상태 계약으로 남는다.

### 상태·관계·엔딩 완전성 행렬

| 축 | 최소 표본 | 현재 증거 | 다음 확장 기준 |
| --- | ---: | --- | --- |
| 시간/막 | 16막, 막당 사건 2개 이상 + 관계 장면 beat + 상태별 후속 대화 | `progression.contract` 16/16 · 47개 사건 · 공개·압력·선택·결산 100% · 16/16 canonical event Golden · 16/16 closure Golden · 16/16 relationship scene binding · 5-state relationship resolver · 5 exclusive follow-ups | 관계별 후속 대화가 조건 선택과 flag를 바꾸는 다음 확장 |
| 성장축 | 3축, 축당 기본/숙련 엔딩 | 지혜·공감·용기 6 core 엔딩 + 동료 route set 최대 8개 | 축 간 상쇄 또는 혼합 엔딩 추가 |
| 관계 | 동료 3명, 인사→유대→긴장/소원함→중재/기억→상태별 후속 대화→동행 목표→에필로그 | 3 companion, rival loss, deterministic tension/estrangement/truce state, reciprocal mediation, truce flag, 5 exclusive follow-ups, 3 route goals, epilogue, 3 lineage target companions | 후속 대화가 다음 선택의 bond/flag 조건을 여는 확장 |
| 자원 | 능력·은화·피로 중 2개 이상이 선택에 영향 | 세 자원과 계절 목표 | 외출·아이템·시간 예산을 별도 phase로 확장 |
| 공개/조건 | 잠금 선택과 목표 gated ending | 조건부 선택 5개(스탯 4·유대 1·기억 1), master ending | 조건 공개 힌트와 실패 후 회복 경로 추가 |
| 회차 | 동일 입력 동일 trace, 정책 변경 결과 차이 | 5 정책, 4 signature, collection-driven legacy unlock, 3 lineage profiles, week-2 authored bonus, profile별 route signature·target ending·target companion epilogue | 계승 unlock이 다음 회차의 성장축·선택 공간과 profile target ending·관계 회고 분포를 넓히는지 측정 |
| 장면 | 도입·중반 사건·사이드 장면·막 관계 장면·관계 상태·상태별 후속 대화·장소 발견·관계 긴장·관계 중재·외출·유대·기억·계승 게이트·계승 프로필·엔딩·공통 UI 상태 Golden | 73 Golden, 그중 16막 canonical 사건 16/16·결산 16/16·관계 장면 16/16, home/closure relationship state/follow-up rendering, page 11 relationship archive ko/en, canonical 4주차·48주차 handoff 사건, 6 location discovery flags/traces, 24 side-scene records·10 activity mini-events·18 companion scenes·18 ending variants, rival loss/mediation, outing/bond/memory/legacy feedback, five-state Canvas UI matrix, 3 companion epilogue endings | 후속 대화와 공통 surface 상태가 다음 선택·렌더 계약을 여는 Golden 확장 |
| 종결 | terminal·저장·컬렉션·재시작·원인 회고·다음 회차 가이드 | save v7, terminal, collection, 최대 3개 사건 + 달성 목표 + 미달 목표 2개 회고 | 동료별 관계 변화와 상호 배타 목표의 회고 문구 추가 |

### 정량 게이트

```text
scenarioScore = 통과한 축 / 전체 8축 × 100
choiceConsequenceRate = 상태 또는 trace가 달라지는 authored choice / 전체 authored choice
chapterClosureRate = 공개·압력·선택·결산을 모두 가진 막 / 전체 막
replaySignatureCount = (ending, stats, bonds, goals) 고유 서명 수
```

현재 릴리스 게이트는 `scenarioCompleteness.dimensions` 8축, 94/94 본편 선택과 72/72 사이드 선택 도달성, 6/6 엔딩 도달성, 6/6 장소 발견 trace, 3/3 회차 계승 프로필, 3/3 프로필별 2주차 authored 보정, 3/3 profile route signature, 3/3 profile target ending, 3/3 profile target companion epilogue, `choiceConsequenceRate = 100%`, `chapterClosureRate = 100%`, `chapterSceneBindingRate = 100%`, 5-state relationship resolver·5 exclusive follow-up과 ECS replay trace, `replaySignatureCount ≥ 3`, 최소 플레이타임 156분(하한 120분) 계약, 시스템 승인 영수증의 replay 보존을 요구한다. 성능 축은 이와 동일한 SSOT 캠페인을 5,000회 재생해 checksum·replayChecksum·profile별 signature·target ending·target companion 집합을 비교한다.

## 3. 의도적인 차이와 확장 순서

프린세스 메이커 5의 장기(8년)·다층 일정·외출·모험 규모를 그대로 따라가지 않는다. 현재 게임은 48주 16막으로 확장해 한 회차의 원인과 결과를 Golden과 replay trace로 읽을 수 있게 만든다. 48회 활동 선택과 47개 본편 사건 선택, 24개 사이드 장면은 각 주차의 성장·관계·기억을 갱신하고, 각 막 결산에는 SSOT가 지정한 동료의 상반신과 2줄 관계 scene beat가 함께 닫히며, 16개 막 결산이 다음 아크의 질문을 연다. 외출·관계·기억 선택은 초반 표본을 넘어 먼 영지·기억의 집·선택의 의회·새벽 관측소·별씨앗 채석장까지 이어지며, 장편 콘텐츠가 숫자만 늘어나지 않고 책임 추적 규칙을 플레이 선택으로 되돌려준다. 중반 공간은 6개 장소를 사건 진입 시 최초 발견하고 `place:<id>` flag/trace로 저장한다. 회차 계승은 도감의 authored 엔딩을 `stargazer/gardener/pathfinder` 3개 프로필로 정규화해 다음 회차 시작 스탯 +2, `legacy:<id>` flag, trace를 함께 생성하고, 2주차 게시판 선택에 프로필별 추가 성장축 +1을 적용한다. 다음 확장은 이 계승 프로필이 막별 선택 공간과 엔딩 분포를 어떻게 바꾸는지 Golden·replay·benchmark로 측정한다.
