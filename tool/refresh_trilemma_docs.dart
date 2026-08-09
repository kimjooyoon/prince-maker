import 'dart:io';

String render(String source) {
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  final localeKeys = File('story/locales/ko.jsonl')
      .readAsLinesSync()
      .where((line) => line.contains('"type":"entry"'))
      .length;
  final header = '<!-- generated: tool/refresh_trilemma_docs.dart -->\n';
  var output = source.startsWith(header) ? source : '$header$source';
  output = output
      .replaceAll(RegExp(r'Golden \d+종'), 'Golden ${goldens}종')
      .replaceAll(RegExp(r'\d+개 Golden'), '${goldens}개 Golden')
      .replaceAll(
          RegExp(r'Canvas Golden 증적은 \d+장'), 'Canvas Golden 증적은 ${goldens}장')
      .replaceAll(
          RegExp(r'ko/en \d+ locale keys'), 'ko/en ${localeKeys} locale keys')
      .replaceAll(RegExp(r'\d+개 locale catalog key'),
          '${localeKeys}개 locale catalog key')
      .replaceAll(
          RegExp(r'\d+ locale catalog key'), '${localeKeys} locale catalog key')
      .replaceAll(
          RegExp(r'\d+ locale minimum key'), '${localeKeys} locale minimum key')
      .replaceAll(
          '세 성격의 관계 공명 archive 화면을 추가해 현재 Canvas Golden 증적은 ${goldens}장이다.',
          '세 성격의 관계 공명 archive 화면과 세 성격별 page 1 상반신 일러스트 화면을 추가해 현재 Canvas Golden 증적은 ${goldens}장이다.')
      .replaceAll('SSOT sheetIndex binding, 16개 closure Golden',
          'SSOT sheetIndex binding, 3개 성격별 page 1 상반신 Golden, 16개 closure Golden')
      .replaceAll('3×3 personality×companion matrix·5개 exclusive follow-up',
          '3×3 personality×companion matrix·3개 성격별 상반신 Golden·활동 forecast Golden·활동 회고 일지 Golden·5개 exclusive follow-up')
      .replaceAll('3개 성격별 page 1 상반신 Golden, 16개 closure Golden',
          '3개 성격별 page 1 상반신 Golden·활동 forecast Golden·활동 회고 일지 Golden, 16개 closure Golden');
  if (!output.contains('엔딩 뒤 다음 회차 계승 선택 Golden')) {
    output = output.replaceAll(
        '3개 회차 계승 프로필', '3개 회차 계승 프로필·엔딩 뒤 다음 회차 계승 선택 Golden(ko/en)');
  }
  if (!output.contains('엔딩 뒤 계승 프로필 선택 Golden')) {
    output = output.replaceAll('3개 계승 프로필·3개 프로필별 선택 보정',
        '3개 계승 프로필·엔딩 뒤 계승 프로필 선택 Golden(ko/en)·3개 프로필별 선택 보정');
  }
  if (!output.contains('계승 policy forecast Canvas Golden')) {
    output = output.replaceAll(
        '엔딩 뒤 계승 프로필 선택 Golden(ko/en)·3개 프로필별 선택 보정',
        '엔딩 뒤 계승 프로필 선택 Golden(ko/en)·계승 policy forecast Canvas Golden·3개 프로필별 선택 보정');
  }
  if (!output.contains('explicit ending picker')) {
    output = output.replaceAll('collection-driven legacy unlock',
        'collection-driven legacy unlock with explicit ending picker');
  }
  if (!output.contains('next-run home lineage feedback')) {
    output = output.replaceAll('explicit ending picker',
        'explicit ending picker with next-run home lineage feedback');
  }
  output = output
      .replaceAll('Canvas UI 다섯 상태 행렬·활동 forecast·활동 회고 일지·실제',
          'Canvas UI 다섯 상태 행렬·활동 forecast·활동 회고 일지(ko/en)·실제')
      .replaceAll('Canvas UI 다섯 상태 행렬·실제 16막 chapter closure와 관계 장면·관계 상태',
          'Canvas UI 다섯 상태 행렬·활동 forecast·활동 회고 일지(ko/en)·실제 16막 chapter closure와 관계 장면·관계 상태')
      .replaceAll(
          '3개 성격별 page 1 상반신 Golden·활동 forecast Golden, 16개 closure Golden',
          '3개 성격별 page 1 상반신 Golden·활동 forecast Golden·활동 회고 일지 Golden(ko/en), 16개 closure Golden')
      .replaceAll(
          '3개 성격별 page 1 상반신 Golden·활동 forecast Golden·활동 회고 일지 Golden, 16개 closure Golden',
          '3개 성격별 page 1 상반신 Golden·활동 forecast Golden·활동 회고 일지 Golden(ko/en), 16개 closure Golden')
      .replaceAll('세 성격의 관계 공명 archive 화면과 활동 forecast·활동 회고 일지·세 성격별',
          '세 성격의 관계 공명 archive 화면과 활동 forecast·활동 회고 일지(ko/en)·세 성격별')
      .replaceAll('세 성격의 관계 공명 archive 화면과 세 성격별 page 1 상반신 일러스트 화면을 추가해',
          '세 성격의 관계 공명 archive 화면과 활동 forecast·활동 회고 일지(ko/en)·세 성격별 page 1 상반신 일러스트 화면을 추가해');
  output = output
      .replaceAll('`replayChecksum`, signature cardinality',
          '`replayChecksum`·activity forecast checksum·companionSceneChecksum, signature cardinality')
      .replaceAll(
          '`replayChecksum`·activity forecast checksum, signature cardinality',
          '`replayChecksum`·activity forecast checksum·companionSceneChecksum, signature cardinality')
      .replaceAll('475,000', '565,000')
      .replaceAll('475000', '565000')
      .replaceAll('47개 사건 선택을 처리하는 시간을 측정한다.',
          '47개 사건 선택과 최대 18개 동료 독립 장면 기록을 처리하는 시간을 측정한다.');
  if (!output.contains('`lineageDistribution`은')) {
    output = output.replaceAll(
        '프로필의 성장축을 결정론적으로 선택하고 시작 스탯 변형을 적용한다.',
        '프로필의 성장축을 결정론적으로 선택하고 시작 스탯 변형을 적용한다. `lineageDistribution`은 각 프로필을 5개 SSOT 일정 정책으로 재생해 최소 3개 ending·3개 signature와 서로 다른 fingerprint를 요구한다.');
  }
  if (!output.contains('관측 4개 ending·4개 signature')) {
    output = output.replaceAll(
        '`lineageDistribution`은 각 프로필을 5개 SSOT 일정 정책으로 재생해 최소 3개 ending·3개 signature와 서로 다른 fingerprint를 요구한다.',
        '`lineageDistribution`은 각 프로필을 5개 SSOT 일정 정책으로 재생해 최소 3개 ending·3개 signature와 서로 다른 fingerprint를 요구한다. 관측 4개 ending·4개 signature·3개 fingerprint를 benchmark가 정확히 대조하고, `legacy-picker.png` Canvas forecast가 같은 SSOT 수치를 표시한다.');
  }
  if (!output.contains('5개 정책 × 3개 프로필 ending/signature 분포')) {
    output = output.replaceAll('3개 lineage 분포·계승 프로필 순환을 계약으로 고정한다.',
        '3개 lineage 분포·5개 정책 × 3개 프로필 ending/signature 분포·계승 프로필 순환을 계약으로 고정한다.');
  }
  if (!output.contains('6개 대표 Canvas page')) {
    output = output.replaceAll('따라서 네트워크·폰트·브라우저 상태와 무관하게',
        '별도 Canvas paint budget은 home/event/ending/ledger/relationship/companion 6개 대표 Canvas page를 동일 Scene.paint 경로로 24회씩 렌더링해 평균 8,000µs 미만을 강제한다. 따라서 네트워크·폰트·브라우저 상태와 무관하게');
  }
  output = output
      .replaceAll(
          '18개 동료 독립 장면·10개 활동 미니 이벤트', '18개 동료 독립 장면·36개 동행 선택·10개 활동 미니 이벤트')
      .replaceAll('18 companion scenes·10개 activity mini-events',
          '18 companion scenes·36 companion choices·10개 activity mini-events')
      .replaceAll('page 13 companion scene record ko/en',
          'page 13 companion choice/record/locked/mixed ko/en')
      .replaceAll(
          '`companion-scenes.png`·`companion-scene-recorded.png`·`companion-scene-recorded-en.png`',
          '`companion-scenes.png`·`companion-scene-choice.png`·`companion-scene-recorded.png`·`companion-scene-recorded-en.png`·3개 동료 mixed/locked Golden')
      .replaceAll('72/166(0.4337) trade-off 선택',
          '72/166(0.4337) trade-off 선택과 36/36 companion choice impact')
      .replaceAll('72/166 trade-off choices',
          '72/166 trade-off choices·36/36 companion choices');
  output = output
      .replaceAll(
          RegExp(
              r'72/166\(0\.4337\) trade-off 선택(?:과 36/36 companion choice impact)+'),
          '72/166(0.4337) trade-off 선택과 36/36 companion choice impact')
      .replaceAll(
          RegExp(r'72/166 trade-off choices(?:·36/36 companion choices)+'),
          '72/166 trade-off choices·36/36 companion choices');
  if (!output.contains('36/36 companion choice foresight')) {
    output = output.replaceAll(
        '72/166(0.4337) trade-off 선택과 36/36 companion choice impact',
        '72/166(0.4337) trade-off 선택과 36/36 companion choice impact·36/36 companion choice foresight');
  }
  return output;
}

void main(List<String> args) {
  final file = File('docs/trilemma.md');
  final current = file.readAsStringSync(), updated = render(current);
  if (args.contains('--check')) {
    if (current != updated) {
      stderr.writeln('TRILEMMA_DOC_FAIL: generated counts are stale');
      exit(1);
    }
    stdout.writeln('TRILEMMA_DOC_OK');
    return;
  }
  file.writeAsStringSync(updated);
  stdout.writeln('TRILEMMA_DOC_WRITTEN');
}
