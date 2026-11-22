import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Accurate, interactive seek position. Do not fabricate an audio waveform:
/// real waveforms require decoding/analyzing the source audio separately.
class WaveformSeek extends StatelessWidget {
  const WaveformSeek({
    super.key,
    required this.progress,
    required this.onSeek,
  });
  final double progress;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Progresso de reprodução',
      value: '${(progress * 100).round()}%',
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2.5,
          activeTrackColor: context.ink,
          inactiveTrackColor: context.muted.withValues(alpha: .30),
          thumbColor: context.ink,
          overlayColor: context.ink.withValues(alpha: .08),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 15),
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Slider(
          min: 0,
          max: 1,
          value: progress.clamp(0, 1).toDouble(),
          onChanged: onSeek,
        ),
      ),
    );
  }
}
