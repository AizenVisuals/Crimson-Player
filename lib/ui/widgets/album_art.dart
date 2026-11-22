import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/music_track.dart';
import '../../services/local_library.dart';
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
            : _LocalArtwork(
                key: ValueKey(track!.artworkId),
                id: track!.artworkId!,
                fallback: fallback,
              ),
      ),
    );
  }
}

class _LocalArtwork extends StatefulWidget {
  const _LocalArtwork({
    required super.key,
    required this.id,
    required this.fallback,
  });

  final int id;
  final Widget fallback;

  @override
  State<_LocalArtwork> createState() => _LocalArtworkState();
}

class _LocalArtworkState extends State<_LocalArtwork> {
  late final Future<Uint8List?> _artwork = LocalLibrary.loadArtwork(widget.id);

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
        future: _artwork,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) return widget.fallback;
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => widget.fallback,
          );
        },
      );
}
