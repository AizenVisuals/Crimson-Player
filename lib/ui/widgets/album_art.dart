import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import '../../models/music_track.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({super.key, this.track, this.radius = 24});
  final MusicTrack? track;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 1,
        child: track?.artworkId == null
            ? const CustomPaint(painter: _ArtPainter())
            : QueryArtworkWidget(
                id: track!.artworkId!,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.zero,
                artworkFit: BoxFit.cover,
                artworkWidth: double.infinity,
                artworkHeight: double.infinity,
                nullArtworkWidget: const CustomPaint(painter: _ArtPainter()),
              ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  const _ArtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B1320), Color(0xFF192330), Color(0xFF04070D)],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final center = Offset(size.width * .53, size.height * .48);
    final base = size.shortestSide * .31;
    canvas.drawCircle(
      center.translate(0, size.height * .025),
      base * 1.08,
      Paint()
        ..color = const Color(0xFF000000).withValues(alpha: .38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final disc = Path();
    for (var i = 0; i <= 160; i++) {
      final angle = i / 160 * math.pi * 2;
      final r = base * (1 + .025 * math.sin(7 * angle) + .012 * math.cos(17 * angle));
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        disc.moveTo(point.dx, point.dy);
      } else {
        disc.lineTo(point.dx, point.dy);
      }
    }
    disc.close();
    canvas.drawPath(
      disc,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.25, -.34),
          colors: [Color(0xFFF7F7F5), Color(0xFFCDD1D4), Color(0xFF707D8C)],
        ).createShader(rect),
    );

    final stroke = Paint()
      ..color = const Color(0xFF596271).withValues(alpha: .35)
      ..strokeWidth = size.shortestSide * .004;
    for (var i = 0; i < 14; i++) {
      final angle = i * math.pi / 7 + .3;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * base * .13;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * base * .95;
      canvas.drawLine(start, end, stroke);
    }
    canvas.drawCircle(center, base * .07, Paint()..color = const Color(0xFF9CA5B0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
