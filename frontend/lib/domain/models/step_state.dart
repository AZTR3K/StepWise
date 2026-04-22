class StepState {
  final List<int> arraySnapshot;
  final int? activeIndexA;
  final int? activeIndexB;
  final bool isSwap;
  final int activeCodeLine;

  StepState({
    required this.arraySnapshot,
    this.activeIndexA,
    this.activeIndexB,
    this.isSwap = false,
    this.activeCodeLine = 0,
  });
}