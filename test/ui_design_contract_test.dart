import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';

void main() {
  test('design token catalog covers every game UI surface', () {
    final document =
        decodeJsonl(File('design/tokens.jsonl').readAsStringSync());
    final lines = File('design/tokens.jsonl').readAsLinesSync();
    final componentLine =
        lines.firstWhere((line) => jsonDecode(line)['key'] == 'components');
    final components =
        (jsonDecode(componentLine)['value'] as Map).cast<String, dynamic>();
    expect(
        components.keys,
        containsAll(<String>[
          'app_shell',
          'status_hud',
          'stat_panel',
          'stat_pill',
          'fatigue_meter',
          'goal_callout',
          'progress_tracker',
          'activity_card',
          'primary_action',
          'secondary_action',
          'feedback_banner',
          'choice_card',
          'requirement_badge',
          'speaker_portrait',
          'dialogue_panel',
          'portrait_page',
          'route_atlas',
          'side_scene_card',
          'chapter_closure_scene',
          'environment_card',
          'environment_surface',
          'character_card',
          'character_art_panel',
          'emotion_chip',
          'relationship_archive_panel',
          'ledger_thread_card',
          'quest_progress_card',
          'receipt_row',
          'save_code_panel',
          'ending_panel',
          'empty_state',
          'locale_toggle',
          'navigation_footer',
        ]));
    expect(components['choice_card']['states'],
        containsAll(['idle', 'selected', 'disabled']));
    expect(components['feedback_banner']['states'],
        containsAll(['empty', 'success', 'warning', 'danger']));
    expect(components['emotion_chip']['states'],
        containsAll(['idle', 'selected']));
    expect(components['relationship_archive_panel']['states'],
        containsAll(['resolved', 'replayable']));
    final variants = document['canvasComponentVariants'] as List;
    expect(
        variants,
        containsAll([
          'panel',
          'card',
          'button',
          'hud',
          'dialogue',
          'status',
          'locked'
        ]));
    final states = document['uiStates'] as List;
    expect(
        states,
        containsAll(
            ['idle', 'selected', 'disabled', 'warning', 'success', 'danger']));
  });
}
