import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dp_step_state.dart';
import '../../domain/models/dp_engine.dart';
import '../../domain/engines/fibonacci_engine.dart';
import '../../domain/engines/knapsack_engine.dart';
import '../../domain/engines/lcs_engine.dart';
import '../../domain/engines/lis_engine.dart';
import '../../domain/engines/coin_change_engine.dart';
import '../../domain/engines/edit_distance_engine.dart';
import '../../domain/engines/rod_cutting_engine.dart';
import '../../domain/engines/matrix_chain_engine.dart';
import '../../domain/engines/max_subarray_sum_engine.dart';
import '../../domain/engines/max_subarray_product_engine.dart';
import '../theme/app_colors.dart';
import '../state/visualizer_state.dart';
import '../widgets/glass_panel.dart';
import '../widgets/base_visualizer_control.dart';

// ─── Registry ─────────────────────────────────────────────────────────────────

/// All supported DP algorithms in display order.
const dpAlgorithmNames = [
  'Fibonacci Sequence',
  '0/1 Knapsack',
  'Longest Common Subsequence',
  'Longest Increasing Subsequence',
  'Coin Change',
  'Edit Distance',
  'Rod Cutting',
  'Matrix Chain Multiplication',
  'Max Subarray Sum',
  'Max Subarray Product',
];

DPEngine _engineFor(String name) {
  switch (name) {
    case 'Fibonacci Sequence':
      return const FibonacciSequenceEngine();
    case '0/1 Knapsack':
      return const KnapsackEngine();
    case 'Longest Common Subsequence':
      return const LCSEngine();
    case 'Longest Increasing Subsequence':
      return const LISEngine();
    case 'Coin Change':
      return const CoinChangeEngine();
    case 'Edit Distance':
      return const EditDistanceEngine();
    case 'Rod Cutting':
      return const RodCuttingEngine();
    case 'Matrix Chain Multiplication':
      return const MatrixChainEngine();
    case 'Max Subarray Sum':
      return const MaxSubarraySumEngine();
    case 'Max Subarray Product':
      return const MaxSubarrayProductEngine();
    default:
      return const FibonacciSequenceEngine();
  }
}

// ─── Colour constants (mirrors VisualizerScreen) ──────────────────────────────

const _bg = AppColors.background;
const _indigo = AppColors.indigo;
const _indigoLight = AppColors.indigoLight;
const _orange = AppColors.orange;

// Additional DP-specific colours
const _activeWrite = Color(0xFFFFB347);   // orange — cell being written
const _activeRead  = Color(0xFF7B9CFF);   // soft indigo — cells being read
const _doneFill    = Color(0xFF2E3A6B);   // dark indigo — completed cells
const _matchGreen  = Color(0xFF4CAF50);   // green — match in LCS / LIS
const _arrowColor  = Color(0xFFFFB347);   // arrows for LIS

// ─── Pseudocode map ───────────────────────────────────────────────────────────

Map<String, List<String>> _buildPseudoCodeMap() {
  return {for (final name in dpAlgorithmNames) name: _engineFor(name).pseudoCode};
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class DPVisualizerScreen extends ConsumerStatefulWidget {
  final String algorithmName;

  const DPVisualizerScreen({super.key, required this.algorithmName});

  @override
  ConsumerState<DPVisualizerScreen> createState() => _DPVisualizerScreenState();
}

class _DPVisualizerScreenState extends ConsumerState<DPVisualizerScreen> {
  late List<DPStepState> _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;

  // ── Pseudocode scroll (same pattern as VisualizerScreen) ─────────────────
  final ScrollController _pseudoScrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  bool _userIsScrolling = false;
  Timer? _userScrollDebounce;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void dispose() {
    _pseudoScrollController.dispose();
    _userScrollDebounce?.cancel();
    super.dispose();
  }

  void _rebuild() {
    _steps = _engineFor(widget.algorithmName).generateSteps();
    _currentStepIndex = 0;
  }

  void _restart() {
    if (_isPlaying) setState(() => _isPlaying = false);
    setState(() => _currentStepIndex = 0);
  }

  List<String> get _pseudoCode =>
      _buildPseudoCodeMap()[widget.algorithmName] ?? const [];

  // ── Playback — identical logic to VisualizerScreen ────────────────────────

  void _scrollToActiveLine(int activeLine) {
    if (_userIsScrolling) return;
    final key = _lineKeys[activeLine];
    if (key == null || key.currentContext == null) return;
    final speed = ref.read(playbackSpeedProvider);
    final durationMs = (300 / speed).round().clamp(50, 600);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userIsScrolling) return;
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: Duration(milliseconds: durationMs),
        curve: Curves.easeInOutCubic,
        alignment: 0.5,
      );
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
      _scrollToActiveLine(_steps[_currentStepIndex].activeCodeLine);
    } else {
      setState(() => _isPlaying = false);
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _isPlaying = false;
      });
      _scrollToActiveLine(_steps[_currentStepIndex].activeCodeLine);
    }
  }

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && _currentStepIndex < _steps.length - 1) {
      final speed = ref.read(playbackSpeedProvider);
      final delayMs = (600 / speed).round();
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
    if (mounted && _currentStepIndex == _steps.length - 1) {
      setState(() => _isPlaying = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final isDone = _currentStepIndex == _steps.length - 1;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.algorithmName,
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Ambient glow (same as VisualizerScreen) ─────────────────────
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _indigo.withValues(alpha: 0.15),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            Column(
              children: [
                // ── Pseudocode panel ─────────────────────────────────────────
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is UserScrollNotification) {
                            _userIsScrolling = true;
                            _userScrollDebounce?.cancel();
                            _userScrollDebounce =
                                Timer(const Duration(seconds: 2), () {
                              if (mounted) _userIsScrolling = false;
                            });
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _pseudoScrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _pseudoCode.asMap().entries.map((entry) {
                              final lineIndex = entry.key;
                              final isActive =
                                  lineIndex == step.activeCodeLine;
                              final key = _lineKeys.putIfAbsent(
                                  lineIndex, () => GlobalKey());
                              return KeyedSubtree(
                                key: key,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOutCubic,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? _indigo.withValues(alpha: 0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    entry.value,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: isActive
                                          ? _indigoLight
                                          : Colors.white54,
                                      fontWeight: isActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── DP Table Canvas ───────────────────────────────────────────
                Flexible(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 16,
                      child: Column(
                        children: [
                          // Formula strip
                          if (step.formula.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                step.formula,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: _orange.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                          // Table view
                          Expanded(
                            child: step.is2D
                                ? _2DGridView(step: step)
                                : _1DTableView(step: step),
                          ),

                          // Description strip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              step.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Done banner (mirrors VisualizerScreen) ───────────────────
                if (isDone)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      borderRadius: 14,
                      glowColor: Colors.greenAccent,
                      alpha: 0.15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.greenAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Table Filled',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Playback controls ─────────────────────────────────────────
                // NOTE: BaseVisualizerControl is reused as-is.
                // The onArrayUpdated callback receives the new array and
                // we regenerate steps — same pattern as VisualizerScreen.
                // For DP algorithms, the array field is not directly editable
                // via the control bar, so we pass a no-op; you can wire up a
                // custom input sheet later (see _DPInputSheet at bottom).
                BaseVisualizerControl(
                  isPlaying: _isPlaying,
                  canStepBack: _currentStepIndex > 0,
                  canStepForward: _currentStepIndex < _steps.length - 1,
                  onPlayPause: _togglePlay,
                  onStepBack: _prevStep,
                  onStepForward: _nextStep,
                  onRestart: _restart,
                  // DP screens expose the current dp table values as the
                  // "current array" — the control bar can display step count.
                  currentArray: step.table1D != null
                      ? step.table1D!
                            .map((v) => (v ?? 0).toInt())
                            .toList()
                      : [],
                  onArrayUpdated: (_) {}, // override with custom input later
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 1-D Table Widget ─────────────────────────────────────────────────────────

class _1DTableView extends StatelessWidget {
  final DPStepState step;
  const _1DTableView({required this.step});

  @override
  Widget build(BuildContext context) {
    final table = step.table1D!;
    final n = table.length;
    final hasArrows = step.hasArrows;

    return LayoutBuilder(builder: (ctx, constraints) {
      // Cell sizing
      const minCellW = 36.0;
      const maxCellW = 56.0;
      final cellW =
          (constraints.maxWidth / n).clamp(minCellW, maxCellW);
      const cellH = 40.0;
      const labelH = 18.0;
      final arrowH = hasArrows ? 28.0 : 0.0;
      final totalW = cellW * n;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(totalW, constraints.maxWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Input labels row
              if (step.inputLabels.isNotEmpty)
                _LabelRow(
                  labels: step.inputLabels,
                  cellWidth: cellW,
                  height: labelH,
                  color: Colors.white38,
                ),

              // dp[] index labels
              _LabelRow(
                labels: List.generate(n, (i) => '$i'),
                cellWidth: cellW,
                height: labelH,
                color: Colors.white24,
              ),

              // Table cells
              SizedBox(
                height: cellH,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(n, (i) {
                    final isWrite = i == step.activeCol;
                    final isRead = step.readCells.contains(i);
                    final isDone = step.doneCells.contains(i);
                    final val = table[i];
                    return _DPCell(
                      value: val != null ? '${val.toInt()}' : '',
                      width: cellW,
                      height: cellH,
                      isWrite: isWrite,
                      isRead: isRead,
                      isDone: isDone,
                      isNull: val == null,
                    );
                  }),
                ),
              ),

              // Arrow layer for LIS
              if (hasArrows)
                SizedBox(
                  height: arrowH,
                  child: CustomPaint(
                    size: Size(math.max(totalW, constraints.maxWidth), arrowH),
                    painter: _ArrowPainter(
                      arrows: step.arrows,
                      cellWidth: cellW,
                      n: n,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── 2-D Grid Widget ──────────────────────────────────────────────────────────

class _2DGridView extends StatelessWidget {
  final DPStepState step;
  const _2DGridView({required this.step});

  @override
  Widget build(BuildContext context) {
    final table = step.table2D!;
    final rows = table.length;
    final cols = table[0].length;

    return LayoutBuilder(builder: (ctx, constraints) {
      // Compute cell size from available space
      const headerW = 48.0;
      const headerH = 28.0;
      const minCellSize = 28.0;
      const maxCellSize = 44.0;

      final availW = constraints.maxWidth - headerW;
      final availH = constraints.maxHeight - headerH;
      final cellFromW = availW / cols;
      final cellFromH = availH / rows;
      final cellSize = math.min(cellFromW, cellFromH)
          .clamp(minCellSize, maxCellSize);

      final hasRowLabels = step.rowLabels.isNotEmpty;
      final hasColLabels = step.colLabels.isNotEmpty;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column header row
              if (hasColLabels)
                Row(children: [
                  SizedBox(width: headerW),
                  ...List.generate(cols, (j) {
                    final label = j < step.colLabels.length
                        ? step.colLabels[j]
                        : '$j';
                    return SizedBox(
                      width: cellSize,
                      height: headerH,
                      child: Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.white38),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }),
                ]),

              // Data rows
              ...List.generate(rows, (i) {
                final rowLabel = hasRowLabels && i < step.rowLabels.length
                    ? step.rowLabels[i]
                    : '$i';
                return Row(children: [
                  // Row header
                  SizedBox(
                    width: headerW,
                    height: cellSize,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          rowLabel,
                          style: const TextStyle(
                              fontSize: 9, color: Colors.white38),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // Cells
                  ...List.generate(cols, (j) {
                    final packed = DPStepState.pack2D(i, j);
                    final isWrite =
                        i == step.activeRow && j == step.activeCol;
                    final isRead = step.readCells.contains(packed);
                    final isDone = step.doneCells.contains(packed);
                    final val = table[i][j];
                    return _DPCell(
                      value: val != null ? '${val.toInt()}' : '',
                      width: cellSize,
                      height: cellSize,
                      isWrite: isWrite,
                      isRead: isRead,
                      isDone: isDone,
                      isNull: val == null,
                    );
                  }),
                ]);
              }),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Shared Cell Widget ───────────────────────────────────────────────────────

class _DPCell extends StatelessWidget {
  final String value;
  final double width;
  final double height;
  final bool isWrite;
  final bool isRead;
  final bool isDone;
  final bool isNull;

  const _DPCell({
    required this.value,
    required this.width,
    required this.height,
    required this.isWrite,
    required this.isRead,
    required this.isDone,
    required this.isNull,
  });

  Color get _bgColor {
    if (isWrite) return _activeWrite.withValues(alpha: 0.25);
    if (isRead) return _activeRead.withValues(alpha: 0.20);
    if (isDone) return _doneFill.withValues(alpha: 0.50);
    return Colors.white.withValues(alpha: 0.04);
  }

  Color get _borderColor {
    if (isWrite) return _activeWrite;
    if (isRead) return _activeRead;
    return Colors.white12;
  }

  Color get _textColor {
    if (isWrite) return _activeWrite;
    if (isRead) return _activeRead;
    if (isDone) return Colors.white70;
    return Colors.white30;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width - 2,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor, width: isWrite || isRead ? 1.5 : 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: (isWrite || isRead)
            ? [
                BoxShadow(
                  color: _borderColor.withValues(alpha: 0.4),
                  blurRadius: 6,
                )
              ]
            : null,
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            fontSize: width < 36 ? 9 : 12,
            color: _textColor,
            fontWeight: isWrite ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

// ─── Label Row ────────────────────────────────────────────────────────────────

class _LabelRow extends StatelessWidget {
  final List<String> labels;
  final double cellWidth;
  final double height;
  final Color color;

  const _LabelRow({
    required this.labels,
    required this.cellWidth,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: labels
          .map((l) => SizedBox(
                width: cellWidth,
                height: height,
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(fontSize: 9, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ─── Arrow Painter (LIS) ──────────────────────────────────────────────────────

class _ArrowPainter extends CustomPainter {
  final List<int> arrows; // packed from*1000+to
  final double cellWidth;
  final int n;

  const _ArrowPainter({
    required this.arrows,
    required this.cellWidth,
    required this.n,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _arrowColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final packed in arrows) {
      final from = packed ~/ 1000;
      final to = packed % 1000;
      if (from >= n || to >= n) continue;

      final xFrom = (from + 0.5) * cellWidth;
      final xTo = (to + 0.5) * cellWidth;
      final y1 = 0.0;
      final y2 = size.height;

      // Curved arc upward
      final path = Path()
        ..moveTo(xFrom, y1)
        ..quadraticBezierTo(
          (xFrom + xTo) / 2,
          -size.height * 0.5,
          xTo,
          y2,
        );

      canvas.drawPath(path, paint);

      // Arrowhead
      final arrowPaint = Paint()
        ..color = _arrowColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final angle = math.atan2(y2 - (size.height * 0.5), xTo - (xFrom + xTo) / 2);
      const arrowLen = 6.0;
      const arrowAngle = 0.4;
      canvas.drawLine(
        Offset(xTo, y2),
        Offset(
          xTo - arrowLen * math.cos(angle - arrowAngle),
          y2 - arrowLen * math.sin(angle - arrowAngle),
        ),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(xTo, y2),
        Offset(
          xTo - arrowLen * math.cos(angle + arrowAngle),
          y2 - arrowLen * math.sin(angle + arrowAngle),
        ),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) =>
      old.arrows != arrows || old.cellWidth != cellWidth;
}