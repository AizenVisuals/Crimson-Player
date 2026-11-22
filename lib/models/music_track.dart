import 'package:on_audio_query/on_audio_query.dart';

/// The UI and playback engine share the same track model for local and online audio.
class MusicTrack {
  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    this.artworkId,
    this.duration,
    this.online = false,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String uri;
  final int? artworkId;
  final Duration? duration;
  final bool online;

  factory MusicTrack.fromSong(SongModel song) {
    return MusicTrack(
      id: 'local:' + song.id.toString(),
      title: song.title,
      artist: _clean(song.artist, 'Artista desconhecido'),
      album: _clean(song.album, 'Álbum desconhecido'),
      uri: song.data,
      artworkId: song.id,
      duration: song.duration == null
          ? null
          : Duration(milliseconds: song.duration!),
    );
  }

  static String _clean(String? value, String fallback) {
    if (value == null || value.trim().isEmpty || value == '<unknown>') {
      return fallback;
    }
    return value.trim();
  }
}
