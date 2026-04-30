import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Universal notifier for playback speed across all visualizers.
/// Range: 0.25x to 4.0x. Default: 1.0x.
class PlaybackSpeed extends Notifier<double> {
  @override
  double build() => 1.0;

  void set(double speed) => state = speed;
}

final playbackSpeedProvider = NotifierProvider<PlaybackSpeed, double>(PlaybackSpeed.new);

/// Notifier for control panel visibility.
class ControlsVisibility extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final controlsVisibilityProvider = NotifierProvider<ControlsVisibility, bool>(ControlsVisibility.new);
