import 'package:flutter/foundation.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import '../models/music_track.dart';

class LocalLibrary extends ChangeNotifier {
  final OnAudioQuery _query = OnAudioQuery();

  List<MusicTrack> tracks = const [];
  bool loading = false;
  bool permissionDenied = false;
  String? error;

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    permissionDenied = false;
    error = null;
    notifyListeners();
    try {
      final allowed = await _query.checkAndRequest();
      if (!allowed) {
        permissionDenied = true;
        tracks = const [];
        return;
      }
      final songs = await _query.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
      );
      tracks = songs.where((song) => song.data.isNotEmpty)
          .map(MusicTrack.fromSong).toList(growable: false);
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
