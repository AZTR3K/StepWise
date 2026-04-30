import '../models/step_state.dart';

class MergeSortEngine {
  List<StepState> generateSteps(List<int> initialArray) {
    List<StepState> history = [];
    List<int> arr = List.from(initialArray);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 0)); // function mergeSort

    _mergeSort(arr, 0, arr.length - 1, history);

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 10)); // array is sorted (or end)
    return history;
  }

  void _mergeSort(List<int> arr, int left, int right, List<StepState> history) {
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 1)); // if l >= r
    if (left >= right) return;

    int mid = (left + right) ~/ 2;

    history.add(StepState(
      arraySnapshot: List.from(arr),
      activeIndexA: left,
      activeIndexB: mid,
      isSwap: false,
      activeCodeLine: 2, // mid = (l+r)/2
    ));

    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 3)); // mergeSort left
    _mergeSort(arr, left, mid, history);
    
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 4)); // mergeSort right
    _mergeSort(arr, mid + 1, right, history);
    
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 5)); // merge
    _merge(arr, left, mid, right, history);
  }

  void _merge(List<int> arr, int left, int mid, int right, List<StepState> history) {
    history.add(StepState(arraySnapshot: List.from(arr), activeCodeLine: 7)); // function merge
    List<int> leftArr = arr.sublist(left, mid + 1);
    List<int> rightArr = arr.sublist(mid + 1, right + 1);

    int i = 0, j = 0, k = left;

    while (i < leftArr.length && j < rightArr.length) {
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: left + i,
        activeIndexB: mid + 1 + j,
        isSwap: false,
        activeCodeLine: 8, // compare left[i] and right[j]
      ));

      if (leftArr[i] <= rightArr[j]) {
        arr[k] = leftArr[i];
        i++;
      } else {
        arr[k] = rightArr[j];
        j++;
      }

      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: k,
        activeIndexB: null,
        isSwap: true,
        activeCodeLine: 9, // place smaller into arr[k]
      ));
      k++;
    }

    while (i < leftArr.length) {
      arr[k] = leftArr[i];
      history.add(StepState(
        arraySnapshot: List.from(arr),
        activeIndexA: k,
        isSwap: true,
        activeCodeLine: 9,
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
        activeCodeLine: 9,
      ));
      j++;
      k++;
    }
  }
}