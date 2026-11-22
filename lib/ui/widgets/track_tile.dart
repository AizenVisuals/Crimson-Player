import 'package:flutter/material.dart';
import '../../models/music_track.dart';
import '../../services/music_player.dart';
import 'album_art.dart';
import 'curved_nav.dart';

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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      leading: index == null
          ? SizedBox(width: 54, child: AlbumArt(track: track, radius: 13))
          : SizedBox(
              width: 36,
              child: Center(child: Text(
                (index! + 1).toString().padLeft(2, '0'),
                style: const TextStyle(color: Color(0xFF777B83), fontSize: 13),
              )),
            ),
      title: Text(track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      subtitle: Text(track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Color(0xFF92969D), fontSize: 12)),
      trailing: AnimatedBuilder(
        animation: player,
        builder: (context, _) => IconButton(
          tooltip: player.isFavorite(track) ? 'Remover favorito' : 'Favoritar',
          onPressed: () => player.toggleFavorite(track),
          icon: Icon(
            player.isFavorite(track) ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: player.isFavorite(track) ? crimson : const Color(0xFFB5B7BC),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
