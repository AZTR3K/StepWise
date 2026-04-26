import '../models/search_step_state.dart';

class ExponentialSearchEngine {
  List<SearchStepState> generateSteps(List<int> array, int target) {
    final steps = <SearchStepState>[];
    final arr = List<int>.from(array)..sort();
    final n = arr.length;

    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      activeCodeLine: 0,
    ));

    // Edge case: first element
    if (arr[0] == target) {
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: 0,
        foundIndex: 0,
        stepType: SearchStepType.found,
        activeCodeLine: 3,
      ));
      return steps;
    }

    // Phase 1: Find range by doubling
    int bound = 1;
    while (bound < n && arr[bound] <= target) {
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: bound,
        jumpIndex: bound,
        rangeStart: 0,
        rangeEnd: bound,
        stepType: SearchStepType.jump,
        activeCodeLine: 1, // "double bound"
      ));
      bound *= 2;
    }

    // Phase 2: Binary search in found range
    int left = bound ~/ 2;
    int right = (bound < n) ? bound : n - 1;

    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      rangeStart: left,
      rangeEnd: right,
      stepType: SearchStepType.rangeCheck,
      activeCodeLine: 2, // "binary search in range"
    ));

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;

      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: mid,
        rangeStart: left,
        rangeEnd: right,
        stepType: SearchStepType.comparing,
        activeCodeLine: 3, // "compare arr[mid] with target"
      ));

      if (arr[mid] == target) {
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: mid,
          foundIndex: mid,
          rangeStart: left,
          rangeEnd: right,
          stepType: SearchStepType.found,
          activeCodeLine: 4, // "return mid"
        ));
        return steps;
      } else if (arr[mid] < target) {
        left = mid + 1;
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: mid,
          rangeStart: left,
          rangeEnd: right,
          stepType: SearchStepType.rangeCheck,
          activeCodeLine: 5, // "left = mid + 1"
        ));
      } else {
        right = mid - 1;
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: mid,
          rangeStart: left,
          rangeEnd: right,
          stepType: SearchStepType.rangeCheck,
          activeCodeLine: 5, // "right = mid - 1"
        ));
      }
    }

    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      stepType: SearchStepType.notFound,
      activeCodeLine: 6,
    ));

    return steps;
  }
}