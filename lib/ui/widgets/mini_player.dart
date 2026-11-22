import 'package:flutter/material.dart';

import '../../services/music_player.dart';
import '../app_theme.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.player, required this.onOpen});
  final MusicPlayer player;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        final song = player.current;
        if (song == null) return const SizedBox.shrink();
        // Light theme: dark mini player. Dark theme: white mini player,
        // faithful to both screenshots supplied by the user.
        final background = context.isDark ? AppColors.paper : AppColors.ink;
        final foreground = context.isDark ? AppColors.ink : AppColors.paper;
        final muted = context.isDark
            ? AppColors.slate
            : const Color(0xFFC0C5D0);

        return Material(
          color: background,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onOpen,
            child: SizedBox(
              height: 67,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: SizedBox(
                      width: 54,
                      child: AlbumArt(track: song, radius: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: player.isFavorite(song) ? 'Remover favorito' : 'Favoritar',
                    onPressed: () => player.toggleFavorite(song),
                    icon: Icon(
                      player.isFavorite(song)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: foreground,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton.filled(
                      tooltip: player.playing ? 'Pausar' : 'Reproduzir',
                      onPressed: player.playPause,
                      style: IconButton.styleFrom(
                        backgroundColor: foreground,
                        foregroundColor: background,
                        minimumSize: const Size(40, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Icon(
                          player.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          key: ValueKey(player.playing),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
