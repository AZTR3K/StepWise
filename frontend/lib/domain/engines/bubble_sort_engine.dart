import '../models/step_state.dart';

class BubbleSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    // Initial state
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    int n = arr.length;
    for (int i = 0; i < n - 1; i++) {
      bool swapped = false;
      for (int j = 0; j < n - i - 1; j++) {
        // State: Comparing elements
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: j,
          activeIndexB: j + 1,
          isSwap: false,
          activeCodeLine: 2, // "if arr[j] > arr[j+1]"
        ));

        if (arr[j] > arr[j + 1]) {
          // Perform swap
          int temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
          swapped = true;

          // State: Elements swapped
          history.add(StepState(
            arraySnapshot: List.from(arr),
            activeIndexA: j,
            activeIndexB: j + 1,
            isSwap: true,
            activeCodeLine: 3, // "swap(arr[j], arr[j+1])"
          ));
        }
      }
      if (!swapped) break;
    }

    // Final sorted state
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 5));
    return history;
  }
}