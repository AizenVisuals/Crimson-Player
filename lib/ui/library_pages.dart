import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/music_track.dart';
import '../services/local_library.dart';
import '../services/music_player.dart';
import 'app_theme.dart';
import 'widgets/album_art.dart';
import 'widgets/track_tile.dart';

typedef PlayTrack = Future<void> Function(MusicTrack track, List<MusicTrack> queue);
typedef OpenAlbum = void Function(String name, List<MusicTrack> tracks);

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
        style: TextStyle(
          color: context.ink,
          fontSize: 29,
          letterSpacing: -.9,
          fontWeight: FontWeight.w700,
        )),
      if (subtitle != null) ...[
        const SizedBox(height: 5),
        Text(subtitle!, style: TextStyle(
          color: context.muted, fontSize: 12,
        )),
      ],
    ],
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.onMore});
  final String title;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: TextStyle(
        color: context.ink, fontWeight: FontWeight.w700, fontSize: 17,
        letterSpacing: -.35,
      ))),
      if (onMore != null)
        TextButton(
          onPressed: onMore,
          child: Text('Ver tudo',
            style: TextStyle(color: context.muted, fontSize: 12)),
        ),
    ],
  );
}

class LibraryStatus extends StatelessWidget {
  const LibraryStatus({super.key, required this.library});
  final LocalLibrary library;

  @override
  Widget build(BuildContext context) {
    if (library.loading) return const Padding(
      padding: EdgeInsets.symmetric(vertical: 35),
      child: Center(child: CircularProgressIndicator()),
    );
    final denied = library.permissionDenied;
    final label = denied
        ? 'Acesso às músicas'
        : library.error != null ? 'Não foi possível ler a biblioteca'
        : 'Sua biblioteca está vazia';
    final subtitle = denied
        ? 'Autorize o acesso aos arquivos de áudio do aparelho.'
        : library.error != null ? 'Confira a permissão e tente atualizar.'
        : 'Adicione músicas ao celular para vê-las aqui.';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: context.muted.withValues(alpha: .15)),
        borderRadius: BorderRadius.circular(17),
        color: context.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.library_music_outlined, color: context.muted, size: 26),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                color: context.ink, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 5),
              Text(subtitle,
                style: TextStyle(color: context.muted, height: 1.5, fontSize: 12)),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: denied && library.permissionPermanentlyDenied
                    ? library.openPermissions
                    : library.refresh,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.refresh_rounded, color: context.ink, size: 17),
                label: Text(
                  denied && library.permissionPermanentlyDenied
                      ? 'Abrir configurações'
                      : 'Atualizar biblioteca',
                  style: TextStyle(color: context.ink,
                      fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.library,
    required this.player,
    required this.onPlay,
    required this.onOpenAlbum,
    required this.onOpenLibrary,
    required this.onSettings,
  });
  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;
  final OpenAlbum onOpenAlbum;
  final VoidCallback onOpenLibrary;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: library,
    builder: (context, _) {
      final tracks = library.tracks;
      final albums = <String, List<MusicTrack>>{};
      for (final track in tracks) {
        albums.putIfAbsent(track.album, () => []).add(track);
      }
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 26),
          children: [
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CRIMSON PLAYER',
                    style: TextStyle(
                      color: context.muted,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    )),
                  const SizedBox(height: 8),
                  Text('Início', style: TextStyle(
                    color: context.ink, letterSpacing: -.8,
                    fontSize: 29, fontWeight: FontWeight.w700)),
                ],
              )),
              IconButton(
                tooltip: 'Ajustes',
                onPressed: onSettings,
                icon: Icon(Icons.tune_rounded, color: context.ink),
              ),
            ]),
            const SizedBox(height: 31),
            if (tracks.isEmpty) ...[
              const SectionHeader('Sua música'),
              const SizedBox(height: 13),
              LibraryStatus(library: library),
            ] else ...[
              SectionHeader('Sua biblioteca', onMore: onOpenLibrary),
              const SizedBox(height: 13),
              InkWell(
                onTap: () => onPlay(tracks.first, tracks),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.subtle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    SizedBox(width: 102,
                      child: AlbumArt(track: tracks.first, radius: 15)),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRONTO PARA OUVIR', style: TextStyle(
                          color: context.muted, fontWeight: FontWeight.w700,
                          fontSize: 10, letterSpacing: 1)),
                        const SizedBox(height: 9),
                        Text(tracks.first.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.ink,
                            fontWeight: FontWeight.w700, fontSize: 17)),
                        const SizedBox(height: 5),
                        Text(tracks.first.artist,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.muted, fontSize: 12)),
                        const SizedBox(height: 12),
                        Icon(Icons.play_circle_fill_rounded,
                          color: context.ink, size: 28),
                      ],
                    )),
                  ]),
                ),
              ),
              const SizedBox(height: 29),
              const SectionHeader('Músicas'),
              const SizedBox(height: 10),
              for (var i = 0; i < math.min(5, tracks.length); i++)
                TrackTile(
                  index: i, track: tracks[i], player: player,
                  onTap: () => onPlay(tracks[i], tracks),
                ),
              if (albums.isNotEmpty) ...[
                const SizedBox(height: 23),
                const SectionHeader('Álbuns'),
                const SizedBox(height: 15),
                SizedBox(
                  height: 177,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final entry in albums.entries.take(12))
                        Padding(
                          padding: const EdgeInsets.only(right: 13),
                          child: SizedBox(
                            width: 126,
                            child: InkWell(
                              onTap: () => onOpenAlbum(entry.key, entry.value),
                              borderRadius: BorderRadius.circular(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AlbumArt(track: entry.value.first, radius: 14),
                                  const SizedBox(height: 7),
                                  Text(entry.key, maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: context.ink,
                                      fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ));
    },
  );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    super.key,
    required this.library,
    required this.player,
    required this.onPlay,
    required this.onOpenAlbum,
  });

  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;
  final OpenAlbum onOpenAlbum;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool albums = false;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.library,
    builder: (context, _) {
      final tracks = widget.library.tracks;
      final albumMap = <String, List<MusicTrack>>{};
      for (final track in tracks) {
        albumMap.putIfAbsent(track.album, () => []).add(track);
      }
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(23, 20, 23, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTitle('Biblioteca', subtitle: '${tracks.length} músicas'),
              const SizedBox(height: 19),
              Row(children: [
                ChoiceChip(
                  label: const Text('Músicas'),
                  selected: !albums,
                  onSelected: (_) => setState(() => albums = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Álbuns'),
                  selected: albums,
                  onSelected: (_) => setState(() => albums = true),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Atualizar músicas',
                  onPressed: widget.library.refresh,
                  icon: Icon(Icons.refresh_rounded, color: context.muted),
                ),
              ]),
              const SizedBox(height: 14),
              Expanded(child: tracks.isEmpty
                  ? ListView(children: [LibraryStatus(library: widget.library)])
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: albums
                          ? ListView.builder(
                              key: const ValueKey('albums'),
                              itemCount: albumMap.length,
                              itemBuilder: (context, index) {
                                final entry = albumMap.entries.elementAt(index);
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                  leading: SizedBox(width: 57,
                                    child: AlbumArt(track: entry.value.first, radius: 12)),
                                  title: Text(entry.key, maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: context.ink,
                                      fontWeight: FontWeight.w700, fontSize: 13)),
                                  subtitle: Text('${entry.value.length} músicas',
                                    style: TextStyle(color: context.muted, fontSize: 11)),
                                  trailing: Icon(Icons.chevron_right_rounded,
                                    color: context.muted, size: 20),
                                  onTap: () => widget.onOpenAlbum(entry.key, entry.value),
                                );
                              },
                            )
                          : ListView.builder(
                              key: const ValueKey('songs'),
                              itemCount: tracks.length,
                              itemBuilder: (context, index) => TrackTile(
                                track: tracks[index], index: index,
                                player: widget.player,
                                onTap: () => widget.onPlay(tracks[index], tracks),
                              ),
                            ),
                    )),
            ],
          ),
        ),
      ));
    },
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key, required this.library, required this.player, required this.onPlay,
  });

  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController query = TextEditingController();

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> openStreamDialog() async {
    final controller = TextEditingController();
    String? invalid;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Abrir link de áudio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cole um link HTTPS direto para uma fonte de áudio autorizada.'),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'https://...',
                  border: const OutlineInputBorder(),
                  errorText: invalid,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final uri = Uri.tryParse(controller.text.trim());
                if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
                  setDialogState(() => invalid = 'Informe uma URL HTTPS válida');
                  return;
                }
                final track = MusicTrack(
                  id: 'online:${uri.toString()}',
                  title: 'Áudio online',
                  artist: uri.host,
                  album: 'Streaming',
                  uri: uri.toString(),
                  online: true,
                );
                Navigator.pop(dialogContext);
                widget.onPlay(track, [track]);
              },
              child: const Text('Reproduzir'),
            ),
          ],
        ),
      ),
    );
    // URL is held only by the active playback queue.
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.library,
    builder: (context, _) {
      final filter = query.text.toLowerCase().trim();
      final tracks = widget.library.tracks.where((track) =>
          filter.isNotEmpty &&
          (track.title.toLowerCase().contains(filter) ||
           track.artist.toLowerCase().contains(filter) ||
           track.album.toLowerCase().contains(filter))).toList();
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 25),
          children: [
            const ScreenTitle('Buscar', subtitle: 'Encontre sua música'),
            const SizedBox(height: 23),
            TextField(
              controller: query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Música, artista ou álbum',
                hintStyle: TextStyle(color: context.muted, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: context.muted),
                filled: true,
                fillColor: context.subtle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 29),
            const SectionHeader('Biblioteca local'),
            const SizedBox(height: 12),
            if (filter.isEmpty)
              Text('Digite para pesquisar nas músicas do celular.',
                style: TextStyle(color: context.muted, fontSize: 12))
            else if (tracks.isEmpty)
              Text('Nenhuma música encontrada.',
                style: TextStyle(color: context.muted, fontSize: 12))
            else
              for (final track in tracks)
                TrackTile(
                  track: track,
                  player: widget.player,
                  onTap: () => widget.onPlay(track, tracks),
                ),
            const SizedBox(height: 30),
            const SectionHeader('Streaming'),
            const SizedBox(height: 10),
            ListTile(
              onTap: openStreamDialog,
              contentPadding: const EdgeInsets.symmetric(horizontal: 7),
              leading: Icon(Icons.link_rounded, color: context.ink),
              title: Text('Reproduzir um link de áudio',
                style: TextStyle(color: context.ink,
                  fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: Text('Links HTTPS diretos e autorizados',
                style: TextStyle(color: context.muted, fontSize: 11)),
              trailing: Icon(Icons.chevron_right_rounded, color: context.muted),
            ),
          ],
        ),
      ));
    },
  );
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key, required this.library, required this.player, required this.onPlay,
  });

  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([library, player]),
    builder: (context, _) {
      final favorites = library.tracks.where(player.isFavorite).toList();
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
          children: [
            ScreenTitle('Hotlist', subtitle: '${favorites.length} favoritas'),
            const SizedBox(height: 29),
            const SectionHeader('Suas favoritas'),
            const SizedBox(height: 13),
            if (favorites.isEmpty)
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: context.subtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Suas músicas favoritas aparecem aqui. '
                  'Toque no coração durante a reprodução para adicioná-las.',
                  style: TextStyle(color: context.muted, height: 1.5, fontSize: 12),
                ),
              )
            else
              for (var i = 0; i < favorites.length; i++)
                TrackTile(
                  index: i,
                  track: favorites[i],
                  player: player,
                  onTap: () => onPlay(favorites[i], favorites),
                ),
            const SizedBox(height: 27),
            const SectionHeader('Fila atual'),
            const SizedBox(height: 10),
            if (player.queue.isEmpty)
              Text('Ainda não há músicas na fila.',
                style: TextStyle(color: context.muted, fontSize: 12))
            else
              for (var i = 0; i < player.queue.length; i++)
                TrackTile(
                  index: i,
                  track: player.queue[i],
                  player: player,
                  onTap: () => onPlay(player.queue[i], player.queue),
                ),
          ],
        ),
      ));
    },
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.library,
    required this.appearance,
    required this.onAppearanceChanged,
  });

  final LocalLibrary library;
  final ThemeMode appearance;
  final ValueChanged<ThemeMode> onAppearanceChanged;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Voltar',
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Ajustes'),
    ),
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 30),
        children: [
          const SectionHeader('Aparência'),
          const SizedBox(height: 7),
          Text('Escolha como o player aparece no seu aparelho.',
            style: TextStyle(fontSize: 12, color: context.muted)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 9,
            children: [
              for (final option in [
                (ThemeMode.system, 'Sistema', Icons.brightness_auto_outlined),
                (ThemeMode.light, 'Claro', Icons.light_mode_outlined),
                (ThemeMode.dark, 'Escuro', Icons.dark_mode_outlined),
              ])
                ChoiceChip(
                  avatar: Icon(option.$3, size: 17),
                  label: Text(option.$2),
                  selected: appearance == option.$1,
                  onSelected: (_) => onAppearanceChanged(option.$1),
                ),
            ],
          ),
          const SizedBox(height: 29),
          const SectionHeader('Biblioteca'),
          const SizedBox(height: 9),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.refresh_rounded, color: context.ink),
            title: const Text('Atualizar músicas'),
            subtitle: const Text('Buscar os arquivos de áudio do dispositivo'),
            onTap: library.refresh,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.admin_panel_settings_outlined,
              color: context.ink),
            title: const Text('Permissões de áudio'),
            subtitle: const Text('Abrir configurações do Android'),
            onTap: library.openPermissions,
          ),
          const SizedBox(height: 23),
          const SectionHeader('Sobre'),
          const SizedBox(height: 8),
          Text('Crimson Player · Prévia Android v0.2.0',
            style: TextStyle(color: context.muted, fontSize: 12)),
          const SizedBox(height: 6),
          Text('Nome provisório. Versão desktop planejada para depois.',
            style: TextStyle(color: context.muted, fontSize: 12)),
        ],
      ),
    )),
  );
}

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.name,
    required this.tracks,
    required this.player,
    required this.onPlay,
  });

  final String name;
  final List<MusicTrack> tracks;
  final MusicPlayer player;
  final Future<void> Function(MusicTrack) onPlay;

  @override
  Widget build(BuildContext context) {
    final artist = tracks.isEmpty ? 'Artista desconhecido' : tracks.first.artist;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 13, 24, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 124,
                  child: AlbumArt(
                    track: tracks.isEmpty ? null : tracks.first,
                    radius: 18,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Álbum · ${tracks.length} músicas',
                      style: TextStyle(color: context.muted, fontSize: 11)),
                    const SizedBox(height: 7),
                    Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.ink, fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5,
                      )),
                    const SizedBox(height: 6),
                    Text(artist, style: TextStyle(
                      color: context.muted, fontSize: 12)),
                    const SizedBox(height: 6),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 23),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: tracks.isEmpty ? null : () => onPlay(tracks.first),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 19),
                label: const Text('Reproduzir'),
              )),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(
                onPressed: tracks.isEmpty ? null : () {
                  final first = tracks[math.Random().nextInt(tracks.length)];
                  if (!player.shuffle) player.toggleShuffle();
                  onPlay(first);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.subtle,
                  foregroundColor: context.ink,
                ),
                icon: const Icon(Icons.shuffle_rounded, size: 18),
                label: const Text('Aleatório'),
              )),
            ]),
            const SizedBox(height: 21),
            for (var i = 0; i < tracks.length; i++)
              TrackTile(
                index: i,
                track: tracks[i],
                player: player,
                onTap: () => onPlay(tracks[i]),
              ),
          ],
        ),
      )),
    );
  }
}
