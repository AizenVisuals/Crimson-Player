import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/music_track.dart';

class LocalLibrary extends ChangeNotifier {
  final OnAudioQuery _query = OnAudioQuery();

  List<MusicTrack> tracks = const [];
  bool loading = false;
  bool permissionDenied = false;
  bool permissionPermanentlyDenied = false;
  String? error;

  Future<void> openPermissions() async {
    await openAppSettings();
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    permissionDenied = false;
    permissionPermanentlyDenied = false;
    error = null;
    notifyListeners();

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = await DeviceInfoPlugin().androidInfo;
        // READ_MEDIA_AUDIO on Android 13+; legacy READ_EXTERNAL_STORAGE
        // on Android 12 and older. An explicit request allows OEM-specific
        // permission flows to show the proper dialog.
        final permission = android.version.sdkInt >= 33
            ? Permission.audio
            : Permission.storage;
        final granted = await permission.request();
        if (!granted.isGranted) {
          permissionDenied = true;
          permissionPermanentlyDenied = granted.isPermanentlyDenied;
          tracks = const [];
          return;
        }
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
