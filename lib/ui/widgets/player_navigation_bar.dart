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
        padding: const EdgeInsets.fromLTRB(14, 3, 14, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (player != null && onOpenPlayer != null)
              MiniPlayer(player: player!, onOpen: onOpenPlayer!),
            Material(
              color: context.isDark
                  ? const Color(0xFF861832)
                  : const Color(0xFFB51232),
              elevation: 5,
              shadowColor: Colors.black.withValues(alpha: .2),
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CurvedNav(index: index, onChanged: onChanged),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
