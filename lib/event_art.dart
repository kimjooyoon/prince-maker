import 'dart:ui' as ui;

const lumenMajorCharacterIds = <String>['noa', 'lumi', 'bora', 'taro'];
const lumenSideSceneLocations = <String>[
  'archive',
  'greenhouse',
  'market',
  'observatory',
  'river-road',
  'quarry',
];

String eventIllustrationAsset(Map<String, dynamic> event) =>
    event['illustrationAsset'] as String? ??
    'assets/generated/event-illustrations/event-${event['week']}.png';

String sideSceneIllustrationAsset(Map<String, dynamic> scene) =>
    scene['illustrationAsset'] as String? ??
    'assets/generated/side-scene-illustrations/${scene['locationId']}.png';

int sideSceneIllustrationFrame(Map scene) =>
    (scene['illustrationFrame'] as int?) ?? 0;

void drawEventIllustration(
  ui.Canvas canvas,
  ui.Image image,
  ui.Rect destination,
) {
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    destination,
    ui.Paint(),
  );
}

void drawSideSceneIllustration(
  ui.Canvas canvas,
  ui.Image image,
  ui.Rect destination, {
  required int frame,
}) {
  final width = image.width / 4;
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(
        width * frame.clamp(0, 3), 0, width, image.height.toDouble()),
    destination,
    ui.Paint(),
  );
}
