import '../models/dp_engine.dart';
import '../models/dp_step_state.dart';

class CoinChangeEngine extends DPEngine {
  final List<int> coins;
  final int amount;

  const CoinChangeEngine({
    this.coins = const [1, 2, 5],
    this.amount = 11,
  });

  @override
  String get name => 'Coin Change';

  @override
  List<String> get pseudoCode => [
        'dp[i] = min coins to make amount i',
        'dp[0] = 0',
        'for i = 1 to amount: dp[i] = ∞',
        'for i = 1 to amount:',
        '  for each coin c:',
        '    if c <= i:',
        '      dp[i] = min(dp[i], dp[i-c] + 1)',
        'return dp[amount]  (or -1 if ∞)',
      ];

  @override
  List<DPStepState> generateSteps() {
    const inf = 999999;
    final steps = <DPStepState>[];
    final dp = List<num?>.filled(amount + 1, null);

    steps.add(DPStepState(
      table1D: List.from(dp),
      description: 'Coins: ${coins.join(', ')}. Find min coins for amount $amount.',
      formula: 'dp = new int[${amount + 1}]',
      activeCodeLine: 0,
      inputLabels: List.generate(amount + 1, (i) => '$i'),
    ));

    dp[0] = 0;
    for (int i = 1; i <= amount; i++) {dp[i] = inf;}
    steps.add(DPStepState(
      table1D: dp.map((v) => v == inf ? null : v).toList(),
      activeCol: 0,
      description: 'Base case dp[0]=0 (need 0 coins for amount 0). All others = ∞.',
      formula: 'dp[0] = 0',
      activeCodeLine: 1,
      inputLabels: List.generate(amount + 1, (i) => '$i'),
    ));

    for (int i = 1; i <= amount; i++) {
      for (final c in coins) {
        if (c <= i) {
          final candidate = (dp[i - c] as int) + 1;
          steps.add(DPStepState(
            table1D: dp.map((v) => v == inf ? null : v).toList(),
            activeCol: i,
            readCells: [i - c],
            description:
                'Amount $i, coin $c → dp[${i - c}]=${dp[i - c] == inf ? '∞' : dp[i - c]} + 1 = $candidate vs dp[$i]=${dp[i] == inf ? '∞' : dp[i]}',
            formula: 'dp[$i] = min(dp[$i], dp[${i - c}] + 1)',
            activeCodeLine: 6,
            inputLabels: List.generate(amount + 1, (k) => '$k'),
          ));
          if (candidate < (dp[i] as int)) {
            dp[i] = candidate;
          }
        }
      }
      steps.add(DPStepState(
        table1D: dp.map((v) => v == inf ? null : v).toList(),
        activeCol: i,
        doneCells: List.generate(i, (k) => k),
        description:
            'dp[$i] settled = ${dp[i] == inf ? '∞ (impossible)' : dp[i]}',
        formula: 'dp[$i] = ${dp[i] == inf ? '∞' : dp[i]}',
        activeCodeLine: 6,
        inputLabels: List.generate(amount + 1, (k) => '$k'),
      ));
    }

    final result = dp[amount];
    steps.add(DPStepState(
      table1D: dp.map((v) => v == inf ? null : v).toList(),
      doneCells: List.generate(amount + 1, (k) => k),
      activeCol: amount,
      description: result == inf
          ? 'Amount $amount cannot be formed with given coins.'
          : 'Minimum coins needed for amount $amount = $result',
      formula: 'return dp[$amount] = ${result == inf ? '-1' : result}',
      activeCodeLine: 7,
      inputLabels: List.generate(amount + 1, (k) => '$k'),
    ));

    return steps;
  }
}