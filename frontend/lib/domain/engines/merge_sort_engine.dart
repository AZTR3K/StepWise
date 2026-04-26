import '../models/step_state.dart';

class MergeSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0));

    _mergeSort(arr, 0, arr.length - 1, history);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 6));
    return history;
  }

  void _mergeSort(List<int> arr, int left, int right, List<StepState> history) {
    if (left >= right) return;

    int mid = (left + right) ~/ 2;

    // Show splitting
    history.add(StepState(
      arraySnapshot: List.from(arr),
      activeIndexA: left,
      activeIndexB: mid,
      isSwap: false,
      activeCodeLine: 1, // "find mid"
    ));

    _mergeSort(arr, left, mid, history);
    _mergeSort(arr, mid + 1, right, history);
    _merge(arr, left, mid, right, history);
  }

  void _merge(List<int> arr, int left, int mid, int right, List<StepState> history) {
    List<int> leftArr = arr.sublist(left, mid + 1);
    List<int> rightArr = arr.sublist(mid + 1, right + 1);

    int i = 0, j = 0, k = left;

    while (i < leftArr.length && j < rightArr.length) {
      // Show comparison
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: left + i,
        activeIndexB: mid + 1 + j,
        isSwap: false,
        activeCodeLine: 3, // "compare left[i] and right[j]"
      ));

      if (leftArr[i] <= rightArr[j]) {
        arr[k] = leftArr[i];
        i++;
      } else {
        arr[k] = rightArr[j];
        j++;
      }

      // Show placement
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: k,
        activeIndexB: null,
        isSwap: true,
        activeCodeLine: 4, // "place into merged array"
      ));
      k++;
    }

    while (i < leftArr.length) {
      arr[k] = leftArr[i];
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: k,
        isSwap: true,
        activeCodeLine: 4,
      ));
      i++;
      k++;
    }

    while (j < rightArr.length) {
      arr[k] = rightArr[j];
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: k,
        isSwap: true,
        activeCodeLine: 4,
      ));
      j++;
      k++;
    }
  }
}