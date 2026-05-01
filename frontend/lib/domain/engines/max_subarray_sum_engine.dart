import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

/// Kadane's algorithm: dp[i] = max subarray sum ending at i.
class MaxSubarraySumEngine extends DPEngine {
  final List<int> array;

  const MaxSubarraySumEngine({
    this.array = const [-2, 1, -3, 4, -1, 2, 1, -5, 4],
  });

  @override
  String get name => 'Max Subarray Sum';

  @override
  List<String> get pseudoCode => [
        'dp[i] = max subarray sum ending at index i',
        'dp[0] = arr[0]',
        'for i = 1 to n-1:',
        '  dp[i] = max(arr[i], dp[i-1] + arr[i])',
        '  // extend prev subarray or start fresh',
        'return max(dp)',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = array.length;
    final steps = <DPStepState>[];
    final dp = List<num?>.filled(n, null);

    steps.add(DPStepState(
      table1D: List.from(dp),
      description: 'Kadane\'s algorithm. Array: ${array.join(', ')}',
      formula: 'dp = new int[n]',
      activeCodeLine: 0,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    dp[0] = array[0];
    steps.add(DPStepState(
      table1D: List.from(dp),
      activeCol: 0,
      description: 'dp[0] = arr[0] = ${array[0]}',
      formula: 'dp[0] = ${array[0]}',
      activeCodeLine: 1,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    int globalMax = array[0];
    int globalMaxIdx = 0;

    for (int i = 1; i < n; i++) {
      final extend = (dp[i - 1] as int) + array[i];
      final fresh = array[i];
      final val = extend > fresh ? extend : fresh;
      final didExtend = extend > fresh;

      steps.add(DPStepState(
        table1D: List.from(dp),
        activeCol: i,
        readCells: [i - 1],
        description:
            'Extend: dp[${i - 1}]+arr[$i]=${(dp[i - 1] as int)}+${array[i]}=$extend  |  Fresh: ${array[i]}  → pick ${didExtend ? 'extend' : 'fresh'}',
        formula: 'dp[$i] = max(${array[i]}, ${dp[i - 1]}+${array[i]}) = $val',
        activeCodeLine: 3,
        inputLabels: array.map((v) => '$v').toList(),
      ));

      dp[i] = val;
      if (val > globalMax) {
        globalMax = val;
        globalMaxIdx = i;
      }
    }

    steps.add(DPStepState(
      table1D: List.from(dp),
      doneCells: List.generate(n, (k) => k),
      activeCol: globalMaxIdx,
      description: 'Global max subarray sum = $globalMax (ends at index $globalMaxIdx)',
      formula: 'return max(dp) = $globalMax',
      activeCodeLine: 5,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    return steps;
  }
}