import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class LISEngine extends DPEngine {
  final List<int> array;

  const LISEngine({
    this.array = const [10, 9, 2, 5, 3, 7, 101, 18],
  });

  @override
  String get name => 'Longest Increasing Subsequence';

  @override
  List<String> get pseudoCode => [
        'dp[i] = LIS length ending at index i',
        'for i = 0 to n-1: dp[i] = 1',
        'for i = 1 to n-1:',
        '  for j = 0 to i-1:',
        '    if arr[j] < arr[i]:',
        '      dp[i] = max(dp[i], dp[j] + 1)',
        '      record predecessor: pred[i] = j',
        'return max(dp)',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = array.length;
    final steps = <DPStepState>[];
    final dp = List<num?>.filled(n, null);
    final pred = List<int>.filled(n, -1);
    final arrows = <int>[];

    steps.add(DPStepState(
      table1D: List.from(dp),
      description: 'Array: ${array.join(', ')}. Each dp[i] = length of LIS ending at i.',
      formula: 'dp = new int[n]',
      activeCodeLine: 0,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    for (int i = 0; i < n; i++) {dp[i] = 1;}
    steps.add(DPStepState(
      table1D: List.from(dp),
      description: 'Initialise all dp[i] = 1 (every element is an LIS of length 1)',
      formula: 'for i in range(n): dp[i] = 1',
      activeCodeLine: 1,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    for (int i = 1; i < n; i++) {
      for (int j = 0; j < i; j++) {
        steps.add(DPStepState(
          table1D: List.from(dp),
          activeCol: i,
          readCells: [j],
          arrows: List.from(arrows),
          description:
              'Compare arr[$j]=${array[j]} with arr[$i]=${array[i]}',
          formula: 'if arr[$j] < arr[$i]: dp[$i] = max(dp[$i], dp[$j]+1)',
          activeCodeLine: 4,
          inputLabels: array.map((v) => '$v').toList(),
        ));

        if (array[j] < array[i]) {
          final candidate = dp[j]! + 1;
          if (candidate > dp[i]!) {
            dp[i] = candidate;
            pred[i] = j;
            // rebuild arrows list from pred array
            arrows.clear();
            for (int k = 0; k < n; k++) {
              if (pred[k] >= 0) arrows.add(pred[k] * 1000 + k);
            }
            steps.add(DPStepState(
              table1D: List.from(dp),
              activeCol: i,
              readCells: [j],
              arrows: List.from(arrows),
              description:
                  'arr[$j]=${array[j]} < arr[$i]=${array[i]} → dp[$i] updated to ${dp[i]}',
              formula: 'dp[$i] = dp[$j] + 1 = ${dp[i]}',
              activeCodeLine: 5,
              inputLabels: array.map((v) => '$v').toList(),
            ));
          }
        }
      }
    }

    final lisLength = dp.whereType<num>().reduce((a, b) => a > b ? a : b);
    steps.add(DPStepState(
      table1D: List.from(dp),
      doneCells: List.generate(n, (i) => i),
      arrows: List.from(arrows),
      description: 'LIS length = $lisLength',
      formula: 'return max(dp) = $lisLength',
      activeCodeLine: 7,
      inputLabels: array.map((v) => '$v').toList(),
    ));

    return steps;
  }
}