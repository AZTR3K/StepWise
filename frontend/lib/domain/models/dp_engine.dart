import 'dp_step_state.dart';

/// Every DP algorithm implements this interface.
/// [generateSteps] returns the full list of [DPStepState] snapshots that the
/// visualiser will play back one-by-one.
abstract class DPEngine {
  const DPEngine();

  List<DPStepState> generateSteps();

  /// Human-readable name shown in the AppBar.
  String get name;

  /// Which pseudocode lines to display.
  List<String> get pseudoCode;
}