import '../models/search_step_state.dart';

class LinearSearchEngine {
  List<SearchStepState> generateSteps(List<int> array, int target) {
    final steps = <SearchStepState>[];
    final arr = List<int>.from(array);

    // Initial state
    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      activeCodeLine: 0,
    ));

    for (int i = 0; i < arr.length; i++) {
      // Highlight current element being checked
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: i,
        stepType: SearchStepType.comparing,
        activeCodeLine: 1, // "for each element"
      ));

      if (arr[i] == target) {
        // Found!
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: i,
          foundIndex: i,
          stepType: SearchStepType.found,
          activeCodeLine: 3, // "return index"
        ));
        return steps;
      } else {
        // Not this one, move on
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: i,
          stepType: SearchStepType.comparing,
          activeCodeLine: 2, // "if arr[i] == target"
        ));
      }
    }

    // Not found
    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      stepType: SearchStepType.notFound,
      activeCodeLine: 4, // "return -1"
    ));

    return steps;
  }
}