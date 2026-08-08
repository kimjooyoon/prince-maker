import 'dart:io';

String render(String source) {
  final goldens = Directory('test/goldens')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.png'))
      .length;
  final header = '<!-- generated: tool/refresh_trilemma_docs.dart -->\n';
  var output = source.startsWith(header) ? source : '$header$source';
  output = output
      .replaceAll(RegExp(r'Golden \d+종'), 'Golden ${goldens}종')
      .replaceAll(RegExp(r'\d+개 Golden'), '${goldens}개 Golden')
      .replaceAll(RegExp(r'Canvas Golden 증적은 \d+장'),
          'Canvas Golden 증적은 ${goldens}장')
      .replaceAll(
          '세 성격의 관계 공명 archive 화면을 추가해 현재 Canvas Golden 증적은 ${goldens}장이다.',
          '세 성격의 관계 공명 archive 화면과 세 성격별 page 1 상반신 일러스트 화면을 추가해 현재 Canvas Golden 증적은 ${goldens}장이다.')
      .replaceAll(
          'SSOT sheetIndex binding, 16개 closure Golden',
          'SSOT sheetIndex binding, 3개 성격별 page 1 상반신 Golden, 16개 closure Golden')
      .replaceAll(
          '3×3 personality×companion matrix·5개 exclusive follow-up',
          '3×3 personality×companion matrix·3개 성격별 상반신 Golden·5개 exclusive follow-up');
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
