import 'package:flutter/material.dart';

const crimson = Color(0xFFD51A32);
const charcoal = Color(0xFF202125);

class CurvedNav extends StatelessWidget {
  const CurvedNav({
    super.key,
    required this.index,
    required this.onChanged,
  });
  final int index;
  final ValueChanged<int> onChanged;

  static const items = <(IconData, String)>[
    (Icons.home_outlined, 'Início'),
    (Icons.search_rounded, 'Buscar'),
    (Icons.library_music_outlined, 'Biblioteca'),
    (Icons.queue_music_rounded, 'Playlists'),
    (Icons.tune_rounded, 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 8, 17, 12),
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: charcoal,
          borderRadius: BorderRadius.circular(37),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(37),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: index.toDouble()),
            duration: const Duration(milliseconds: 430),
            curve: Curves.easeInOutCubic,
            builder: (context, active, child) => Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(painter: _RibbonPainter(active)),
                child!,
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: index == i,
                      label: items[i].$2,
                      child: InkWell(
                        onTap: () => onChanged(i),
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: index == i ? 1.13 : 1,
                              duration: const Duration(milliseconds: 280),
                              child: Icon(
                                items[i].$1,
                                color: index == i ? crimson : const Color(0xFFE3E3E6),
                                size: 23,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              items[i].$2,
                              style: TextStyle(
                                color: index == i ? Colors.white : const Color(0xFFBFC0C4),
                                fontSize: 10,
                                fontWeight: index == i ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: 3,
                              width: index == i ? 4 : 0,
                              decoration: const BoxDecoration(
                                color: crimson,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter(this.active);
  final double active;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = (active + .5) * size.width / CurvedNav.items.length;
    const baseY = 80.0;
    final trace = Path()
      ..moveTo(0, baseY)
      ..lineTo(centerX - 55, baseY)
      ..cubicTo(centerX - 48, baseY, centerX - 48, 10, centerX, 9)
      ..cubicTo(centerX + 48, 10, centerX + 48, baseY, centerX + 55, baseY)
      ..lineTo(size.width, baseY);
    canvas.drawPath(
      trace,
      Paint()
        ..color = crimson
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(centerX, size.height - 7),
      3,
      Paint()..color = crimson.withValues(alpha: .7),
    );
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) => active != oldDelegate.active;
}
