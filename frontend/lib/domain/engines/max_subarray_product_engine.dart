import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

/// dp_max[i] = max product subarray ending at i
/// dp_min[i] = min product subarray ending at i (needed for negatives)
/// We display dp_max as the primary table.
class MaxSubarrayProductEngine extends DPEngine {
  final List<int> array;

  const MaxSubarrayProductEngine({
    this.array = const [2, 3, -2, 4, -1],
  });

  @override
  String get name => 'Max Subarray Product';

  @override
  List<String> get pseudoCode => [
        'dpMax[i] = max product ending at index i',
        'dpMin[i] = min product ending at index i',
        'dpMax[0] = dpMin[0] = arr[0]',
        'for i = 1 to n-1:',
        '  candidates = {arr[i], dpMax[i-1]*arr[i], dpMin[i-1]*arr[i]}',
        '  dpMax[i] = max(candidates)',
        '  dpMin[i] = min(candidates)',
        'return max(dpMax)',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = array.length;
    final steps = <DPStepState>[];
    final dpMax = List<num?>.filled(n, null);
    final dpMin = List<num?>.filled(n, null);

    steps.add(DPStepState(
      table1D: List.from(dpMax),
      description:
          'Max Subarray Product. Array: ${array.join(', ')}. Track both max and min because negative×negative = positive.',
      formula: 'dpMax = dpMin = new int[n]',
      activeCodeLine: 0,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    dpMax[0] = array[0];
    dpMin[0] = array[0];
    steps.add(DPStepState(
      table1D: List.from(dpMax),
      activeCol: 0,
      description: 'Base: dpMax[0] = dpMin[0] = arr[0] = ${array[0]}',
      formula: 'dpMax[0] = dpMin[0] = ${array[0]}',
      activeCodeLine: 2,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    int globalMax = array[0];
    int globalMaxIdx = 0;

    for (int i = 1; i < n; i++) {
      final v = array[i];
      final candidates = [v, (dpMax[i - 1] as int) * v, (dpMin[i - 1] as int) * v];
      final newMax = candidates.reduce((a, b) => a > b ? a : b);
      final newMin = candidates.reduce((a, b) => a < b ? a : b);

      steps.add(DPStepState(
        table1D: List.from(dpMax),
        activeCol: i,
        readCells: [i - 1],
        description:
            'Candidates: arr[$i]=$v, dpMax[${i-1}]×$v=${(dpMax[i-1] as int)*v}, dpMin[${i-1}]×$v=${(dpMin[i-1] as int)*v}  → max=$newMax, min=$newMin',
        formula: 'dpMax[$i] = $newMax, dpMin[$i] = $newMin',
        activeCodeLine: 5,
        inputLabels: array.map((v) => '$v').toList(),
      ));

      dpMax[i] = newMax;
      dpMin[i] = newMin;

      if (newMax > globalMax) {
        globalMax = newMax;
        globalMaxIdx = i;
      }
    }

    steps.add(DPStepState(
      table1D: List.from(dpMax),
      doneCells: List.generate(n, (k) => k),
      activeCol: globalMaxIdx,
      description: 'Max subarray product = $globalMax (ends at index $globalMaxIdx)',
      formula: 'return max(dpMax) = $globalMax',
      activeCodeLine: 7,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    return steps;
  }
}