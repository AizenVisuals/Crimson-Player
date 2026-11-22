import 'package:flutter/material.dart';

import '../models/music_track.dart';
import '../services/local_library.dart';
import '../services/music_player.dart';
import 'widgets/album_art.dart';
import 'widgets/curved_nav.dart';
import 'widgets/track_tile.dart';

typedef PlayTrack = Future<void> Function(MusicTrack track, List<MusicTrack> queue);
typedef OpenAlbum = void Function(String name, List<MusicTrack> tracks);

const ink = Color(0xFF1D2027);
const muted = Color(0xFF969AA2);

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.caption});
  final String title;
  final String? caption;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (caption != null) ...[
        Text(caption!.toUpperCase(), style: const TextStyle(
          color: crimson, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 10)),
        const SizedBox(height: 10),
      ],
      Text(title, style: const TextStyle(
        color: ink, fontWeight: FontWeight.w800, fontSize: 30, letterSpacing: -.6)),
    ],
  );
}

class LibraryStatus extends StatelessWidget {
  const LibraryStatus({super.key, required this.library});
  final LocalLibrary library;

  @override
  Widget build(BuildContext context) {
    if (library.loading) return const Padding(
      padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator()));
    final title = library.permissionDenied
        ? 'Permita acessar suas músicas'
        : library.error == null ? 'Sua biblioteca está vazia' : 'Não foi possível ler suas músicas';
    final subtitle = library.permissionDenied
        ? 'Precisamos da permissão de áudio para encontrar as músicas do aparelho.'
        : library.error == null
          ? 'Adicione arquivos de áudio ao dispositivo e atualize a biblioteca.'
          : library.error!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          const Icon(Icons.library_music_outlined, size: 47, color: muted),
          const SizedBox(height: 15),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(
            color: muted, height: 1.5)),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: library.refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Atualizar biblioteca'),
          ),
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
  });
  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;
  final OpenAlbum onOpenAlbum;
  final VoidCallback onOpenLibrary;

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
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 25, 26, 35),
          children: [
            Row(children: [
              const Expanded(child: Text('CRIMSON', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3, color: ink))),
              IconButton(onPressed: library.refresh, tooltip: 'Recarregar músicas',
                icon: const Icon(Icons.refresh, color: ink)),
              const CircleAvatar(radius: 19, backgroundColor: ink,
                child: Icon(Icons.music_note, color: Colors.white, size: 19)),
            ]),
            const SizedBox(height: 25),
            const ScreenTitle('Sua música. Seu momento.', caption: 'BEM-VINDO'),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(27),
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DÊ O PLAY', style: TextStyle(
                      color: Color(0xFFEF5267), fontSize: 10,
                      fontWeight: FontWeight.w800, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    const Text('Uma trilha sonora para cada dia.',
                      style: TextStyle(color: Colors.white, fontSize: 22,
                        fontWeight: FontWeight.w800, height: 1.15)),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: tracks.isEmpty
                          ? onOpenLibrary
                          : () => onPlay(tracks.first, tracks),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(tracks.isEmpty ? 'Minha biblioteca' : 'Reproduzir'),
                    ),
                  ],
                )),
                const SizedBox(width: 10),
                SizedBox(width: 106, child: AlbumArt(
                  track: tracks.isEmpty ? null : tracks.first, radius: 19)),
              ]),
            ),
            const SizedBox(height: 32),
            _SectionHeader('Na sua biblioteca', action: onOpenLibrary),
            const SizedBox(height: 13),
            if (tracks.isEmpty) LibraryStatus(library: library)
            else for (final track in tracks.take(4))
              TrackTile(track: track, player: player,
                onTap: () => onPlay(track, tracks)),
            if (albums.isNotEmpty) ...[
              const SizedBox(height: 28),
              const _SectionHeader('Álbuns'),
              const SizedBox(height: 18),
              SizedBox(height: 181, child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final album in albums.entries.take(8))
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 132,
                        child: InkWell(
                          onTap: () => onOpenAlbum(album.key, album.value),
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AlbumArt(track: album.value.first, radius: 18),
                              const SizedBox(height: 8),
                              Text(album.key, maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )),
            ],
          ],
        ),
      ));
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.action});
  final String title;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(
        color: ink, fontSize: 20, fontWeight: FontWeight.w800))),
      if (action != null) TextButton(onPressed: action,
        child: const Text('Ver tudo', style: TextStyle(color: crimson))),
    ],
  );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({
    super.key, required this.library, required this.player,
    required this.onPlay, required this.onOpenAlbum,
  });
  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;
  final OpenAlbum onOpenAlbum;

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  bool albumsMode = false;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.library,
    builder: (context, _) {
      final tracks = widget.library.tracks;
      final albums = <String, List<MusicTrack>>{};
      for (final track in tracks) {
        albums.putIfAbsent(track.album, () => []).add(track);
      }
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ScreenTitle('Biblioteca', caption: 'SUA COLEÇÃO'),
            const SizedBox(height: 7),
            Text(tracks.length.toString() + ' músicas no dispositivo',
              style: const TextStyle(color: muted)),
            const SizedBox(height: 22),
            Row(children: [
              ChoiceChip(label: const Text('Músicas'), selected: !albumsMode,
                onSelected: (_) => setState(() => albumsMode = false)),
              const SizedBox(width: 9),
              ChoiceChip(label: const Text('Álbuns'), selected: albumsMode,
                onSelected: (_) => setState(() => albumsMode = true)),
              const Spacer(),
              IconButton(tooltip: 'Atualizar', icon: const Icon(Icons.refresh),
                onPressed: widget.library.refresh),
            ]),
            const SizedBox(height: 12),
            Expanded(child: tracks.isEmpty
              ? ListView(children: [LibraryStatus(library: widget.library)])
              : albumsMode
                ? ListView.builder(
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final entry = albums.entries.elementAt(index);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        leading: SizedBox(width: 57,
                          child: AlbumArt(track: entry.value.first, radius: 12)),
                        title: Text(entry.key, maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(entry.value.length.toString() + ' faixas'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.onOpenAlbum(entry.key, entry.value),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, i) => TrackTile(
                      track: tracks[i], player: widget.player,
                      onTap: () => widget.onPlay(tracks[i], tracks)),
                  )),
          ]),
        ),
      ));
    },
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.library, required this.player, required this.onPlay});
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
          title: const Text('Reproduzir stream'),
          content: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Cole um link HTTPS direto para um áudio ou stream autorizado.'),
              const SizedBox(height: 14),
              TextField(controller: controller, keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'URL do áudio',
                  hintText: 'https://...',
                  errorText: invalid,
                )),
            ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final uri = Uri.tryParse(controller.text.trim());
                if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
                  setDialogState(() => invalid = 'Use um link HTTPS válido');
                  return;
                }
                final url = uri.toString();
                Navigator.pop(dialogContext);
                widget.onPlay(MusicTrack(
                  id: 'online:' + url, title: 'Stream online',
                  artist: uri.host, album: 'Fonte online',
                  uri: url, online: true,
                ), [
                  MusicTrack(
                    id: 'online:' + url, title: 'Stream online',
                    artist: uri.host, album: 'Fonte online',
                    uri: url, online: true,
                  ),
                ]);
              },
              child: const Text('Reproduzir'),
            ),
          ],
        ),
      ),
    );
    // Do not retain user-provided URLs outside the playback queue.
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.library,
    builder: (context, _) {
      final text = query.text.toLowerCase().trim();
      final tracks = widget.library.tracks.where((track) {
        return text.isNotEmpty && (
          track.title.toLowerCase().contains(text) ||
          track.artist.toLowerCase().contains(text) ||
          track.album.toLowerCase().contains(text));
      }).toList();
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 25, 24, 35), children: [
          const ScreenTitle('Buscar', caption: 'ENCONTRE SEU SOM'),
          const SizedBox(height: 21),
          TextField(
            controller: query,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Música, artista ou álbum...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF2F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 30),
          const _SectionHeader('Músicas locais'),
          const SizedBox(height: 12),
          if (text.isEmpty) const Text('Digite para pesquisar na sua biblioteca.',
            style: TextStyle(color: muted))
          else if (tracks.isEmpty) const Text('Nenhuma música encontrada.',
            style: TextStyle(color: muted))
          else for (final track in tracks)
            TrackTile(track: track, player: widget.player,
              onTap: () => widget.onPlay(track, tracks)),
          const SizedBox(height: 32),
          const _SectionHeader('Música online'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F6),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.wifi_tethering_rounded, color: crimson, size: 27),
              const SizedBox(height: 12),
              const Text('Streaming por link', style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              const Text('Reproduza links diretos de áudio autorizados. Catálogos '
                'de artistas e álbuns online serão integrados em uma próxima etapa.',
                style: TextStyle(color: muted, height: 1.5)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: openStreamDialog,
                icon: const Icon(Icons.link),
                label: const Text('Abrir link de áudio'),
              ),
            ]),
          ),
        ]),
      ));
    },
  );
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key, required this.library,
    required this.player, required this.onPlay});
  final LocalLibrary library;
  final MusicPlayer player;
  final PlayTrack onPlay;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([library, player]),
    builder: (context, _) {
      final favorites = library.tracks.where(player.isFavorite).toList();
      return Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 25, 24, 32), children: [
          const ScreenTitle('Suas músicas', caption: 'PLAYLISTS E FAVORITOS'),
          const SizedBox(height: 15),
          const Text('Favoritas', style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (favorites.isEmpty) const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text('Toque no coração de uma música para adicioná-la aqui.',
              style: TextStyle(color: muted)))
          else for (final track in favorites)
            TrackTile(track: track, player: player,
              onTap: () => onPlay(track, favorites)),
          const SizedBox(height: 25),
          const Text('Fila atual', style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (player.queue.isEmpty) const Text('Sua fila de reprodução está vazia.',
            style: TextStyle(color: muted))
          else for (final track in player.queue)
            TrackTile(track: track, player: player,
              onTap: () => onPlay(track, player.queue)),
          const SizedBox(height: 22),
          const Text('Criação e sincronização de playlists virão nas próximas versões.',
            style: TextStyle(color: muted, fontSize: 12)),
        ]),
      ));
    },
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.library});
  final LocalLibrary library;

  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 650),
    child: ListView(padding: const EdgeInsets.fromLTRB(24, 25, 24, 32), children: [
      const ScreenTitle('Ajustes', caption: 'PERSONALIZE'),
      const SizedBox(height: 28),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.refresh),
        title: const Text('Atualizar biblioteca'),
        subtitle: const Text('Buscar músicas no dispositivo'),
        onTap: library.refresh,
      ),
      const Divider(),
      const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.info_outline),
        title: Text('Crimson Player'),
        subtitle: Text('Prévia Android • v0.1.0\nNome provisório'),
        isThreeLine: true,
      ),
      const SizedBox(height: 20),
      const Text('Reprodução local e streaming por URL na versão inicial. '
        'Outras fontes online e desktop virão depois.',
        style: TextStyle(color: muted, height: 1.6)),
    ]),
  ));
}

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key, required this.name, required this.tracks,
    required this.player, required this.onPlay});
  final String name;
  final List<MusicTrack> tracks;
  final MusicPlayer player;
  final Future<void> Function(MusicTrack) onPlay;

  @override
  Widget build(BuildContext context) {
    final artist = tracks.isEmpty ? 'Desconhecido' : tracks.first.artist;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () =>
          Navigator.pop(context))],
      ),
      body: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ListView(padding: const EdgeInsets.fromLTRB(26, 16, 26, 40),
          children: [
            Row(children: [
              SizedBox(width: 125, child: AlbumArt(
                track: tracks.isEmpty ? null : tracks.first, radius: 20)),
              const SizedBox(width: 22),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ÁLBUM • ' + tracks.length.toString() + ' faixas',
                    style: const TextStyle(color: muted, fontSize: 11)),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(
                    fontSize: 27, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text(artist, style: const TextStyle(color: muted)),
                ])),
            ]),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: tracks.isEmpty ? null : () => onPlay(tracks.first),
                style: FilledButton.styleFrom(
                  backgroundColor: ink, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Reproduzir'),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: tracks.isEmpty ? null : () {
                  player.toggleShuffle();
                  onPlay(tracks.first);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
                icon: const Icon(Icons.shuffle),
                label: const Text('Aleatório'),
              )),
            ]),
            const SizedBox(height: 22),
            for (var i = 0; i < tracks.length; i++)
              TrackTile(index: i, track: tracks[i], player: player,
                onTap: () => onPlay(tracks[i])),
          ]),
      )),
    );
  }
}
