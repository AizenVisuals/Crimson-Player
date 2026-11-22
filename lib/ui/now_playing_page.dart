import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/music_player.dart';
import 'widgets/album_art.dart';
import 'widgets/curved_nav.dart';
import 'widgets/track_tile.dart';
import 'widgets/waveform_seek.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({
    super.key,
    required this.player,
    required this.onSelectTab,
  });

  final MusicPlayer player;
  final ValueChanged<int> onSelectTab;

  String format(Duration time) {
    final minutes = time.inMinutes.toString();
    final seconds = (time.inSeconds % 60).toString().padLeft(2, '0');
    return minutes + ':' + seconds;
  }

  void showQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(modalContext).size.height * .65,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 5, 22, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Fila de reprodução', style: TextStyle(
                fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Expanded(child: AnimatedBuilder(
                animation: player,
                builder: (context, _) => ListView.builder(
                  itemCount: player.queue.length,
                  itemBuilder: (context, index) => TrackTile(
                    track: player.queue[index],
                    player: player,
                    onTap: () {
                      player.open(player.queue[index], fromQueue: player.queue);
                      Navigator.pop(modalContext);
                    },
                  ),
                ),
              )),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: player,
    builder: (context, _) {
      final song = player.current;
      final duration = player.duration.inMilliseconds == 0
          ? (song?.duration ?? Duration.zero)
          : player.duration;
      final progress = duration.inMilliseconds > 0
          ? (player.position.inMilliseconds / duration.inMilliseconds)
              .clamp(0.0, 1.0).toDouble()
          : 0.0;
      final width = MediaQuery.sizeOf(context).width;
      final artSize = math.min(width - 75, 340.0);
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
            tooltip: 'Voltar',
            onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: const Text('Now Playing', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF202125))),
          actions: [
            IconButton(tooltip: 'Fila de reprodução',
              onPressed: () => showQueue(context),
              icon: const Icon(Icons.queue_music_rounded)),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(30, 12, 30, 20),
            children: [
              Center(child: SizedBox(width: artSize, child: AlbumArt(
                track: song, radius: 26))),
              const SizedBox(height: 31),
              Row(children: [
                IconButton(
                  tooltip: 'Favorito',
                  onPressed: song == null ? null : () => player.toggleFavorite(song),
                  icon: Icon(
                    song != null && player.isFavorite(song)
                        ? Icons.favorite : Icons.favorite_border,
                    color: song != null && player.isFavorite(song)
                        ? crimson : const Color(0xFFC6C8CA))),
                Expanded(child: Column(children: [
                  Text(song?.title ?? 'Nenhuma música selecionada',
                    textAlign: TextAlign.center, maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900,
                      color: Color(0xFF181A1E), fontSize: 26)),
                  const SizedBox(height: 7),
                  Text(song?.artist ?? 'Abra uma música da sua biblioteca',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF989BA1), fontSize: 17)),
                ])),
                IconButton(tooltip: 'Mais opções',
                  onPressed: () => showQueue(context),
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF94979C))),
              ]),
              const SizedBox(height: 25),
              WaveformSeek(progress: progress, onSeek: player.seekTo),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(format(player.position),
                      style: const TextStyle(color: Color(0xFF666A71), fontSize: 12)),
                    Text(format(duration), style: const TextStyle(
                      color: Color(0xFFB3B6BB), fontSize: 12)),
                  ]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Aleatório',
                    onPressed: player.toggleShuffle,
                    icon: Icon(Icons.shuffle,
                      color: player.shuffle ? crimson : const Color(0xFFC2C4C9))),
                  IconButton(
                    iconSize: 29,
                    tooltip: 'Anterior',
                    onPressed: player.previous,
                    icon: const Icon(Icons.skip_previous_rounded)),
                  Container(
                    width: 76, height: 76,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1D2027), shape: BoxShape.circle),
                    child: IconButton(
                      tooltip: player.playing ? 'Pausar' : 'Reproduzir',
                      iconSize: 37,
                      color: Colors.white,
                      onPressed: player.playPause,
                      icon: Icon(player.playing
                        ? Icons.pause_rounded : Icons.play_arrow_rounded)),
                  ),
                  IconButton(
                    iconSize: 29,
                    tooltip: 'Próxima',
                    onPressed: player.next,
                    icon: const Icon(Icons.skip_next_rounded)),
                  IconButton(
                    tooltip: 'Repetir música',
                    onPressed: player.toggleRepeat,
                    icon: Icon(Icons.repeat_one_rounded,
                      color: player.repeatOne ? crimson : const Color(0xFFC2C4C9))),
                ],
              ),
              if (player.error != null) ...[
                const SizedBox(height: 18),
                Text('Falha na reprodução: ' + player.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: crimson, fontSize: 12)),
              ],
            ],
          ),
        )),
        bottomNavigationBar: SafeArea(
          top: false,
          child: CurvedNav(index: 2, onChanged: onSelectTab),
        ),
      );
    },
  );
}
