import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

/// Matrix Chain Multiplication: find the optimal parenthesisation.
/// [dims] encodes dimensions: matrix i has size dims[i] × dims[i+1].
class MatrixChainEngine extends DPEngine {
  final List<int> dims;

  const MatrixChainEngine({
    this.dims = const [10, 30, 5, 60], // 3 matrices: 10×30, 30×5, 5×60
  });

  @override
  String get name => 'Matrix Chain Multiplication';

  @override
  List<String> get pseudoCode => [
        'dp[i][j] = min multiplications for matrices i..j',
        'for i = 1 to n: dp[i][i] = 0  // single matrix',
        'for len = 2 to n:  // chain length',
        '  for i = 1 to n-len+1:',
        '    j = i + len - 1',
        '    dp[i][j] = ∞',
        '    for k = i to j-1:',
        '      cost = dp[i][k] + dp[k+1][j]',
        '             + dims[i-1]*dims[k]*dims[j]',
        '      dp[i][j] = min(dp[i][j], cost)',
        'return dp[1][n]',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = dims.length - 1; // number of matrices
    final steps = <DPStepState>[];
    const inf = 999999999;

    final dp = List.generate(n + 1, (_) => List<num?>.filled(n + 1, null));

    final labels = List.generate(n, (i) => 'M${i + 1}(${dims[i]}×${dims[i + 1]})');
    final rowLabels = ['', ...labels];
    final colLabels = ['', ...labels];

    steps.add(DPStepState(
      table2D: _snap(dp, n),
      description: 'Matrices: ${labels.join(', ')}. Minimise scalar multiplications.',
      formula: 'dp = new int[${n + 1}][${n + 1}]',
      activeCodeLine: 0,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 1; i <= n; i++) {dp[i][i] = 0;}
    steps.add(DPStepState(
      table2D: _snap(dp, n),
      description: 'Base: cost of a single matrix = 0',
      formula: 'for i: dp[i][i] = 0',
      activeCodeLine: 1,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int len = 2; len <= n; len++) {
      for (int i = 1; i <= n - len + 1; i++) {
        final j = i + len - 1;
        dp[i][j] = inf;

        for (int k = i; k < j; k++) {
          final cost = (dp[i][k] as int) +
              (dp[k + 1][j] as int) +
              dims[i - 1] * dims[k] * dims[j];
          steps.add(DPStepState(
            table2D: _snap(dp, n),
            activeRow: i,
            activeCol: j,
            readCells: [
              DPStepState.pack2D(i, k),
              DPStepState.pack2D(k + 1, j),
            ],
            description:
                'Split M$i..M$j at k=$k: dp[$i][$k]+dp[${k + 1}][$j]+${dims[i - 1]}×${dims[k]}×${dims[j]}=$cost',
            formula: 'dp[$i][$j] = min(${dp[i][j] == inf ? '∞' : dp[i][j]}, $cost)',
            activeCodeLine: 9,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          if (cost < (dp[i][j] as int)) dp[i][j] = cost;
        }

        steps.add(DPStepState(
          table2D: _snap(dp, n),
          activeRow: i,
          activeCol: j,
          description: 'Best split for M$i..M$j = ${dp[i][j]} multiplications',
          formula: 'dp[$i][$j] = ${dp[i][j]}',
          activeCodeLine: 9,
          rowLabels: rowLabels,
          colLabels: colLabels,
        ));
      }
    }

    steps.add(DPStepState(
      table2D: _snap(dp, n),
      activeRow: 1,
      activeCol: n,
      description: 'Min multiplications = ${dp[1][n]}',
      formula: 'return dp[1][$n] = ${dp[1][n]}',
      activeCodeLine: 10,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    return steps;
  }

  List<List<num?>> _snap(List<List<num?>> dp, int n) =>
      List.generate(n + 1, (i) => List<num?>.from(dp[i]));
}