import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engines/inorder_engine.dart';
import '../../domain/engines/preorder_engine.dart';
import '../../domain/engines/avl_engine.dart';
import '../../domain/engines/redblack_engine.dart';
import '../../domain/models/tree_step_state.dart';
import '../theme/app_colors.dart';
import '../state/visualizer_state.dart';
import '../widgets/glass_panel.dart';

// ─── Pseudocode ───────────────────────────────────────────────────────────────
const _pseudoCodeMap = {
  'Inorder': [
    "0. inorder(node):",
    "1.   if node == null: return",
    "2.   inorder(node.left)",
    "3.   visit(node)",          // activeCodeLine 2
    "4.   inorder(node.right)",  // activeCodeLine 3
    "5. done",                   // activeCodeLine 4
  ],
  'Preorder': [
    "0. preorder(node):",
    "1.   if node == null: return",
    "2.   visit(node)",
    "3.   preorder(node.left)",
    "4.   preorder(node.right)",
    "5. done",
  ],
  'Postorder': [
    "0. postorder(node):",
    "1.   if node == null: return",
    "2.   postorder(node.left)",
    "3.   postorder(node.right)",
    "4.   visit(node)",
    "5. done",
  ],
  'AVL': [
    "1. insert(node, value)",
    "2. update height",
    "3. bf = height(L) - height(R)",
    "4. if |bf| > 1: rotate",
    "5.   LL → right rotate",
    "6.   RR → left rotate",
    "7.   LR / RL → double rotate",
    "8. done",
  ],
  'Red-Black': [
    "1. insert as BST node (RED)",
    "2. if parent is RED:",
    "3.   Uncle RED → recolour",
    "4.   Uncle BLACK → rotate",
    "5. root is always BLACK",
    "6. done",
  ],
};

// ─── Step generator ───────────────────────────────────────────────────────────
List<TreeStepState> _generateSteps(String name, List<int> values) {
  switch (name) {
    case 'Inorder':   return InorderEngine().generateSteps(values);
    case 'Preorder':  return PreorderEngine().generateSteps(values);
    //case 'Postorder': return PostorderEngine().generateSteps(values);
    case 'AVL':       return AVLEngine().generateSteps(values);
    case 'Red-Black': return RedBlackTreeEngine().generateSteps(values);
    default:          return InorderEngine().generateSteps(values);
  }
}

// ─── Tree Layout ──────────────────────────────────────────────────────────────
/// Computes (x, y) in [0,1]×[0,1] for each node using a level-based layout.
/// Returns a map from node index → Offset(x, y).
Map<int, Offset> _computeTreeLayout(List<TreeNodeSnapshot> nodes, int? rootIndex) {
  if (rootIndex == null || nodes.isEmpty) return {};

  final positions = <int, Offset>{};
  // BFS to assign positions
  // Each level divides horizontal space equally.
  final levels = <int, List<int>>{};
  final parentMap = <int, int>{};
  final queue = <int>[rootIndex];
  final depthMap = <int, int>{rootIndex: 0};

  while (queue.isNotEmpty) {
    final idx = queue.removeAt(0);
    final depth = depthMap[idx]!;
    levels.putIfAbsent(depth, () => []).add(idx);
    final node = nodes[idx];
    if (node.left != null) {
      depthMap[node.left!] = depth + 1;
      parentMap[node.left!] = idx;
      queue.add(node.left!);
    }
    if (node.right != null) {
      depthMap[node.right!] = depth + 1;
      parentMap[node.right!] = idx;
      queue.add(node.right!);
    }
  }

  final totalDepth = depthMap.values.fold(0, math.max);
  // Assign x using in-order traversal for natural BST spacing
  int counter = 0;
  final xOrder = <int, int>{};

  void assignX(int? idx) {
    if (idx == null || idx >= nodes.length) return;
    final node = nodes[idx];
    assignX(node.left);
    xOrder[idx] = counter++;
    assignX(node.right);
  }

  assignX(rootIndex);

  final totalNodes = xOrder.length;
  for (final entry in xOrder.entries) {
    final depth = depthMap[entry.key] ?? 0;
    final xFrac = totalNodes <= 1
        ? 0.5
        : (entry.value + 0.5) / totalNodes;
    final yFrac = totalDepth == 0
        ? 0.15
        : 0.10 + (depth / (totalDepth + 1)) * 0.80;
    positions[entry.key] = Offset(xFrac, yFrac);
  }

  return positions;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class TreeVisualizerScreen extends ConsumerStatefulWidget {
  final String algorithmName;
  const TreeVisualizerScreen({super.key, required this.algorithmName});

  @override
  ConsumerState<TreeVisualizerScreen> createState() =>
      _TreeVisualizerScreenState();
}

class _TreeVisualizerScreenState extends ConsumerState<TreeVisualizerScreen>
    with TickerProviderStateMixin {

  late List<int> _values;
  late List<TreeStepState> _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;

  bool _showPseudocode = true;
  late AnimationController _pseudoController;
  late Animation<double> _pseudoAnimation;

  final _pseudoScrollController = ScrollController();
  final _lineKeys = <int, GlobalKey>{};
  bool _userIsScrolling = false;
  Timer? _scrollDebounce;

  // ── Name normalisation ────────────────────────────────────────────────────
  String get _normalisedName {
    final n = widget.algorithmName;
    if (n.toLowerCase().contains('inorder') || n.toLowerCase().contains('in-order')) return 'Inorder';
    if (n.toLowerCase().contains('preorder') || n.toLowerCase().contains('pre-order')) return 'Preorder';
    if (n.toLowerCase().contains('postorder') || n.toLowerCase().contains('post-order')) return 'Postorder';
    if (n.toLowerCase().contains('avl')) return 'AVL';
    if (n.toLowerCase().contains('red') || n.toLowerCase().contains('black')) return 'Red-Black';
    return 'Inorder';
  }

  List<String> get _pseudoCode =>
      _pseudoCodeMap[_normalisedName] ?? _pseudoCodeMap['Inorder']!;

  bool get _isStructuralAlgo =>
      _normalisedName == 'AVL' || _normalisedName == 'Red-Black';

  bool get _isRBTree => _normalisedName == 'Red-Black';

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _values = List.from(defaultTreeValues);
    _rebuildSteps();

    _pseudoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _pseudoAnimation = CurvedAnimation(
        parent: _pseudoController, curve: Curves.easeInOutCubic);
    _pseudoController.forward();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _pseudoScrollController.dispose();
    _scrollDebounce?.cancel();
    super.dispose();
  }

  // ── Steps ─────────────────────────────────────────────────────────────────
  void _rebuildSteps() {
    _steps = _generateSteps(_normalisedName, _values);
    _currentStepIndex = 0;
    _isPlaying = false;
  }

  // ── Playback ──────────────────────────────────────────────────────────────
  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() => _currentStepIndex++);
      _scrollToLine(_steps[_currentStepIndex].activeCodeLine);
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
      _scrollToLine(_steps[_currentStepIndex].activeCodeLine);
    }
  }

  void _restart() => setState(_rebuildSteps);

  void _togglePlay() async {
    setState(() => _isPlaying = !_isPlaying);
    while (_isPlaying && _currentStepIndex < _steps.length - 1) {
      final speed = ref.read(playbackSpeedProvider);
      await Future.delayed(Duration(milliseconds: (700 / speed).round()));
      if (!mounted || !_isPlaying) break;
      _nextStep();
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  void _scrollToLine(int line) {
    if (_userIsScrolling) return;
    final key = _lineKeys[line];
    if (key?.currentContext == null) return;
    final speed = ref.read(playbackSpeedProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _userIsScrolling) return;
      Scrollable.ensureVisible(key!.currentContext!,
          duration: Duration(
              milliseconds: (300 / speed).round().clamp(50, 600)),
          curve: Curves.easeInOutCubic,
          alignment: 0.5);
    });
  }

  // ── Tree editing ──────────────────────────────────────────────────────────
  void _addValue(int v) {
    if (_values.contains(v)) return;
    setState(() {
      _values = [..._values, v];
      _rebuildSteps();
    });
  }

  void _removeValue(int v) {
    setState(() {
      _values = _values.where((x) => x != v).toList();
      _rebuildSteps();
    });
  }

  void _resetTree() {
    setState(() {
      _values = List.from(defaultTreeValues);
      _rebuildSteps();
    });
  }

  // ── Editor sheet ──────────────────────────────────────────────────────────
  void _openEditorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TreeEditorSheet(
        values: _values,
        onAddValue: (v) { _addValue(v); },
        onRemoveValue: (v) { _removeValue(v); },
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _steps.isNotEmpty ? _steps[_currentStepIndex] : null;
    final progress = _steps.length <= 1
        ? 0.0
        : _currentStepIndex / (_steps.length - 1);

    if (step == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Add values to build a tree.',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final layout = _computeTreeLayout(step.nodes, step.rootIndex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.algorithmName,
            style: const TextStyle(
                fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        actions: [
          // Pseudocode toggle
          IconButton(
            onPressed: () {
              setState(() => _showPseudocode = !_showPseudocode);
              _showPseudocode
                  ? _pseudoController.forward()
                  : _pseudoController.reverse();
            },
            icon: Icon(
              _showPseudocode
                  ? Icons.code_off_rounded
                  : Icons.code_rounded,
              color: _showPseudocode
                  ? AppColors.indigoLight
                  : Colors.white38,
              size: 20,
            ),
          ),
          // Tree editor
          IconButton(
            onPressed: _openEditorSheet,
            icon: Icon(Icons.tune_rounded,
                color: Colors.white.withValues(alpha: 0.65), size: 20),
            tooltip: 'Edit tree',
          ),
          // Reset
          IconButton(
            onPressed: _resetTree,
            icon: Icon(Icons.refresh_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            // ── Status row ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  _TreeStatusBadge(step: step),
                  const SizedBox(width: 10),
                  if (step.stepDescription != null)
                    Expanded(
                      child: Text(
                        step.stepDescription!,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.38),
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // ── Pseudocode (collapsible) ─────────────────────────────────────
            SizeTransition(
              sizeFactor: _pseudoAnimation,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  borderRadius: 14,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is UserScrollNotification) {
                        _userIsScrolling = true;
                        _scrollDebounce?.cancel();
                        _scrollDebounce = Timer(
                            const Duration(seconds: 2),
                            () {
                              if (mounted) _userIsScrolling = false;
                            });
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _pseudoScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _pseudoCode.asMap().entries.map((entry) {
                          final lineIdx = entry.key;
                          final isActive =
                              lineIdx == step.activeCodeLine;
                          final key = _lineKeys.putIfAbsent(
                              lineIdx, () => GlobalKey());
                          return KeyedSubtree(
                            key: key,
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.indigo
                                        .withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11.5,
                                  color: isActive
                                      ? AppColors.indigoLight
                                      : Colors.white38,
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

            // ── Tree canvas ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final size = Size(
                      constraints.maxWidth, constraints.maxHeight);
                  return CustomPaint(
                    size: size,
                    painter: _TreePainter(
                      step: step,
                      layout: layout,
                      isRBTree: _isRBTree,
                    ),
                  );
                }),
              ),
            ),

            // ── Traversal order strip ────────────────────────────────────────
            if (!_isStructuralAlgo && step.visitedOrder.isNotEmpty)
              _TraversalOrderStrip(
                  nodes: step.nodes,
                  visitedOrder: step.visitedOrder,
                  activeNodeIndex: step.activeNodeIndex),

            // ── Progress bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor:
                      Colors.white.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation(
                      AppColors.indigo),
                ),
              ),
            ),

            // ── Playback bar ─────────────────────────────────────────────────
            _PlaybackBar(
              isPlaying: _isPlaying,
              canBack: _currentStepIndex > 0,
              canForward: _currentStepIndex < _steps.length - 1,
              onPlayPause: _togglePlay,
              onBack: _prevStep,
              onForward: _nextStep,
              onRestart: _restart,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tree Painter ─────────────────────────────────────────────────────────────
class _TreePainter extends CustomPainter {
  final TreeStepState step;
  final Map<int, Offset> layout;
  final bool isRBTree;
  static const double _r = 22.0;

  const _TreePainter({
    required this.step,
    required this.layout,
    required this.isRBTree,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawEdges(canvas, size);
    _drawNodes(canvas, size);
  }

  Offset _pos(int idx, Size size) {
    final frac = layout[idx] ?? const Offset(0.5, 0.5);
    return Offset(frac.dx * size.width, frac.dy * size.height);
  }

  void _drawEdges(Canvas canvas, Size size) {
    for (int idx = 0; idx < step.nodes.length; idx++) {
      final node = step.nodes[idx];
      final from = _pos(idx, size);

      for (final childIdx in [node.left, node.right]) {
        if (childIdx == null || childIdx >= step.nodes.length) continue;
        final to = _pos(childIdx, size);

        final dir = to - from;
        final dist = dir.distance;
        if (dist < _r * 2) continue;
        final unit = dir / dist;
        final start = from + unit * (_r + 2);
        final end   = to   - unit * (_r + 2);

        final isActive = idx == step.activeNodeIndex ||
            childIdx == step.activeNodeIndex;
        final bothVisited = step.visitedOrder.contains(idx) &&
            step.visitedOrder.contains(childIdx);

        Color edgeColor;
        double strokeW;
        if (isActive) {
          edgeColor = AppColors.orange;
          strokeW = 2.2;
          // Glow
          canvas.drawLine(start, end, Paint()
            ..color = AppColors.orange.withValues(alpha: 0.15)
            ..strokeWidth = 10
            ..style = PaintingStyle.stroke
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        } else if (bothVisited) {
          edgeColor = AppColors.indigo.withValues(alpha: 0.5);
          strokeW = 1.5;
        } else {
          edgeColor = Colors.white.withValues(alpha: 0.1);
          strokeW = 1.0;
        }

        canvas.drawLine(start, end, Paint()
          ..color = edgeColor
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (int idx = 0; idx < step.nodes.length; idx++) {
      final node = step.nodes[idx];
      final c    = _pos(idx, size);

      final isActive    = node.isActive;
      final isVisited   = node.isVisited;
      final isNew       = node.isNewlyInserted;
      final isHighlight = node.isHighlighted;
      // RB colour ring
      if (isRBTree) {
        final bool isRedNode = node.colour == NodeColour.red;
        final rbColor = isRedNode
            ? AppColors.red // Bright red for Red nodes
            : Colors.black;
        canvas.drawCircle(c, _r + 4, Paint()
          ..color = rbColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
          if (!isRedNode) {
            canvas.drawCircle(c, _r, Paint()..color = Colors.black.withValues(alpha: 0.8));
          }
      }

      // Outer glow
      if (isActive || isNew) {
        canvas.drawCircle(c, _r + 8, Paint()
          ..color = (isNew ? AppColors.green : AppColors.orange)
              .withValues(alpha: 0.18)
          ..maskFilter =
              const MaskFilter.blur(BlurStyle.normal, 14));
      }

      // Fill
      final fillColor = isActive
          ? AppColors.orange.withValues(alpha: 0.2)
          : isNew
              ? AppColors.green.withValues(alpha: 0.15)
              : isVisited
                  ? AppColors.indigo.withValues(alpha: 0.25)
                  : isHighlight
                      ? AppColors.indigoLight.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.04);
      canvas.drawCircle(c, _r, Paint()..color = fillColor);

      // Border
      Color borderColor;
      double borderW;
      if (isActive) {
        borderColor = AppColors.orange;
        borderW = 2.2;
      } else if (isNew) {
        borderColor = AppColors.green;
        borderW = 2.0;
      } else if (isVisited) {
        borderColor = AppColors.indigoLight.withValues(alpha: 0.75);
        borderW = 1.8;
      } else if (isHighlight) {
        borderColor = AppColors.indigo.withValues(alpha: 0.6);
        borderW = 1.5;
      } else {
        borderColor = Colors.white.withValues(alpha: 0.12);
        borderW = 1.0;
      }
      canvas.drawCircle(c, _r, Paint()
        ..color = borderColor
        ..strokeWidth = borderW
        ..style = PaintingStyle.stroke);

      // Value label
      _label(canvas, node.value.toString(), c,
          color: isActive
              ? AppColors.orange
              : isNew
                  ? AppColors.green
                  : isVisited
                      ? AppColors.indigoLight
                      : Colors.white.withValues(alpha: 0.55),
          fontSize: node.value > 99 ? 10.0 : 13.0,
          bold: true);

      // Balance factor badge (AVL)
      if (node.balanceFactor != null) {
        final bf = node.balanceFactor!;
        final bfColor = bf.abs() > 1
            ? AppColors.red
            : bf.abs() == 1
                ? AppColors.orange
                : AppColors.green;
        _label(canvas, bf.toString(),
            c + const Offset(_r + 2, -_r - 2),
            color: bfColor, fontSize: 9, bold: true,
            bgColor: AppColors.background);
      }
    }
  }

  void _label(Canvas canvas, String text, Offset center, {
    required Color color,
    double fontSize = 11,
    bool bold = false,
    Color? bgColor,
  }) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            letterSpacing: bold ? -0.3 : 0,
          )),
      textDirection: TextDirection.ltr,
    )..layout();

    if (bgColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: center,
              width: tp.width + 7,
              height: tp.height + 3),
          const Radius.circular(4)),
        Paint()..color = bgColor,
      );
    }
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => true;
}

// ─── Traversal order strip ────────────────────────────────────────────────────
class _TraversalOrderStrip extends StatelessWidget {
  final List<TreeNodeSnapshot> nodes;
  final List<int> visitedOrder;
  final int? activeNodeIndex;

  const _TraversalOrderStrip({
    required this.nodes,
    required this.visitedOrder,
    this.activeNodeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text('Order: ',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25),
                    fontSize: 10)),
            ...visitedOrder.asMap().entries.map((e) {
              final pos = e.key;
              final nodeIdx = e.value;
              final isLast = pos == visitedOrder.length - 1;
              if (nodeIdx >= nodes.length) return const SizedBox.shrink();
              final val = nodes[nodeIdx].value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.orange.withValues(alpha: 0.12)
                          : AppColors.indigo.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLast
                            ? AppColors.orange.withValues(alpha: 0.35)
                            : AppColors.indigo.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      val.toString(),
                      style: TextStyle(
                        color: isLast
                            ? AppColors.orange
                            : AppColors.indigoLight
                                .withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (pos < visitedOrder.length - 1)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: 8,
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────
class _TreeStatusBadge extends StatelessWidget {
  final TreeStepState step;
  const _TreeStatusBadge({required this.step});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;
    switch (step.stepType) {
      case TreeStepType.done:
        color = AppColors.green;
        icon = Icons.check_circle_rounded;
        label = 'Done';
      case TreeStepType.visited:
        color = AppColors.indigoLight;
        icon = Icons.check_rounded;
        label = 'Visited';
      case TreeStepType.visiting:
        color = AppColors.orange;
        icon = Icons.radio_button_checked_rounded;
        label = 'Visiting';
      case TreeStepType.inserting:
        color = AppColors.green;
        icon = Icons.add_circle_outline_rounded;
        label = 'Inserting';
      case TreeStepType.rotating:
        color = AppColors.orange;
        icon = Icons.rotate_right_rounded;
        label = 'Rotating';
      case TreeStepType.recolouring:
        color = AppColors.red;
        icon = Icons.palette_rounded;
        label = 'Recolouring';
      default:
        color = Colors.white54;
        icon = Icons.hourglass_empty_rounded;
        label = 'Ready';
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── Playback bar ─────────────────────────────────────────────────────────────
class _PlaybackBar extends ConsumerWidget {
  final bool isPlaying, canBack, canForward;
  final VoidCallback onPlayPause, onBack, onForward, onRestart;

  const _PlaybackBar({
    required this.isPlaying,
    required this.canBack,
    required this.canForward,
    required this.onPlayPause,
    required this.onBack,
    required this.onForward,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);
    final isNormal = (speed - 1.0).abs() < 0.01;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GlassPanel(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        borderRadius: 20,
        alpha: 0.07,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Speed row
            Row(children: [
              Icon(Icons.speed_rounded,
                  color: Colors.white.withValues(alpha: 0.28), size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.5,
                    activeTrackColor:
                        AppColors.indigoLight.withValues(alpha: 0.55),
                    inactiveTrackColor:
                        Colors.white.withValues(alpha: 0.06),
                    thumbColor: Colors.white,
                    overlayColor:
                        AppColors.indigo.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10),
                  ),
                  child: Slider(
                    value: speed,
                    min: 0.25,
                    max: 4.0,
                    divisions: 15,
                    onChanged: (v) =>
                        ref.read(playbackSpeedProvider.notifier).set(v),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref.read(playbackSpeedProvider.notifier).set(1.0);
                  Feedback.forTap(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isNormal
                        ? AppColors.indigo.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('${speed.toStringAsFixed(2)}x',
                      style: TextStyle(
                        color: isNormal
                            ? AppColors.indigoLight
                            : Colors.white.withValues(alpha: 0.4),
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: isNormal
                            ? FontWeight.bold
                            : FontWeight.normal,
                      )),
                ),
              ),
            ]),
            const SizedBox(height: 6),

            // Buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _btn(Icons.restart_alt_rounded, onRestart),
                const SizedBox(width: 4),
                _btn(Icons.skip_previous_rounded,
                    canBack ? onBack : null,
                    active: canBack),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.indigo,
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.indigo.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _btn(Icons.skip_next_rounded,
                    canForward ? onForward : null,
                    active: canForward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, {bool active = true}) =>
      IconButton(
        onPressed: onTap,
        icon: Icon(icon,
            color: active
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.18),
            size: 24),
        padding: EdgeInsets.zero,
        constraints:
            const BoxConstraints(minWidth: 40, minHeight: 40),
      );
}

// ─── Tree Editor Sheet ────────────────────────────────────────────────────────
class _TreeEditorSheet extends StatefulWidget {
  final List<int> values;
  final ValueChanged<int> onAddValue;
  final ValueChanged<int> onRemoveValue;

  const _TreeEditorSheet({
    required this.values,
    required this.onAddValue,
    required this.onRemoveValue,
  });

  @override
  State<_TreeEditorSheet> createState() => _TreeEditorSheetState();
}

class _TreeEditorSheetState extends State<_TreeEditorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _addCtrl = TextEditingController();
  String? _addError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  void _tryAdd() {
    final parsed = int.tryParse(_addCtrl.text.trim());
    if (parsed == null) {
      setState(() => _addError = 'Enter a valid integer');
      return;
    }
    if (widget.values.contains(parsed)) {
      setState(() => _addError = 'Value already in tree');
      return;
    }
    widget.onAddValue(parsed);
    setState(() { _addCtrl.clear(); _addError = null; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),

        // Title row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Tree Editor',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    shape: BoxShape.circle),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 16),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10)),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color:
                            AppColors.indigo.withValues(alpha: 0.3),
                        blurRadius: 8)
                  ]),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Add'), Tab(text: 'Remove')],
            ),
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_addTab(), _removeTab()],
          ),
        ),
      ]),
    );
  }

  Widget _addTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Enter a value to insert into the BST:',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _addError != null
                          ? AppColors.red.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.1))),
              child: Center(
                child: TextField(
                  controller: _addCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^-?\d*'))
                  ],
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. 45',
                    hintStyle: const TextStyle(
                        color: Colors.white24, fontSize: 13),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _tryAdd(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _tryAdd,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.indigo.withValues(alpha: 0.4))),
              child: const Center(
                  child: Text('Add',
                      style: TextStyle(
                          color: AppColors.indigoLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w700))),
            ),
          ),
        ]),
        if (_addError != null) ...[
          const SizedBox(height: 8),
          Text(_addError!,
              style: TextStyle(
                  color: AppColors.red.withValues(alpha: 0.8),
                  fontSize: 11)),
        ],
        const SizedBox(height: 20),
        Text('Current values:',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.28), fontSize: 11)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.values.map((v) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: AppColors.indigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.indigo.withValues(alpha: 0.2))),
            child: Text(v.toString(),
                style: const TextStyle(
                    color: AppColors.indigoLight, fontSize: 12)),
          )).toList(),
        ),
      ]),
    );
  }

  Widget _removeTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tap a value to remove it from the tree:',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.values.map((v) => GestureDetector(
            onTap: () {
              widget.onRemoveValue(v);
              setState(() {});
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.25))),
              child: Text(v.toString(),
                  style: TextStyle(
                      color: AppColors.red.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
          )).toList(),
        ),
      ]),
    );
  }
}