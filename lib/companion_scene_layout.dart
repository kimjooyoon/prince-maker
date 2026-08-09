import 'dart:ui' as ui;

/// Shared geometry for the companion archive's Canvas and input projections.
///
/// Keeping these rectangles in one place makes a Golden's visible controls and
/// the hit targets evolve together. The logical coordinates are the same
/// coordinates used by [CanvasViewport].
class CompanionSceneLayout {
  const CompanionSceneLayout._();

  static const cardWidth = 340.0;
  static const cardHeight = 116.0;
  static const cardStartX = 24.0;
  static const cardStartY = 216.0;
  static const cardColumnStep = 356.0;
  static const cardRowStep = 130.0;
  static const maxVisibleCards = 6;

  static const previousRect = ui.Rect.fromLTWH(24, 604, 176, 38);
  static const nextRect = ui.Rect.fromLTWH(560, 604, 176, 38);
  static const backRect = ui.Rect.fromLTWH(0, 650, 760, 50);
  // The visible controls stay precise while the hit targets absorb the
  // centered Canvas transform on compact viewports.
  static const previousHitRect = ui.Rect.fromLTWH(0, 590, 250, 110);
  static const nextHitRect = ui.Rect.fromLTWH(510, 590, 250, 110);

  static ui.Rect cardRect(int index) {
    final column = index % 2, row = index ~/ 2;
    return ui.Rect.fromLTWH(cardStartX + column * cardColumnStep,
        cardStartY + row * cardRowStep, cardWidth, cardHeight);
  }

  static ui.Rect choiceRect(int sceneIndex, int choiceIndex) {
    final card = cardRect(sceneIndex);
    return ui.Rect.fromLTWH(
        card.left + 12 + choiceIndex * 162, card.top + 90, 154, 20);
  }

  static ui.Rect choiceHitRect(int sceneIndex, int choiceIndex) {
    final card = cardRect(sceneIndex);
    return ui.Rect.fromLTWH(
        card.left + 12 + choiceIndex * 162, card.top + 48, 154, 102);
  }

  static bool containsInclusive(ui.Rect rect, ui.Offset point) =>
      point.dx >= rect.left &&
      point.dx <= rect.right &&
      point.dy >= rect.top &&
      point.dy <= rect.bottom;

  static int? cardIndexAt(ui.Offset point, int sceneCount) {
    final count = sceneCount.clamp(0, maxVisibleCards);
    for (var index = 0; index < count; index++) {
      if (cardRect(index).contains(point)) return index;
    }
    return null;
  }

  static int? choiceIndexAt(ui.Offset point, int sceneIndex) {
    for (var index = 0; index < 2; index++) {
      if (containsInclusive(choiceHitRect(sceneIndex, index), point)) {
        return index;
      }
    }
    return null;
  }
}
