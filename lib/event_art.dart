import 'dart:ui' as ui;

const lumenMajorCharacterIds = <String>['noa', 'lumi', 'bora', 'taro'];

String eventIllustrationAsset(Map<String, dynamic> event) =>
    event['illustrationAsset'] as String? ??
    'assets/generated/event-illustrations/event-${event['week']}.png';

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
