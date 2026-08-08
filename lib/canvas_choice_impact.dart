import 'dart:ui';

import 'choice_impact.dart';

/// Paints the authored choice contract without font rasterization.
/// Teal is a reward axis; amber is a cost axis. A split bar is a visible
/// trade-off while a single-color bar is a commitment to one direction.
void drawChoiceImpact(Canvas canvas, Rect bounds, Map<String, dynamic> choice) {
  final impact = ChoiceImpact.from(choice),
      track = RRect.fromRectAndRadius(bounds, const Radius.circular(4)),
      rewardWidth = bounds.width * (impact.rewardAxes / 4).clamp(0, 1),
      costWidth = bounds.width * (impact.costAxes / 4).clamp(0, 1);
  canvas.drawRRect(track, Paint()..color = const Color(0x1f273452));
  if (rewardWidth > 0) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(bounds.left, bounds.top, rewardWidth, bounds.height),
            const Radius.circular(4)),
        Paint()..color = const Color(0xff4eaaa5));
  }
  if (costWidth > 0) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                bounds.right - costWidth, bounds.top, costWidth, bounds.height),
            const Radius.circular(4)),
        Paint()..color = const Color(0xffd3a43b));
  }
}
