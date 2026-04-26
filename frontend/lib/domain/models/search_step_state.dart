enum SearchStepType { idle, comparing, found, notFound, rangeCheck, jump }

class SearchStepState {
  final List<int> array;
  final int targetValue;
  final int? currentIndex;      // element being actively examined
  final int? rangeStart;        // left bound (for binary / exponential)
  final int? rangeEnd;          // right bound
  final int? foundIndex;        // set only when element is found
  final int? jumpIndex;         // for jump search block boundary
  final SearchStepType stepType;
  final int activeCodeLine;

  const SearchStepState({
    required this.array,
    required this.targetValue,
    this.currentIndex,
    this.rangeStart,
    this.rangeEnd,
    this.foundIndex,
    this.jumpIndex,
    this.stepType = SearchStepType.idle,
    this.activeCodeLine = 0,
  });
}