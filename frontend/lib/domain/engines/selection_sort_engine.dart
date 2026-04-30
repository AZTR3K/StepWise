import '../models/step_state.dart';

class SelectionSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    int n = arr.length;
    for (int i = 0; i < n - 1; i++) {
      int minIdx = i;

      // Show starting position of scan
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: i,
        activeIndexB: null,
        isSwap: false,
        activeCodeLine: 2, // "assume arr[i] is minimum"
      ));

      for (int j = i + 1; j < n; j++) {
        // Show comparison to find minimum
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: minIdx,
          activeIndexB: j,
          isSwap: false,
          activeCodeLine: 3, // "find minimum in unsorted portion"
        ));

        if (arr[j] < arr[minIdx]) {
          minIdx = j;
        }
      }

      if (minIdx != i) {
        // Show swap
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: i,
          activeIndexB: minIdx,
          isSwap: false,
          activeCodeLine: 4, // "swap with first unsorted"
        ));

        int temp = arr[i];
        arr[i] = arr[minIdx];
        arr[minIdx] = temp;

        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: i,
          activeIndexB: minIdx,
          isSwap: true,
          activeCodeLine: 5, // "place minimum at position i"
        ));
      }
    }

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 6));
    return history;
  }
}