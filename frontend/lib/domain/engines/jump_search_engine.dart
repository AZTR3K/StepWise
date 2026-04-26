import 'dart:math';
import '../models/search_step_state.dart';

class JumpSearchEngine {
  List<SearchStepState> generateSteps(List<int> array, int target) {
    final steps = <SearchStepState>[];
    final arr = List<int>.from(array)..sort();
    final n = arr.length;
    final step = sqrt(n).floor();

    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      activeCodeLine: 0,
    ));

    int prev = 0;
    int curr = step;

    // Phase 1: Jump ahead in blocks
    while (curr < n && arr[curr] < target) {
      // Show jump to block boundary
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: curr,
        jumpIndex: curr,
        rangeStart: prev,
        rangeEnd: curr,
        stepType: SearchStepType.jump,
        activeCodeLine: 1, // "jump by √n steps"
      ));

      prev = curr;
      curr = min(curr + step, n - 1);

      if (curr == n - 1 && arr[curr] < target) {
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          stepType: SearchStepType.notFound,
          activeCodeLine: 5,
        ));
        return steps;
      }
    }

    // Phase 2: Linear search within the block
    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      rangeStart: prev,
      rangeEnd: min(curr, n - 1),
      stepType: SearchStepType.rangeCheck,
      activeCodeLine: 2, // "linear search in block"
    ));

    for (int i = prev; i <= min(curr, n - 1); i++) {
      steps.add(SearchStepState(
        array: List.from(arr),
        targetValue: target,
        currentIndex: i,
        rangeStart: prev,
        rangeEnd: min(curr, n - 1),
        stepType: SearchStepType.comparing,
        activeCodeLine: 3, // "if arr[i] == target"
      ));

      if (arr[i] == target) {
        steps.add(SearchStepState(
          array: List.from(arr),
          targetValue: target,
          currentIndex: i,
          foundIndex: i,
          rangeStart: prev,
          rangeEnd: min(curr, n - 1),
          stepType: SearchStepType.found,
          activeCodeLine: 4, // "return i"
        ));
        return steps;
      }
    }

    steps.add(SearchStepState(
      array: List.from(arr),
      targetValue: target,
      stepType: SearchStepType.notFound,
      activeCodeLine: 5,
    ));

    return steps;
  }
}