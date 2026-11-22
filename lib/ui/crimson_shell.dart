import 'package:flutter/material.dart';

import '../models/music_track.dart';
import '../services/local_library.dart';
import '../services/music_player.dart';
import 'library_pages.dart';
import 'now_playing_page.dart';
import 'widgets/curved_nav.dart';
import 'widgets/mini_player.dart';

class CrimsonShell extends StatefulWidget {
  const CrimsonShell({super.key, required this.library, required this.player});
  final LocalLibrary library;
  final MusicPlayer player;

  @override
  State<CrimsonShell> createState() => _CrimsonShellState();
}

class _CrimsonShellState extends State<CrimsonShell> {
  int tab = 0;

  Future<void> playTrack(MusicTrack song, List<MusicTrack> queue) async {
    await widget.player.open(song, fromQueue: queue);
    if (mounted) showNowPlaying();
  }

  void showNowPlaying() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => NowPlayingPage(
          player: widget.player,
          onSelectTab: (index) {
            Navigator.pop(context);
            setState(() => tab = index);
          },
        ),
      ),
    );
  }

  void showAlbum(String name, List<MusicTrack> songs) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AlbumPage(
          name: name,
          tracks: songs,
          player: widget.player,
          onPlay: (track) => playTrack(track, songs),
        ),
      ),
    );
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
      ),
      SearchPage(library: widget.library, player: widget.player, onPlay: playTrack),
      LibraryPage(
        library: widget.library,
        player: widget.player,
        onPlay: playTrack,
        onOpenAlbum: showAlbum,
      ),
      FavoritesPage(library: widget.library, player: widget.player, onPlay: playTrack),
      SettingsPage(library: widget.library),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: tab, children: screens),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MiniPlayer(player: widget.player, onOpen: showNowPlaying),
            CurvedNav(index: tab, onChanged: (value) => setState(() => tab = value)),
          ],
        ),
      ),
    );
  }
}
