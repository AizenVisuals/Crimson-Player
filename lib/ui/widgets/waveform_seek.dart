import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveformSeek extends StatelessWidget {
  const WaveformSeek({
    super.key,
    required this.progress,
    required this.onSeek,
  });
  final double progress;
  final ValueChanged<double> onSeek;

  void _setPosition(double x, double width) {
    if (width > 0) onSeek((x / width).clamp(0, 1).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (event) => _setPosition(event.localPosition.dx, constraints.maxWidth),
        onHorizontalDragUpdate: (event) =>
            _setPosition(event.localPosition.dx, constraints.maxWidth),
        child: Semantics(
          label: 'Progresso da música',
          value: (progress * 100).round().toString() + '%',
          child: SizedBox(
            height: 64,
            child: CustomPaint(
              painter: _WavePainter(progress.clamp(0, 1).toDouble()),
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 65;
    final segment = size.width / count;
    for (var i = 0; i < count; i++) {
      final t = i / count;
      final envelope = .24 + .76 * math.pow(math.sin(t * math.pi), 2);
      final detail = .22 + .78 * (math.sin(i * .89).abs() + math.sin(i * 1.93).abs()) / 2;
      final height = size.height * envelope * detail;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset((i + .5) * segment, size.height / 2),
            width: math.max(2, segment * .36),
            height: math.max(3, height),
          ),
          const Radius.circular(4),
        ),
        Paint()
          ..color = t <= progress
              ? const Color(0xFF202125)
              : const Color(0xFFDADCE0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
