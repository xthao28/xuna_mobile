import 'package:flutter/material.dart';

/// Visual vocabulary only; this widget has no device or pet-life dependency.
enum AppPetExpression { idle, happy, curious, sleep }

enum AppPetBackground { room, reading, garden }

/// Shared XUNA artwork for scenes, portraits and decorative illustrations.
class AppXunaPet extends StatelessWidget {
  const AppXunaPet({
    super.key,
    this.expression = AppPetExpression.idle,
    this.animated = false,
    this.scene = false,
    this.background,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final AppPetExpression expression;
  final bool animated;
  final bool scene;
  final AppPetBackground? background;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final play = (scene || background != null) &&
        animated &&
        TickerMode.of(context) &&
        !MediaQuery.disableAnimationsOf(context);
    final prefix = background != null
        ? 'xuna_pet'
        : scene
            ? 'xuna'
            : 'xuna_pet';
    final path =
        'assets/images/${prefix}_${expression.name}.${play ? 'gif' : 'png'}';
    final pet = Image.asset(
      path,
      key: ValueKey(path),
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.none,
      excludeFromSemantics: true,
    );
    if (background == null) return pet;
    return SizedBox(
      width: width,
      height: height,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _PixelBackdrop(background!)),
              Align(
                alignment: const Alignment(0, 0.65),
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  heightFactor: 0.56,
                  child: Image.asset(path,
                      key: ValueKey(path),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      excludeFromSemantics: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A 80×60 grid: broad flat colors, no textures or gradients.
class _PixelBackdrop extends CustomPainter {
  const _PixelBackdrop(this.background);
  final AppPetBackground background;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 80, size.height / 60);
    final paint = Paint()..isAntiAlias = false;
    void block(double x, double y, double w, double h, Color color) {
      paint.color = color;
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
    }

    const ink = Color(0xff40364e);
    const wall = Color(0xffb8a5c8);
    const floor = Color(0xff8e799e);
    const olive = Color(0xff8f9d64);
    const light = Color(0xfff5d6a0);
    block(0, 0, 80, 60, wall);
    block(0, 40, 80, 20, floor);
    block(0, 39, 80, 1, ink);
    switch (background) {
      case AppPetBackground.room:
        block(6, 8, 20, 23, ink);
        block(8, 10, 16, 19, light);
        block(15, 10, 2, 19, ink);
        block(8, 19, 16, 2, ink);
        block(65, 31, 9, 11, ink);
        block(66, 32, 7, 8, light);
        block(68, 22, 3, 10, olive);
        block(63, 25, 6, 4, olive);
        block(71, 20, 5, 5, olive);
        break;
      case AppPetBackground.reading:
        block(5, 13, 21, 23, ink);
        block(7, 15, 17, 8, floor);
        block(7, 25, 17, 9, floor);
        block(9, 16, 3, 7, light);
        block(14, 18, 4, 5, olive);
        block(19, 16, 3, 7, wall);
        block(9, 29, 12, 3, light);
        block(64, 35, 11, 3, ink);
        block(66, 38, 2, 5, ink);
        block(71, 38, 2, 5, ink);
        block(68, 25, 2, 10, ink);
        block(64, 21, 10, 5, light);
        break;
      case AppPetBackground.garden:
        block(0, 34, 80, 26, olive);
        block(0, 43, 80, 17, light);
        block(0, 42, 80, 1, ink);
        for (final x in [5.0, 17.0, 29.0, 41.0, 53.0, 65.0]) {
          block(x, 29, 2, 13, floor);
        }
        block(0, 33, 80, 2, floor);
        block(8, 9, 12, 3, light);
        block(11, 7, 6, 2, light);
        block(59, 14, 14, 3, light);
        block(62, 12, 7, 2, light);
        block(6, 40, 2, 6, ink);
        block(4, 38, 6, 3, wall);
        block(70, 39, 2, 7, ink);
        block(68, 37, 6, 3, wall);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PixelBackdrop oldDelegate) =>
      background != oldDelegate.background;
}
