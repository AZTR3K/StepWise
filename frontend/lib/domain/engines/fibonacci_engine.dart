import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

/// Computes F(0)…F(n) bottom-up and emits one [DPStepState] per cell fill.
class FibonacciSequenceEngine extends DPEngine {
  final int n;
  const FibonacciSequenceEngine({this.n = 9});

  @override
  String get name => 'Fibonacci Sequence';

  @override
  List<String> get pseudoCode => [
        'dp = array of size n+1',
        'dp[0] = 0',
        'dp[1] = 1',
        'for i = 2 to n:',
        '  dp[i] = dp[i-1] + dp[i-2]',
        'return dp[n]',
      ];

  @override
  List<DPStepState> generateSteps() {
    final steps = <DPStepState>[];
    final dp = List<num?>.filled(n + 1, null);

    // Initialise
    steps.add(DPStepState(
      table1D: List.from(dp),
      description: 'Allocate dp table of size ${n + 1}, all uninitialised.',
      formula: 'dp = new int[${n + 1}]',
      activeCodeLine: 0,
      inputLabels: List.generate(n + 1, (i) => 'F($i)'),
    ));

    dp[0] = 0;
    steps.add(DPStepState(
      table1D: List.from(dp),
      activeCol: 0,
      description: 'Base case: F(0) = 0',
      formula: 'dp[0] = 0',
      activeCodeLine: 1,
      inputLabels: List.generate(n + 1, (i) => 'F($i)'),
    ));

    dp[1] = 1;
    steps.add(DPStepState(
      table1D: List.from(dp),
      activeCol: 1,
      description: 'Base case: F(1) = 1',
      formula: 'dp[1] = 1',
      activeCodeLine: 2,
      inputLabels: List.generate(n + 1, (i) => 'F($i)'),
    ));

    for (int i = 2; i <= n; i++) {
      steps.add(DPStepState(
        table1D: List.from(dp),
        activeCol: i,
        readCells: [i - 1, i - 2],
        description: 'Reading dp[${i - 1}]=${dp[i - 1]} and dp[${i - 2}]=${dp[i - 2]}',
        formula: 'dp[$i] = dp[${i - 1}] + dp[${i - 2}]',
        activeCodeLine: 4,
        inputLabels: List.generate(n + 1, (i) => 'F($i)'),
      ));
      dp[i] = dp[i - 1]! + dp[i - 2]!;
      steps.add(DPStepState(
        table1D: List.from(dp),
        activeCol: i,
        doneCells: List.generate(i, (k) => k),
        description: 'dp[$i] = ${dp[i - 1]! + 0} + ${dp[i - 2]} = ${dp[i]}',
        formula: 'dp[$i] = ${dp[i]}',
        activeCodeLine: 4,
        inputLabels: List.generate(n + 1, (k) => 'F($k)'),
      ));
    }

    steps.add(DPStepState(
      table1D: List.from(dp),
      doneCells: List.generate(n + 1, (k) => k),
      activeCol: n,
      description: 'Done! F($n) = ${dp[n]}',
      formula: 'return dp[$n] = ${dp[n]}',
      activeCodeLine: 5,
      inputLabels: List.generate(n + 1, (k) => 'F($k)'),
    ));

    return steps;
  }
}