import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class RodCuttingEngine extends DPEngine {
  final List<int> prices; // prices[i] = price of rod of length i+1
  final int rodLength;

  const RodCuttingEngine({
    this.prices = const [1, 5, 8, 9, 10, 17, 17, 20],
    this.rodLength = 8,
  });

  @override
  String get name => 'Rod Cutting';

  @override
  List<String> get pseudoCode => [
        'dp[i] = max revenue for rod of length i',
        'dp[0] = 0',
        'for i = 1 to n:',
        '  dp[i] = -∞',
        '  for j = 1 to i:',
        '    dp[i] = max(dp[i], prices[j] + dp[i-j])',
        'return dp[n]',
      ];

  @override
  List<DPStepState> generateSteps() {
    final n = rodLength;
    final steps = <DPStepState>[];
    final dp = List<num?>.filled(n + 1, null);

    steps.add(DPStepState(
      table1D: List.from(dp),
      description:
          'Rod of length $n. Prices: ${prices.take(n).join(', ')}. Maximise revenue.',
      formula: 'dp = new int[${n + 1}]',
      activeCodeLine: 0,
      inputLabels: List.generate(n + 1, (i) => '$i'),
    ));

    dp[0] = 0;
    for (int i = 1; i <= n; i++) {dp[i] = -1;}// sentinel
    steps.add(DPStepState(
      table1D: dp.map((v) => v == -1 ? null : v).toList(),
      activeCol: 0,
      description: 'Base: dp[0] = 0 (no rod → no revenue)',
      formula: 'dp[0] = 0',
      activeCodeLine: 1,
      inputLabels: List.generate(n + 1, (i) => '$i'),
    ));

    for (int i = 1; i <= n; i++) {
      int best = 0;
      for (int j = 1; j <= i; j++) {
        final price = j <= prices.length ? prices[j - 1] : 0;
        final candidate = price + (dp[i - j] as int);
        steps.add(DPStepState(
          table1D: dp.map((v) => v == -1 ? null : v).toList(),
          activeCol: i,
          readCells: [i - j],
          description:
              'Cut length $j (price $price) + dp[${i - j}]=${dp[i - j]} = $candidate',
          formula: 'dp[$i] = max(dp[$i], price[$j] + dp[${i - j}]) = max(${dp[i] == -1 ? '−∞' : dp[i]}, $candidate)',
          activeCodeLine: 5,
          inputLabels: List.generate(n + 1, (k) => '$k'),
        ));
        if (candidate > best) {
          best = candidate;
          dp[i] = best;
        }
      }
      steps.add(DPStepState(
        table1D: dp.map((v) => v == -1 ? null : v).toList(),
        activeCol: i,
        doneCells: List.generate(i, (k) => k),
        description: 'dp[$i] = $best (best revenue for rod of length $i)',
        formula: 'dp[$i] = $best',
        activeCodeLine: 5,
        inputLabels: List.generate(n + 1, (k) => '$k'),
      ));
    }

    steps.add(DPStepState(
      table1D: dp.map((v) => v == -1 ? null : v).toList(),
      doneCells: List.generate(n + 1, (k) => k),
      activeCol: n,
      description: 'Max revenue for rod of length $n = ${dp[n]}',
      formula: 'return dp[$n] = ${dp[n]}',
      activeCodeLine: 6,
      inputLabels: List.generate(n + 1, (k) => '$k'),
    ));

    return steps;
  }
}