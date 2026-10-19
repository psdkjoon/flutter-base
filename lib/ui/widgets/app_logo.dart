import 'package:flutter/material.dart';
import 'package:{{projectName}}/theme/catppuccin.dart';

/// The app mark, drawn with vector paths so it stays sharp at any size and
/// follows the current accent color and theme, like the launcher icon does.
class AppLogo extends StatelessWidget {
  const AppLogo({required this.size, super.key});

  final double size;

  // How much of the accent is mixed into the neutral base to get the tile color.
  static const double _darkMix = 0.12;
  static const double _lightMix = 0.22;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final base =
        (dark ? CatppuccinPalette.mocha : CatppuccinPalette.latte).base;
    final tile = Color.lerp(base, scheme.primary, dark ? _darkMix : _lightMix)!;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _LogoPainter(glyph: scheme.primary, tile: tile),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.glyph, required this.tile});

  final Color glyph;
  final Color tile;

  // The same 24 x 24 drawing as the launcher icon.
  static final Path _glyph = Path()
    ..moveTo(12, 3.4)
    ..cubicTo(12.6, 8.2, 15.8, 11.4, 20.6, 12)
    ..cubicTo(15.8, 12.6, 12.6, 15.8, 12, 20.6)
    ..cubicTo(11.4, 15.8, 8.2, 12.6, 3.4, 12)
    ..cubicTo(8.2, 11.4, 11.4, 8.2, 12, 3.4)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawRRect(
      RRect.fromRectXY(const Rect.fromLTWH(0, 0, 24, 24), 6.16, 6.16),
      Paint()..color = tile,
    );
    canvas.drawPath(_glyph, Paint()..color = glyph);
    canvas.drawCircle(const Offset(12, 12), 1.5, Paint()..color = tile);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.glyph != glyph || old.tile != tile;
}
