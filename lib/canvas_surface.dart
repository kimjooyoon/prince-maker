import 'dart:math';
import 'dart:ui';

class CanvasFrame {
  const CanvasFrame(this.scale, this.offset);

  final double scale;
  final Offset offset;
}

class CanvasViewport {
  const CanvasViewport._();

  static const logicalSize = Size(760, 700);

  static CanvasFrame frame(Size viewport) {
    final scale = min(viewport.width / logicalSize.width,
            viewport.height / logicalSize.height)
        .clamp(.5, 1.0);
    return CanvasFrame(
      scale,
      Offset(
        (viewport.width - logicalSize.width * scale) / 2,
        (viewport.height - logicalSize.height * scale) / 2,
      ),
    );
  }

  static Offset logicalTap(Offset position, Size viewport) {
    final f = frame(viewport), local = (position - f.offset) / f.scale;
    return Offset(
      local.dx.clamp(0.0, logicalSize.width),
      local.dy.clamp(0.0, logicalSize.height),
    );
  }
}
