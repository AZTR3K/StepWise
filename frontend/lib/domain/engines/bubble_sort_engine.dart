import '../models/step_state.dart';

class BubbleSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    int n = arr.length;
    for (int i = 0; i < n - 1; i++) {
      history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 1));
      bool swapped = false;
      history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 2));

      for (int j = 0; j < n - i - 1; j++) {
        history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 3));

        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: j,
          activeIndexB: j + 1,
          isSwap: false,
          activeCodeLine: 4,
        ));

        if (arr[j] > arr[j + 1]) {
          int temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;
          swapped = true;

          history.add(StepState(
            arraySnapshot: List.from(arr),
            activeIndexA: j,
            activeIndexB: j + 1,
            isSwap: true,
            activeCodeLine: 5,
          ));

          history.add(StepState(
            arraySnapshot: List.from(arr),
            activeIndexA: j,
            activeIndexB: j + 1,
            isSwap: false,
            activeCodeLine: 6,
          ));
        }
      }
      
      history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 7));
      if (!swapped) break;
    }

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 8));
    return history;
  }
}