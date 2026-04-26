import '../models/step_state.dart';

class HeapSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);
    int n = arr.length;

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    // Build max-heap
    for (int i = n ~/ 2 - 1; i >= 0; i--) {
      _heapify(arr, n, i, history);
    }

    // Extract elements from heap one by one
    for (int i = n - 1; i > 0; i--) {
      // Show swap root with last
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: 0,
        activeIndexB: i,
        isSwap: false,
        activeCodeLine: 3, // "swap root with last"
      ));

      int temp = arr[0];
      arr[0] = arr[i];
      arr[i] = temp;

      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: 0,
        activeIndexB: i,
        isSwap: true,
        activeCodeLine: 4, // "extract max"
      ));

      _heapify(arr, i, 0, history);
    }

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 6));
    return history;
  }

  void _heapify(List<int> arr, int n, int i, List<StepState> history) {
    int largest = i;
    int left = 2 * i + 1;
    int right = 2 * i + 2;

    if (left < n) {
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: largest,
        activeIndexB: left,
        isSwap: false,
        activeCodeLine: 1, // "build max-heap"
      ));
      if (arr[left] > arr[largest]) largest = left;
    }

    if (right < n) {
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: largest,
        activeIndexB: right,
        isSwap: false,
        activeCodeLine: 1,
      ));
      if (arr[right] > arr[largest]) largest = right;
    }

    if (largest != i) {
      int temp = arr[i];
      arr[i] = arr[largest];
      arr[largest] = temp;

      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: i,
        activeIndexB: largest,
        isSwap: true,
        activeCodeLine: 2, // "heapify down"
      ));

      _heapify(arr, n, largest, history);
    }
  }
}