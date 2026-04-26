import '../models/search_step_state.dart';

class BinarySearchEngine {
  List<SearchStepState> generateSteps(List<int> array, int target) {
    final steps = <SearchStepState>[];
    // Binary search requires sorted array
    final arr = List<int>.from(array)..sort();

    int left = 0;
    int right = arr.length - 1;

    // Initial state — show sorted array
    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      rangeStart: left,
      rangeEnd: right,
      activeCodeLine: 0,
    ));

    while (left <= right) {
      int mid = left + (right - left) ~/ 2;

      // Show current search range and mid point
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: mid,
        rangeStart: left,
        rangeEnd: right,
        stepType: SearchStepType.rangeCheck,
        activeCodeLine: 1, // "mid = (left + right) / 2"
      ));

      // Compare mid with target
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: mid,
        rangeStart: left,
        rangeEnd: right,
        stepType: SearchStepType.comparing,
        activeCodeLine: 2, // "if arr[mid] == target"
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
          activeCodeLine: 3, // "return mid"
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
          activeCodeLine: 4, // "left = mid + 1"
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
      activeCodeLine: 6, // "return -1"
    ));

    return steps;
  }
}