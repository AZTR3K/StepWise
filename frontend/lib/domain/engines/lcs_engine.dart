import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class LCSEngine extends DPEngine {
  final String s1;
  final String s2;

  const LCSEngine({
    this.s1 = 'ABCBDAB',
    this.s2 = 'BDCAB',
  });

  @override
  String get name => 'Longest Common Subsequence';

  @override
  List<String> get pseudoCode => [
        'dp[i][j] = LCS length of s1[0..i-1], s2[0..j-1]',
        'for i = 0 to m: dp[i][0] = 0',
        'for j = 0 to n: dp[0][j] = 0',
        'for i = 1 to m:',
        '  for j = 1 to n:',
        '    if s1[i-1] == s2[j-1]:',
        '      dp[i][j] = dp[i-1][j-1] + 1',
        '    else:',
        '      dp[i][j] = max(dp[i-1][j], dp[i][j-1])',
        'return dp[m][n]',
      ];

  @override
  List<DPStepState> generateSteps() {
    final m = s1.length;
    final n = s2.length;
    final steps = <DPStepState>[];

    final dp = List.generate(m + 1, (_) => List<num?>.filled(n + 1, null));

    final rowLabels = ['', ...s1.split('')];
    final colLabels = ['', ...s2.split('')];

    steps.add(DPStepState(
      table2D: _snap(dp, m, n),
      description: 'Initialise LCS table for "$s1" vs "$s2"',
      formula: 'dp = new int[${m + 1}][${n + 1}]',
      activeCodeLine: 0,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 0; i <= m; i++) {dp[i][0] = 0;}
    for (int j = 0; j <= n; j++) {dp[0][j] = 0;}
    steps.add(DPStepState(
      table2D: _snap(dp, m, n),
      description: 'Fill base cases: first row and first column with 0',
      formula: 'dp[i][0] = dp[0][j] = 0',
      activeCodeLine: 2,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final c1 = s1[i - 1];
        final c2 = s2[j - 1];
        if (c1 == c2) {
          final val = dp[i - 1][j - 1]! + 1;
          steps.add(DPStepState(
            table2D: _snap(dp, m, n),
            activeRow: i,
            activeCol: j,
            readCells: [DPStepState.pack2D(i - 1, j - 1)],
            description: 'Match! "$c1" == "$c2" → extend diagonal dp[${i - 1}][${j - 1}]',
            formula: 'dp[$i][$j] = dp[${i - 1}][${j - 1}] + 1 = $val',
            activeCodeLine: 6,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          dp[i][j] = val;
        } else {
          final top = dp[i - 1][j]!;
          final left = dp[i][j - 1]!;
          final val = top > left ? top : left;
          steps.add(DPStepState(
            table2D: _snap(dp, m, n),
            activeRow: i,
            activeCol: j,
            readCells: [
              DPStepState.pack2D(i - 1, j),
              DPStepState.pack2D(i, j - 1),
            ],
            description: '"$c1" ≠ "$c2" → max(dp[${i - 1}][$j]=$top, dp[$i][${j - 1}]=$left)',
            formula: 'dp[$i][$j] = max($top, $left) = $val',
            activeCodeLine: 8,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          dp[i][j] = val;
        }
      }
    }

    steps.add(DPStepState(
      table2D: _snap(dp, m, n),
      activeRow: m,
      activeCol: n,
      description: 'LCS length = ${dp[m][n]}',
      formula: 'return dp[$m][$n] = ${dp[m][n]}',
      activeCodeLine: 9,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    return steps;
  }

  List<List<num?>> _snap(List<List<num?>> dp, int m, int n) =>
      List.generate(m + 1, (i) => List<num?>.from(dp[i]));
}