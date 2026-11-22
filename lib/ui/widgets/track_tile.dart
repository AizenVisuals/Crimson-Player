import 'package:flutter/material.dart';

import '../../models/music_track.dart';
import '../../services/music_player.dart';
import '../app_theme.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.player,
    required this.onTap,
    this.index,
  });

  final MusicTrack track;
  final MusicPlayer player;
  final VoidCallback onTap;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        final selected = player.current?.id == track.id;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          decoration: BoxDecoration(
            color: selected ? context.subtle : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            minVerticalPadding: 4,
            minLeadingWidth: 36,
            contentPadding: const EdgeInsets.symmetric(horizontal: 7),
            leading: SizedBox(
              width: 35,
              child: Center(
                child: selected
                    ? Icon(
                        Icons.graphic_eq_rounded,
                        size: 19,
                        color: context.ink,
                      )
                    : Text(
                        index == null
                            ? '♪'
                            : (index! + 1).toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: index == null ? 17 : 12,
                          fontWeight: FontWeight.w500,
                          color: context.muted,
                        ),
                      ),
              ),
            ),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: context.ink,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            subtitle: Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: context.muted),
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Opções da música',
              icon: Icon(Icons.more_horiz_rounded,
                size: 20, color: context.muted),
              onSelected: (value) {
                if (value == 'favorite') player.toggleFavorite(track);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(children: [
                    Icon(
                      player.isFavorite(track)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(player.isFavorite(track)
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos'),
                  ]),
                ),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
