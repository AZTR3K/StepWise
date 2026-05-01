import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class KnapsackEngine extends DPEngine {
  final List<int> weights;
  final List<int> values;
  final int capacity;

  const KnapsackEngine({
    this.weights = const [2, 3, 4, 5],
    this.values = const [3, 4, 5, 6],
    this.capacity = 8,
  });

  @override
  String get name => '0/1 Knapsack';

  @override
  List<String> get pseudoCode => [
        'dp[i][w] = max value with i items, capacity w',
        'for i = 0 to n: dp[i][0] = 0',
        'for w = 0 to W: dp[0][w] = 0',
        'for i = 1 to n:',
        '  for w = 1 to W:',
        '    if weights[i-1] > w:',
        '      dp[i][w] = dp[i-1][w]   // skip item',
        '    else:',
        '      dp[i][w] = max(dp[i-1][w],',
        '        dp[i-1][w-weights[i-1]] + values[i-1])',
        'return dp[n][W]',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = weights.length;
    final W = capacity;
    final steps = <DPStepState>[];

    // Build null-initialised grid
    List<List<num?>> grid() =>
        List.generate(n + 1, (i) => List<num?>.filled(W + 1, null));

    final dp = grid();
    final rowLabels = ['∅', ...List.generate(n, (i) => 'i${i + 1}(w${weights[i]},v${values[i]})')];
    final colLabels = List.generate(W + 1, (w) => '$w');

    steps.add(DPStepState(
      table2D: _snapshot(dp, n, W),
      description: 'Initialise dp table (${n + 1} items × ${W + 1} capacities)',
      formula: 'dp = new int[${n + 1}][${W + 1}]',
      activeCodeLine: 0,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    // Base cases: row 0 and col 0
    for (int i = 0; i <= n; i++) {dp[i][0] = 0;}
    for (int w = 0; w <= W; w++) {dp[0][w] = 0;}
    steps.add(DPStepState(
      table2D: _snapshot(dp, n, W),
      description: 'Base cases: first row and first column = 0',
      formula: 'dp[0][w] = 0, dp[i][0] = 0',
      activeCodeLine: 2,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 1; i <= n; i++) {
      for (int w = 1; w <= W; w++) {
        final skipVal = dp[i - 1][w]!;

        if (weights[i - 1] > w) {
          // Must skip
          steps.add(DPStepState(
            table2D: _snapshot(dp, n, W),
            activeRow: i,
            activeCol: w,
            readCells: [DPStepState.pack2D(i - 1, w)],
            description:
                'Item $i (weight ${weights[i - 1]}) > capacity $w → skip item',
            formula: 'dp[$i][$w] = dp[${i - 1}][$w] = $skipVal',
            activeCodeLine: 6,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          dp[i][w] = skipVal;
        } else {
          final takeVal = dp[i - 1][w - weights[i - 1]]! + values[i - 1];
          final best = takeVal > skipVal ? takeVal : skipVal;
          steps.add(DPStepState(
            table2D: _snapshot(dp, n, W),
            activeRow: i,
            activeCol: w,
            readCells: [
              DPStepState.pack2D(i - 1, w),
              DPStepState.pack2D(i - 1, w - weights[i - 1]),
            ],
            description:
                'skip=$skipVal, take=${values[i - 1]}+dp[${i - 1}][${w - weights[i - 1]}]=$takeVal → best=$best',
            formula: 'dp[$i][$w] = max($skipVal, $takeVal) = $best',
            activeCodeLine: 9,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          dp[i][w] = best;
        }
      }
    }

    steps.add(DPStepState(
      table2D: _snapshot(dp, n, W),
      activeRow: n,
      activeCol: W,
      description: 'Done! Max value = ${dp[n][W]}',
      formula: 'return dp[$n][$W] = ${dp[n][W]}',
      activeCodeLine: 10,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    return steps;
  }

  List<List<num?>> _snapshot(List<List<num?>> dp, int n, int W) =>
      List.generate(n + 1, (i) => List<num?>.from(dp[i]));
}