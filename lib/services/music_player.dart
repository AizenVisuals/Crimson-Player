import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/music_track.dart';

class MusicPlayer extends ChangeNotifier {
  MusicPlayer() {
    _subscriptions.add(_player.stream.playing.listen((value) {
      playing = value;
      notifyListeners();
    }));
    _subscriptions.add(_player.stream.position.listen((value) {
      position = value;
      notifyListeners();
    }));
    _subscriptions.add(_player.stream.duration.listen((value) {
      duration = value;
      notifyListeners();
    }));
    _subscriptions.add(_player.stream.completed.listen((done) {
      if (done) {
        if (repeatOne) {
          unawaited(_player.seek(Duration.zero).then((_) => _player.play()));
        } else {
          unawaited(next());
        }
      }
    }));
    _subscriptions.add(_player.stream.error.listen((value) {
      error = value;
      notifyListeners();
    }));
    unawaited(_loadFavorites());
  }

  final Player _player = Player();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<String> favorites = {};
  List<MusicTrack> queue = [];
  int queueIndex = -1;
  MusicTrack? current;
  bool playing = false;
  bool shuffle = false;
  bool repeatOne = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String? error;

  bool isFavorite(MusicTrack track) => favorites.contains(track.id);

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites.addAll(prefs.getStringList('favorite_tracks') ?? []);
    notifyListeners();
  }

  Future<void> toggleFavorite(MusicTrack track) async {
    if (!favorites.add(track.id)) favorites.remove(track.id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_tracks', favorites.toList());
  }

  void toggleShuffle() {
    shuffle = !shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    repeatOne = !repeatOne;
    notifyListeners();
  }

  Future<void> open(MusicTrack track, {List<MusicTrack>? fromQueue}) async {
    queue = (fromQueue == null || fromQueue.isEmpty)
        ? [track]
        : List<MusicTrack>.from(fromQueue);
    queueIndex = queue.indexWhere((item) => item.id == track.id);
    if (queueIndex < 0) {
      queue.add(track);
      queueIndex = queue.length - 1;
    }
    await _openAt(queueIndex);
  }

  Future<void> _openAt(int index) async {
    if (index < 0 || index >= queue.length) return;
    queueIndex = index;
    current = queue[index];
    position = Duration.zero;
    duration = current?.duration ?? Duration.zero;
    error = null;
    notifyListeners();
    try {
      await _player.open(Media(current!.uri));
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    if (current == null) return;
    await _player.playOrPause();
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    final nextIndex = shuffle && queue.length > 1
        ? (queueIndex + 1 + Random().nextInt(queue.length - 1)) % queue.length
        : (queueIndex + 1) % queue.length;
    await _openAt(nextIndex);
  }

  Future<void> previous() async {
    if (position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (queue.isNotEmpty) {
      await _openAt((queueIndex - 1 + queue.length) % queue.length);
    }
  }

  Future<void> seekTo(double fraction) async {
    if (duration.inMilliseconds <= 0) return;
    final bounded = fraction.clamp(0.0, 1.0).toDouble();
    await _player.seek(Duration(
      milliseconds: (duration.inMilliseconds * bounded).round(),
    ));
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(_player.dispose());
    super.dispose();
  }
}
