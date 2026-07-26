import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/game_core.dart';

void main() {
  test('same stats resolve to the same authored ending', () {
    final story = JsonStoryAdapter({'events': [], 'endings': [
      {'id':'a','stat':'지혜','title':'별'}, {'id':'b','stat':'공감','title':'정원'}, {'id':'c','stat':'용기','title':'길'}
    ]});
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
    expect(resolveEnding(story, {'지혜': 12, '공감': 6, '용기': 4})['id'], 'a');
  });
}
