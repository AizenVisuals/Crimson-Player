import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/music_track.dart';

class LocalLibrary extends ChangeNotifier {
  static const _mediaStore = MethodChannel('crimson_player/local_library');

  static Future<Uint8List?> loadArtwork(int id) async {
    try {
      return await _mediaStore.invokeMethod<Uint8List>('artwork', {'id': id});
    } on PlatformException {
      return null;
    }
  }

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
      final songs = await _mediaStore.invokeListMethod<Map<Object?, Object?>>(
        'songs',
      );
      tracks = (songs ?? const [])
          .map(MusicTrack.fromMediaStore)
          .toList(growable: false);
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
