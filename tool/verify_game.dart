import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

Never fail(String message) { stderr.writeln('GAME_GATE_FAIL: $message'); exit(1); }
void main() {
  final story = jsonDecode(File('story/story.json').readAsStringSync()) as Map<String, dynamic>;
  final activities = (story['activities'] as List).cast<Map<String, dynamic>>();
  final people = (story['personalities'] as List).cast<Map<String, dynamic>>();
  final events = (story['events'] as List).cast<Map<String, dynamic>>();
  final refs = (story['codeRefs'] as List).cast<Map<String, dynamic>>();
  if (story['endingWeek'] != 12) fail('endingWeek must be 12');
  if (activities.length != 3 || people.length != 3) fail('expected 3 activities and 3 personalities');
  if ({...activities.map((e) => e['id'])}.length != activities.length) fail('activity ids are not unique');
  if ({...people.map((e) => e['id'])}.length != people.length) fail('personality ids are not unique');
  if (events.map((e) => e['week']).toList().join(',') != '4,8') fail('events must occur at weeks 4 and 8');
  for (final ref in refs) { final path = (ref['ref'] as String).split('#').first; if (!File(path).existsSync()) fail('missing code ref $path'); final actual = sha256.convert(File(path).readAsBytesSync()).toString(); if (actual != ref['sha256']) fail('code ref hash drift: $path'); }
  final stats = activities.map((e) => e['stat']).toSet();
  if (activities.any((e) => e['fatigue'] is! int || e['fatigue'] < 0)) fail('every activity needs non-negative fatigue');
  for (final event in events) {
    final choices = (event['choices'] as List).cast<Map<String, dynamic>>();
    if (choices.length != 2) fail('each event needs exactly 2 choices');
    for (final choice in choices) {
      if (!stats.contains(choice['stat'])) fail('event choice targets an unknown stat');
      if (choice['delta'] is! int || choice['coins'] is! int) fail('event deltas must be ints');
    }
  }
  final combinations = activities.length * (story['endingWeek'] as int);
  stdout.writeln('GAME_GATE_OK: activities=${activities.length} personalities=${people.length} events=${events.length} codeRefs=${refs.length} combinations=$combinations score=100%');
}
