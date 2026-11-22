import 'package:flutter/material.dart';
import '../../services/music_player.dart';
import 'album_art.dart';
import 'curved_nav.dart';

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
        return Padding(
          padding: const EdgeInsets.fromLTRB(17, 4, 17, 0),
          child: Material(
            color: charcoal,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 73,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(7),
                      child: SizedBox(
                        height: 59,
                        width: 59,
                        child: AlbumArt(track: song, radius: 17),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFFB8BBC3), fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: player.isFavorite(song) ? 'Remover favorito' : 'Favoritar',
                      icon: Icon(
                        player.isFavorite(song) ? Icons.favorite : Icons.favorite_border,
                        color: player.isFavorite(song) ? crimson : Colors.white,
                        size: 22,
                      ),
                      onPressed: () => player.toggleFavorite(song),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: IconButton.filled(
                        tooltip: player.playing ? 'Pausar' : 'Reproduzir',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: charcoal,
                        ),
                        onPressed: player.playPause,
                        icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
