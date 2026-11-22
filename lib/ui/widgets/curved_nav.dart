import 'package:flutter/material.dart';

/// Pill-shaped navigation with a highlight that follows the selected tab.
class CurvedNav extends StatefulWidget {
  const CurvedNav({super.key, required this.index, required this.onChanged});

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
    return SizedBox(
      height: 72,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / CurvedNav.items.length;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  Positioned(
                    left: (_position.value + .08) * cellWidth,
                    width: cellWidth * .84,
                    top: 7,
                    bottom: 7,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(20),
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
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOutBack,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 240,
                                        ),
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
                                            'nav-$i-${widget.index == i}',
                                          ),
                                          color: Colors.white.withValues(
                                            alpha: widget.index == i ? 1 : .8,
                                          ),
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
                                      color: Colors.white.withValues(
                                        alpha: widget.index == i ? 1 : .8,
                                      ),
                                      fontWeight: widget.index == i
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                                    child: Text(
                                      CurvedNav.items[i].$3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedOpacity(
                                    opacity: widget.index == i ? 1 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SizedBox.square(dimension: 5),
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
        },
      ),
    );
  }
}
