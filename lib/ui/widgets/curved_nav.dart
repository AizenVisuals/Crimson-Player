import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Animated navigation selector.
/// The active capsule travels between destinations under AnimationController,
/// while the selected icon gently scales and fades into its filled variant.
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
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
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
                  left: (_position.value * cellWidth) + cellWidth * .15,
                  top: 5,
                  width: cellWidth * .7,
                  height: 57,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.raised.withValues(
                        alpha: context.isDark ? .85 : .58,
                      ),
                      borderRadius: BorderRadius.circular(18),
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
                                AnimatedScale(
                                  scale: widget.index == i ? 1.13 : 1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 240),
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
                                      key: ValueKey('nav-$i-${widget.index == i}'),
                                      color: widget.index == i ? ink : muted,
                                      size: 21,
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
