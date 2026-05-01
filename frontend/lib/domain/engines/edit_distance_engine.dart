import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class EditDistanceEngine extends DPEngine {
  final String s1;
  final String s2;

  const EditDistanceEngine({
    this.s1 = 'sunday',
    this.s2 = 'saturday',
  });

  @override
  String get name => 'Edit Distance';

  @override
  List<String> get pseudoCode => [
        'dp[i][j] = edit distance of s1[0..i-1] and s2[0..j-1]',
        'for i = 0 to m: dp[i][0] = i  // delete all',
        'for j = 0 to n: dp[0][j] = j  // insert all',
        'for i = 1 to m:',
        '  for j = 1 to n:',
        '    if s1[i-1] == s2[j-1]:',
        '      dp[i][j] = dp[i-1][j-1]  // no cost',
        '    else:',
        '      dp[i][j] = 1 + min(',
        '        dp[i-1][j],   // delete',
        '        dp[i][j-1],   // insert',
        '        dp[i-1][j-1]) // replace',
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
      description: 'Edit distance: "$s1" → "$s2". Operations: insert, delete, replace.',
      formula: 'dp = new int[${m + 1}][${n + 1}]',
      activeCodeLine: 0,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 0; i <= m; i++) {dp[i][0] = i;}
    for (int j = 0; j <= n; j++) {dp[0][j] = j;}
    steps.add(DPStepState(
      table2D: _snap(dp, m, n),
      description: 'Base cases: dp[i][0]=i (delete i chars), dp[0][j]=j (insert j chars)',
      formula: 'dp[i][0]=i, dp[0][j]=j',
      activeCodeLine: 2,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final c1 = s1[i - 1];
        final c2 = s2[j - 1];
        if (c1 == c2) {
          final val = dp[i - 1][j - 1]!;
          steps.add(DPStepState(
            table2D: _snap(dp, m, n),
            activeRow: i,
            activeCol: j,
            readCells: [DPStepState.pack2D(i - 1, j - 1)],
            description: '"$c1" == "$c2" → no operation needed, inherit diagonal',
            formula: 'dp[$i][$j] = dp[${i - 1}][${j - 1}] = $val',
            activeCodeLine: 6,
            rowLabels: rowLabels,
            colLabels: colLabels,
          ));
          dp[i][j] = val;
        } else {
          final del = dp[i - 1][j]!;
          final ins = dp[i][j - 1]!;
          final rep = dp[i - 1][j - 1]!;
          final val = 1 + [del, ins, rep].reduce((a, b) => a < b ? a : b);
          final opName = (del <= ins && del <= rep)
              ? 'delete'
              : (ins <= rep ? 'insert' : 'replace');
          steps.add(DPStepState(
            table2D: _snap(dp, m, n),
            activeRow: i,
            activeCol: j,
            readCells: [
              DPStepState.pack2D(i - 1, j),
              DPStepState.pack2D(i, j - 1),
              DPStepState.pack2D(i - 1, j - 1),
            ],
            description:
                '"$c1"≠"$c2" → 1+min(del=$del, ins=$ins, rep=$rep) = $val ($opName)',
            formula: 'dp[$i][$j] = 1 + min($del, $ins, $rep) = $val',
            activeCodeLine: 11,
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
      description: 'Edit distance from "$s1" to "$s2" = ${dp[m][n]}',
      formula: 'return dp[$m][$n] = ${dp[m][n]}',
      activeCodeLine: 12,
      rowLabels: rowLabels,
      colLabels: colLabels,
    ));

    return steps;
  }

  List<List<num?>> _snap(List<List<num?>> dp, int m, int n) =>
      List.generate(m + 1, (i) => List<num?>.from(dp[i]));
}