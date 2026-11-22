import 'package:flutter/material.dart';

import '../../services/music_player.dart';
import '../app_theme.dart';
import 'curved_nav.dart';
import 'mini_player.dart';

/// Unified, compact bottom dock with an optional contrasting mini-player.
/// In both modes it behaves like the approved album-screen reference.
class PlayerNavigationBar extends StatelessWidget {
  const PlayerNavigationBar({
    super.key,
    required this.index,
    required this.onChanged,
    this.player,
    this.onOpenPlayer,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final MusicPlayer? player;
  final VoidCallback? onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 3, 12, 5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.canvas,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDark ? .15 : .07),
                offset: const Offset(0, -2),
                blurRadius: 18,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (player != null && onOpenPlayer != null)
                  MiniPlayer(player: player!, onOpen: onOpenPlayer!),
                CurvedNav(index: index, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
