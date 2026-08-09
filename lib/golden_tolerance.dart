const double canvasGoldenTolerance = 0.025;

bool acceptsCanvasGoldenDiff({
  required bool exactMatch,
  required double diffPercent,
}) {
  if (exactMatch) return true;
  return diffPercent.isFinite &&
      diffPercent >= 0 &&
      diffPercent <= canvasGoldenTolerance;
}
