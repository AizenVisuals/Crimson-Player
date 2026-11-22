import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/music_player.dart';
import 'app_theme.dart';
import 'widgets/album_art.dart';
import 'widgets/player_navigation_bar.dart';
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

  static String time(Duration time) {
    final safe = time.isNegative ? Duration.zero : time;
    return '${safe.inMinutes}:${(safe.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void showQueue(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .62,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fila de reprodução', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: sheetContext.ink,
                )),
                const SizedBox(height: 14),
                Expanded(child: AnimatedBuilder(
                  animation: player,
                  builder: (context, _) => ListView.builder(
                    itemCount: player.queue.length,
                    itemBuilder: (context, index) => TrackTile(
                      index: index,
                      track: player.queue[index],
                      player: player,
                      onTap: () {
                        player.open(
                          player.queue[index], fromQueue: player.queue,
                        );
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player,
      builder: (context, _) {
        final song = player.current;
        final duration = player.duration.inMilliseconds == 0
            ? (song?.duration ?? Duration.zero)
            : player.duration;
        final progress = duration.inMilliseconds <= 0
            ? 0.0
            : (player.position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0).toDouble();
        final size = MediaQuery.sizeOf(context);
        final artworkSize = math.min(size.width - 92, 312.0);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 26),
              tooltip: 'Minimizar',
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text('Now Playing'),
            actions: [
              IconButton(
                tooltip: 'Fila de reprodução',
                icon: const Icon(Icons.queue_music_rounded, size: 22),
                onPressed: () => showQueue(context),
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(30, 14, 30, 28),
                children: [
                  Center(child: SizedBox(
                    width: artworkSize,
                    child: AlbumArt(track: song, radius: 23),
                  )),
                  const SizedBox(height: 29),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          song != null && player.isFavorite(song)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 21,
                          color: context.muted,
                        ),
                        tooltip: 'Favorito',
                        onPressed: song == null ? null
                            : () => player.toggleFavorite(song),
                      ),
                      Expanded(child: Column(
                        children: [
                          Text(
                            song?.title ?? 'Nenhuma música selecionada',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: context.ink,
                              height: 1.22,
                              letterSpacing: -.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            song?.artist ?? 'Sua biblioteca',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.muted, fontSize: 15,
                            ),
                          ),
                        ],
                      )),
                      IconButton(
                        tooltip: 'Mais opções',
                        onPressed: () => showQueue(context),
                        icon: Icon(Icons.more_horiz_rounded,
                            color: context.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  WaveformSeek(
                    progress: progress,
                    onSeek: song == null ? (_) {} : player.seekTo,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(time(player.position),
                            style: TextStyle(color: context.muted, fontSize: 11)),
                        Text(time(duration),
                            style: TextStyle(color: context.muted, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: player.toggleShuffle,
                        tooltip: 'Aleatório',
                        icon: Icon(Icons.shuffle_rounded, size: 21,
                          color: player.shuffle ? context.ink : context.muted),
                      ),
                      IconButton(
                        onPressed: player.previous,
                        tooltip: 'Anterior',
                        icon: Icon(Icons.skip_previous_rounded,
                            size: 26, color: context.ink),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.ink,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                            color: Colors.black.withValues(alpha: .10),
                          )],
                        ),
                        child: SizedBox(
                          width: 68,
                          height: 68,
                          child: IconButton(
                            onPressed: player.playPause,
                            tooltip: player.playing ? 'Pausar' : 'Reproduzir',
                            color: context.canvas,
                            iconSize: 31,
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                player.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                key: ValueKey(player.playing),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: player.next,
                        tooltip: 'Próxima',
                        icon: Icon(Icons.skip_next_rounded,
                            size: 26, color: context.ink),
                      ),
                      IconButton(
                        onPressed: player.toggleRepeat,
                        tooltip: 'Repetir',
                        icon: Icon(Icons.repeat_one_rounded, size: 21,
                          color: player.repeatOne ? context.ink : context.muted),
                      ),
                    ],
                  ),
                  if (player.error != null) ...[
                    const SizedBox(height: 16),
                    Text('Falha ao reproduzir: ${player.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: Colors.redAccent)),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: PlayerNavigationBar(
            index: 0,
            onChanged: onSelectTab,
          ),
        );
      },
    );
  }
}
