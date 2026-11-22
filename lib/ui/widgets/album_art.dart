import 'package:flutter/material.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../../models/music_track.dart';
import '../app_theme.dart';

/// Displays artwork embedded in the user's audio files.
/// When none exists, show an honest neutral placeholder—not fabricated cover art.
class AlbumArt extends StatelessWidget {
  const AlbumArt({super.key, this.track, this.radius = 17});
  final MusicTrack? track;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget fallback = ColoredBox(
      color: context.subtle,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: context.muted.withValues(alpha: .6),
          size: 30,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AspectRatio(
        aspectRatio: 1,
        child: track?.artworkId == null
            ? fallback
            : QueryArtworkWidget(
                id: track!.artworkId!,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.zero,
                artworkFit: BoxFit.cover,
                artworkHeight: double.infinity,
                artworkWidth: double.infinity,
                nullArtworkWidget: fallback,
              ),
      ),
    );
  }
}
