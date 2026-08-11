import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'star_cellar.dart';

class StarCellarPainter {
  const StarCellarPainter(this.state, this.localized);
  final CellarState state;
  final String Function(String key, String fallback) localized;

  static const room = Rect.fromLTWH(44, 132, 450, 365);
  static const tile = 58.0;
  static const origin = Offset(65, 160);
  static final actionRects = <CellarAction, Rect>{
    CellarAction.up: const Rect.fromLTWH(190, 535, 64, 42),
    CellarAction.left: const Rect.fromLTWH(112, 582, 64, 42),
    CellarAction.pulse: const Rect.fromLTWH(190, 582, 64, 42),
    CellarAction.right: const Rect.fromLTWH(268, 582, 64, 42),
    CellarAction.down: const Rect.fromLTWH(190, 629, 64, 42),
  };

  static CellarAction? actionAt(Offset point) {
    for (final entry in actionRects.entries) {
      if (entry.value.contains(point)) return entry.key;
    }
    return null;
  }

  static bool backAt(Offset point) =>
      const Rect.fromLTWH(24, 640, 140, 42).contains(point);

  void _text(
    Canvas c,
    String value,
    Offset point,
    double size,
    Color color, {
    bool bold = false,
    double width = 330,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'NotoSansKR',
          fontSize: size,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    painter.paint(c, point);
  }

  void _panel(Canvas c, Rect rect, Color fill, {Color stroke = teal}) {
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      Paint()..color = fill,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _point(Canvas c, CellarPoint point, Color color, {double radius = 18}) {
    c.drawCircle(
      origin + Offset(point.x * tile + tile / 2, point.y * tile + tile / 2),
      radius,
      Paint()..color = color,
    );
  }

  void paint(Canvas c) {
    c.drawColor(paper, BlendMode.srcOver);
    _text(
      c,
      localized('ui.miniGame.title', '별지하실 · Star Cellar'),
      const Offset(24, 24),
      28,
      ink,
      bold: true,
    );
    _text(
      c,
      localized('ui.miniGame.subtitle', '빛을 모으고, 흔들리는 마음을 피한다.'),
      const Offset(25, 65),
      13,
      teal,
      width: 470,
    );
    _text(
      c,
      localized(
        'ui.miniGame.hud',
        'HEARTS {hearts} · SHARDS {shards}/3 · TURN {turn}',
      )
          .replaceAll('{hearts}', '${state.hearts}')
          .replaceAll('{shards}', '${3 - state.shards.length}')
          .replaceAll('{turn}', '${state.turn}'),
      const Offset(520, 82),
      11,
      teal,
      bold: true,
      width: 220,
    );
    _panel(c, room, twilight, stroke: mist);
    for (var y = 0; y < StarCellarEngine.height; y++) {
      for (var x = 0; x < StarCellarEngine.width; x++) {
        final r = Rect.fromLTWH(
          origin.dx + x * tile,
          origin.dy + y * tile,
          tile - 4,
          tile - 4,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(r, const Radius.circular(9)),
          Paint()
            ..color = (x + y) % 2 == 0
                ? const Color(0xff30365f)
                : const Color(0xff2b3157),
        );
      }
    }
    final exit = origin +
        Offset(state.exit.x * tile + tile / 2, state.exit.y * tile + tile / 2);
    c.drawRect(
      Rect.fromCenter(center: exit, width: 28, height: 36),
      Paint()..color = state.shards.isEmpty ? sun : mist,
    );
    for (final shard in state.shards) {
      final p =
          origin + Offset(shard.x * tile + tile / 2, shard.y * tile + tile / 2);
      final path = Path()
        ..moveTo(p.dx, p.dy - 15)
        ..lineTo(p.dx + 13, p.dy)
        ..lineTo(p.dx, p.dy + 15)
        ..lineTo(p.dx - 13, p.dy)
        ..close();
      c.drawPath(path, Paint()..color = sun);
    }
    for (final wisp in state.wisps)
      _point(c, wisp, const Color(0xffe47d8e), radius: 14);
    _point(c, state.player, const Color(0xff9fe0c9), radius: 20);
    _text(
      c,
      localized('ui.miniGame.exit', '출구'),
      exit + const Offset(-14, 22),
      8,
      state.shards.isEmpty ? sun : mist,
      bold: true,
      width: 50,
    );
    _panel(
      c,
      const Rect.fromLTWH(520, 132, 216, 365),
      Colors.white,
      stroke: teal,
    );
    _text(
      c,
      localized('ui.miniGame.goal', '방의 약속'),
      const Offset(540, 154),
      17,
      ink,
      bold: true,
    );
    _text(
      c,
      localized(
        'ui.miniGame.help',
        '빛 조각 3개를 모으면 출구가 열린다.\n붉은 잔광과 같은 칸에 서면 마음이 하나 흔들린다.\n펄스는 잔광의 방향을 바꾼다.',
      ),
      const Offset(540, 195),
      11,
      ink,
      width: 175,
    );
    final message = state.won
        ? localized('ui.miniGame.won', '방을 통과했다 · 은빛 기록 +{score}')
        : state.lost
            ? localized('ui.miniGame.lost', '잔광에 닿았다 · 다시 걸을 수 있다')
            : localized('ui.miniGame.ready', '한 칸씩 선택해 다음 빛을 찾자.');
    _text(
      c,
      message.replaceAll('{score}', '${state.score}'),
      const Offset(540, 365),
      11,
      state.lost ? const Color(0xffa84f3c) : teal,
      bold: true,
      width: 170,
    );
    for (final entry in actionRects.entries) {
      _panel(
        c,
        entry.value,
        entry.key == CellarAction.pulse ? sun : paper,
        stroke: teal,
      );
      final label = switch (entry.key) {
        CellarAction.up => '↑',
        CellarAction.down => '↓',
        CellarAction.left => '←',
        CellarAction.right => '→',
        CellarAction.pulse => '*',
        CellarAction.reset => '↺',
      };
      _text(
        c,
        label,
        entry.value.topLeft + const Offset(24, 8),
        22,
        ink,
        bold: true,
        width: 30,
      );
    }
    _panel(
      c,
      const Rect.fromLTWH(24, 640, 140, 42),
      Colors.white,
      stroke: teal,
    );
    _text(
      c,
      localized('ui.miniGame.back', '← 루멘으로'),
      const Offset(45, 653),
      12,
      teal,
      bold: true,
      width: 110,
    );
  }
}
