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
  if (!output.contains('explicit ending picker')) {
    output = output.replaceAll('collection-driven legacy unlock',
        'collection-driven legacy unlock with explicit ending picker');
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
  output = output.replaceAll('`replayChecksum`, signature cardinality',
      '`replayChecksum`·activity forecast checksum, signature cardinality');
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
