import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Pill-shaped navigation with a contour that follows the selected tab.
class CurvedNav extends StatefulWidget {
  const CurvedNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const items = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home_rounded, 'Início'),
    (Icons.search_outlined, Icons.search_rounded, 'Buscar'),
    (Icons.library_music_outlined, Icons.library_music_rounded, 'Biblioteca'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Hotlist'),
  ];

  @override
  State<CurvedNav> createState() => _CurvedNavState();
}

class _CurvedNavState extends State<CurvedNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _position = AlwaysStoppedAnimation<double>(widget.index.toDouble());
  }

  @override
  void didUpdateWidget(covariant CurvedNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final start = _position.value;
      _controller.reset();
      _position = Tween<double>(
        begin: start,
        end: widget.index.toDouble(),
      ).chain(CurveTween(curve: Curves.easeInOutCubic)).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = context.ink;
    final muted = context.muted;
    final accent = context.isDark ? const Color(0xFFF17386) : ink;
    return SizedBox(
      height: 72,
      child: LayoutBuilder(builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / CurvedNav.items.length;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned(
                  left: (_position.value - .8) * cellWidth,
                  width: cellWidth * 2.6,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _SelectionContour(
                        cellWidth: cellWidth,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < CurvedNav.items.length; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: widget.index == i,
                          label: CurvedNav.items[i].$3,
                          child: InkWell(
                            onTap: () => widget.onChanged(i),
                            borderRadius: BorderRadius.circular(18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedSlide(
                                  offset: widget.index == i
                                      ? const Offset(0, -.15)
                                      : Offset.zero,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  child: AnimatedScale(
                                    scale: widget.index == i ? 1.13 : 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 240),
                                      switchInCurve: Curves.easeOutCubic,
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                      ),
                                      child: Icon(
                                        widget.index == i
                                            ? CurvedNav.items[i].$2
                                            : CurvedNav.items[i].$1,
                                        key: ValueKey(
                                            'nav-$i-${widget.index == i}'),
                                        color:
                                            widget.index == i ? accent : muted,
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: widget.index == i ? ink : muted,
                                    fontWeight: widget.index == i
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    CurvedNav.items[i].$3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }
}

class _SelectionContour extends CustomPainter {
  const _SelectionContour({
    required this.cellWidth,
    required this.color,
  });

  final double cellWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final base = size.height - 5;
    final crest = 6.0;
    final spread = math.min(cellWidth * .65, 60.0);
    final shoulder = spread * .48;
    final path = Path()
      ..moveTo(0, base)
      ..lineTo(center - spread, base)
      ..cubicTo(
        center - shoulder,
        base,
        center - spread,
        crest,
        center,
        crest,
      )
      ..cubicTo(
        center + spread,
        crest,
        center + shoulder,
        base,
        center + spread,
        base,
      )
      ..lineTo(size.width, base);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [Colors.transparent, color, Colors.transparent],
      ).createShader(
          Rect.fromLTRB(center - spread * 2, 0, center + spread * 2, base));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SelectionContour oldDelegate) =>
      cellWidth != oldDelegate.cellWidth || color != oldDelegate.color;
}
