import 'package:flutter/material.dart';

import '../models/music_track.dart';
import '../services/local_library.dart';
import '../services/music_player.dart';
import 'library_pages.dart';
import 'now_playing_page.dart';
import 'widgets/player_navigation_bar.dart';

class CrimsonShell extends StatefulWidget {
  const CrimsonShell({
    super.key,
    required this.library,
    required this.player,
    required this.appearance,
    required this.onAppearanceChanged,
  });

  final LocalLibrary library;
  final MusicPlayer player;
  final ThemeMode appearance;
  final ValueChanged<ThemeMode> onAppearanceChanged;

  @override
  State<CrimsonShell> createState() => _CrimsonShellState();
}

class _CrimsonShellState extends State<CrimsonShell> {
  int tab = 0;

  Future<void> playTrack(MusicTrack track, List<MusicTrack> tracks) async {
    await widget.player.open(track, fromQueue: tracks);
    if (mounted) showNowPlaying();
  }

  void showNowPlaying() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => NowPlayingPage(
        player: widget.player,
        onSelectTab: (index) {
          Navigator.pop(context);
          setState(() => tab = index);
        },
      ),
    ));
  }

  void showAlbum(String name, List<MusicTrack> tracks) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AlbumPage(
        name: name,
        tracks: tracks,
        player: widget.player,
        onPlay: (track) => playTrack(track, tracks),
      ),
    ));
  }

  void showSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SettingsPage(
        library: widget.library,
        appearance: widget.appearance,
        onAppearanceChanged: widget.onAppearanceChanged,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(
        library: widget.library,
        player: widget.player,
        onPlay: playTrack,
        onOpenAlbum: showAlbum,
        onOpenLibrary: () => setState(() => tab = 2),
        onSettings: showSettings,
      ),
      SearchPage(
        library: widget.library,
        player: widget.player,
        onPlay: playTrack,
      ),
      LibraryPage(
        library: widget.library,
        player: widget.player,
        onPlay: playTrack,
        onOpenAlbum: showAlbum,
      ),
      FavoritesPage(
        library: widget.library,
        player: widget.player,
        onPlay: playTrack,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: tab, children: screens),
      ),
      bottomNavigationBar: PlayerNavigationBar(
        index: tab,
        player: widget.player,
        onOpenPlayer: showNowPlaying,
        onChanged: (index) => setState(() => tab = index),
      ),
    );
  }
}
