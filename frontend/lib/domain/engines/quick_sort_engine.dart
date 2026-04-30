import '../models/step_state.dart';

class QuickSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    _quickSort(arr, 0, arr.length - 1, history);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 7));
    return history;
  }

  void _quickSort(List<int> arr, int low, int high, List<StepState> history) {
    if (low < high) {
      int pivotIndex = _partition(arr, low, high, history);
      _quickSort(arr, low, pivotIndex - 1, history);
      _quickSort(arr, pivotIndex + 1, high, history);
    }
  }

  int _partition(List<int> arr, int low, int high, List<StepState> history) {
    int pivot = arr[high];

    // Show pivot selection
    history.add(StepState(
      arraySnapshot: List.from(arr),
      activeIndexA: high,
      activeIndexB: null,
      isSwap: false,
      activeCodeLine: 2, // "choose pivot"
    ));

    int i = low - 1;

    for (int j = low; j < high; j++) {
      // Show comparison with pivot
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: j,
        activeIndexB: high,
        isSwap: false,
        activeCodeLine: 4, // "if arr[j] <= pivot"
      ));

      if (arr[j] <= pivot) {
        i++;
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;

        // Show swap
        history.add(StepState(
          arraySnapshot: List.from(arr),
          activeIndexA: i,
          activeIndexB: j,
          isSwap: true,
          activeCodeLine: 5, // "swap arr[i] and arr[j]"
        ));
      }
    }

    // Place pivot in correct position
    int temp = arr[i + 1];
    arr[i + 1] = arr[high];
    arr[high] = temp;

    history.add(StepState(
      arraySnapshot: List.from(arr),
      activeIndexA: i + 1,
      activeIndexB: high,
      isSwap: true,
      activeCodeLine: 6, // "place pivot"
    ));

    return i + 1;
  }
}