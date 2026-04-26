import '../models/step_state.dart';

class InsertionSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    int n = arr.length;
    for (int i = 1; i < n; i++) {
      int key = arr[i];
      int j = i - 1;

      // Show element being picked
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: i,
        activeIndexB: null,
        isSwap: false,
        activeCodeLine: 1, // "pick arr[i]"
      ));

      while (j >= 0 && arr[j] > key) {
        // Show comparison
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: j,
          activeIndexB: j + 1,
          isSwap: false,
          activeCodeLine: 2, // "compare with sorted portion"
        ));

        arr[j + 1] = arr[j];

        // Show shift
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: j,
          activeIndexB: j + 1,
          isSwap: true,
          activeCodeLine: 3, // "shift element right"
        ));

        j--;
      }

      arr[j + 1] = key;

      // Show insertion
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: j + 1,
        activeIndexB: null,
        isSwap: true,
        activeCodeLine: 4, // "insert at correct position"
      ));
    }

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 5));
    return history;
  }
}