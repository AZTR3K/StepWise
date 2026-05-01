import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/engines/bfs_engine.dart';
import '../../domain/engines/dfs_engine.dart';
import '../../domain/engines/dijkstra_engine.dart';
import '../../domain/engines/bellman_ford_engine.dart';
import '../../domain/models/graph_step_state.dart';
import '../theme/app_colors.dart';
import '../state/visualizer_state.dart';
import '../widgets/glass_panel.dart';

// ─── Pseudocode ───────────────────────────────────────────────────────────────
const _pseudoCodeMap = {
  'BFS': [
    "1. enqueue(start); mark visited",
    "2. while queue not empty:",
    "3.   node = dequeue()",
    "4.   for each neighbour:",
    "5.     if not visited: enqueue",
    "6. done",
  ],
  'DFS': [
    "1. push(start)",
    "2. while stack not empty:",
    "3.   node = pop()",
    "4.   if not visited: mark visited",
    "5.   for each neighbour:",
    "6.     if not visited: push",
    "7. done",
  ],
  'Dijkstra': [
    "1. dist[start]=0, all others=∞",
    "2. pick min-dist unvisited node",
    "3. for each neighbour:",
    "4.   newDist = dist[u] + weight",
    "5.   if newDist < dist[v]: update",
    "6. done",
  ],
  'Bellman-Ford': [
    "1. dist[start]=0, all others=∞",
    "2. repeat V-1 times:",
    "3.   for each edge (u→v, w):",
    "4.     if dist[u]+w < dist[v]: update",
    "5.   if no update: break early",
    "6. check for negative cycles",
    "7. done",
  ],
};

// ─── Layout helpers ───────────────────────────────────────────────────────────
List<Offset> _computeLayout(int count) {
  if (count == 0) return [];
  if (count == 1) return [const Offset(0.5, 0.5)];
  final positions = <Offset>[];
  final primaryCount = math.min(count, 6);
  for (int i = 0; i < primaryCount; i++) {
    final angle = (2 * math.pi * i / primaryCount) - math.pi / 2;
    positions.add(Offset(0.5 + 0.36 * math.cos(angle), 0.5 + 0.36 * math.sin(angle)));
  }
  if (count > 6) {
    final secondaryCount = count - 6;
    for (int i = 0; i < secondaryCount; i++) {
      final angle = (2 * math.pi * i / secondaryCount) - math.pi / 2 + math.pi / secondaryCount;
      positions.add(Offset(0.5 + 0.17 * math.cos(angle), 0.5 + 0.17 * math.sin(angle)));
    }
  }
  return positions;
}

List<GraphNode> _redistributeNodes(List<GraphNode> nodes) {
  final positions = _computeLayout(nodes.length);
  return List.generate(nodes.length, (i) =>
    GraphNode(id: nodes[i].id, x: positions[i].dx, y: positions[i].dy));
}

// ─── Step generator ───────────────────────────────────────────────────────────
List<GraphStepState> _generateSteps(
  String name, List<GraphNode> nodes, List<GraphEdge> edges, String startId) {
  switch (name) {
    case 'DFS':         return DfsEngine().generateSteps(nodes, edges, startId);
    case 'Dijkstra':    return DijkstraEngine().generateSteps(nodes, edges, startId);
    case 'Bellman-Ford':return BellmanFordEngine().generateSteps(nodes, edges, startId);
    default:            return BfsEngine().generateSteps(nodes, edges, startId);
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class GraphVisualizerScreen extends ConsumerStatefulWidget {
  final String algorithmName;
  const GraphVisualizerScreen({super.key, required this.algorithmName});

  @override
  ConsumerState<GraphVisualizerScreen> createState() => _GraphVisualizerScreenState();
}

class _GraphVisualizerScreenState extends ConsumerState<GraphVisualizerScreen>
    with TickerProviderStateMixin {

  late List<GraphNode> _nodes;
  late List<GraphEdge> _edges;
  late String _startNodeId;
  late List<GraphStepState> _steps;
  int _currentStepIndex = 0;
  bool _isPlaying = false;

  bool _showPseudocode = true;
  late AnimationController _pseudoController;
  late Animation<double> _pseudoAnimation;

  final _pseudoScrollController = ScrollController();
  final _lineKeys = <int, GlobalKey>{};
  bool _userIsScrolling = false;
  Timer? _scrollDebounce;
  String? _draggingNodeId;

  // ── Name normalisation ────────────────────────────────────────────────────
  String get _normalisedName {
    final n = widget.algorithmName;
    if (n.contains('BFS') || n.toLowerCase().contains('breadth')) return 'BFS';
    if (n.contains('DFS') || n.toLowerCase().contains('depth'))   return 'DFS';
    if (n.toLowerCase().contains('dijkstra'))                      return 'Dijkstra';
    if (n.toLowerCase().contains('bellman'))                       return 'Bellman-Ford';
    return n;
  }

  List<String> get _pseudoCode =>
      _pseudoCodeMap[_normalisedName] ?? _pseudoCodeMap['BFS']!;

  bool get _isWeightedAlgo =>
      _normalisedName == 'Dijkstra' || _normalisedName == 'Bellman-Ford';

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _nodes = _redistributeNodes(List.from(defaultGraphNodes));
    _edges = List.from(defaultGraphEdges);
    _startNodeId = _nodes.first.id;
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
    _steps = _generateSteps(_normalisedName, _nodes, _edges, _startNodeId);
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
      setState(() { _currentStepIndex--; _isPlaying = false; });
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
          duration: Duration(milliseconds: (300 / speed).round().clamp(50, 600)),
          curve: Curves.easeInOutCubic,
          alignment: 0.5);
    });
  }

  // ── Graph editing ─────────────────────────────────────────────────────────
  void _setStartNode(String id) =>
      setState(() { _startNodeId = id; _rebuildSteps(); });

  void _addNode(String id) {
    if (_nodes.any((n) => n.id == id)) return;
    setState(() {
      _nodes = _redistributeNodes([..._nodes, GraphNode(id: id, x: 0.5, y: 0.5)]);
      _rebuildSteps();
    });
  }

  void _removeNode(String id) {
    setState(() {
      _nodes = _redistributeNodes(_nodes.where((n) => n.id != id).toList());
      _edges = _edges.where((e) => e.from != id && e.to != id).toList();
      if (_startNodeId == id && _nodes.isNotEmpty) _startNodeId = _nodes.first.id;
      _rebuildSteps();
    });
  }

  void _addEdge(String from, String to, int weight) {
    final exists = _edges.any((e) =>
        (e.from == from && e.to == to) || (e.from == to && e.to == from));
    if (exists || from == to) return;
    setState(() {
      _edges = [..._edges, GraphEdge(from: from, to: to, weight: weight)];
      _rebuildSteps();
    });
  }

  void _removeEdge(String from, String to) {
    setState(() {
      _edges = _edges.where((e) =>
          !((e.from == from && e.to == to) ||
            (e.from == to   && e.to == from))).toList();
      _rebuildSteps();
    });
  }

  void _resetGraph() {
    setState(() {
      _nodes = _redistributeNodes(List.from(defaultGraphNodes));
      _edges = List.from(defaultGraphEdges);
      _startNodeId = _nodes.first.id;
      _rebuildSteps();
    });
  }

  // ── Drag ──────────────────────────────────────────────────────────────────
  String? _hitTestNode(Offset pos, Size size) {
    for (final n in _nodes) {
      if ((pos - Offset(n.x * size.width, n.y * size.height)).distance < 28) {
        return n.id;
      }
    }
    return null;
  }

  void _onDragUpdate(Offset localPos, Size size) {
    if (_draggingNodeId == null) return;
    setState(() {
      _nodes = _nodes.map((n) => n.id != _draggingNodeId ? n :
        n.copyWith(
          x: (localPos.dx / size.width).clamp(0.06, 0.94),
          y: (localPos.dy / size.height).clamp(0.06, 0.94),
        )).toList();
      _steps = _generateSteps(_normalisedName, _nodes, _edges, _startNodeId);
    });
  }

  // ── Editor sheet ──────────────────────────────────────────────────────────
  void _openEditorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GraphEditorSheet(
        nodes: _nodes,
        edges: _edges,
        startNodeId: _startNodeId,
        isWeighted: _isWeightedAlgo,
        onSetStart:   (id) { Navigator.pop(context); _setStartNode(id); },
        onAddNode:    (id) { _addNode(id); },
        onRemoveNode: (id) { Navigator.pop(context); _removeNode(id); },
        onAddEdge:    _addEdge,
        onRemoveEdge: _removeEdge,
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final progress = _steps.length <= 1
        ? 0.0
        : _currentStepIndex / (_steps.length - 1);

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
            style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        actions: [
          // Pseudocode toggle
          IconButton(
            onPressed: () {
              setState(() => _showPseudocode = !_showPseudocode);
              _showPseudocode ? _pseudoController.forward() : _pseudoController.reverse();
            },
            icon: Icon(
              _showPseudocode ? Icons.code_off_rounded : Icons.code_rounded,
              color: _showPseudocode ? AppColors.indigoLight : Colors.white38,
              size: 20,
            ),
          ),
          // Graph editor
          IconButton(
            onPressed: _openEditorSheet,
            icon: Icon(Icons.tune_rounded, color: Colors.white.withValues(alpha: 0.65), size: 20),
            tooltip: 'Edit graph',
          ),
          // Reset
          IconButton(
            onPressed: _resetGraph,
            icon: Icon(Icons.refresh_rounded, color: Colors.white.withValues(alpha: 0.4), size: 20),
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
                  _GraphStatusBadge(step: step),
                  const SizedBox(width: 10),
                  if (step.stepDescription != null)
                    Expanded(
                      child: Text(
                        step.stepDescription!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  borderRadius: 14,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is UserScrollNotification) {
                        _userIsScrolling = true;
                        _scrollDebounce?.cancel();
                        _scrollDebounce = Timer(const Duration(seconds: 2),
                            () { if (mounted) _userIsScrolling = false; });
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _pseudoScrollController,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _pseudoCode.asMap().entries.map((entry) {
                          final lineIdx = entry.key;
                          final isActive = lineIdx == step.activeCodeLine;
                          final key = _lineKeys.putIfAbsent(lineIdx, () => GlobalKey());
                          return KeyedSubtree(
                            key: key,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.indigo.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(entry.value,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11.5,
                                  color: isActive ? AppColors.indigoLight : Colors.white38,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                )),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Graph canvas ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) =>
                        _draggingNodeId = _hitTestNode(d.localPosition, size),
                    onPanUpdate: (d) => _onDragUpdate(d.localPosition, size),
                    onPanEnd: (_) => setState(() => _draggingNodeId = null),
                    child: CustomPaint(
                      size: size,
                      painter: _GraphPainter(
                        step: step,
                        startNodeId: _startNodeId,
                        isWeighted: _isWeightedAlgo,
                        draggingNodeId: _draggingNodeId,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Distance table (Dijkstra / Bellman-Ford) ─────────────────────
            if (_isWeightedAlgo && step.distances.isNotEmpty)
              _DistanceTable(distances: step.distances, currentId: step.currentNodeId),

            // ── Progress bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation(AppColors.indigo),
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

// ─── Graph Painter ────────────────────────────────────────────────────────────
class _GraphPainter extends CustomPainter {
  final GraphStepState step;
  final String startNodeId;
  final bool isWeighted;
  final String? draggingNodeId;
  static const double _r = 22.0;

  const _GraphPainter({
    required this.step,
    required this.startNodeId,
    required this.isWeighted,
    this.draggingNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in step.nodes) n.id: n};
    _drawEdges(canvas, size, nodeMap);
    _drawNodes(canvas, size);
  }

  void _drawEdges(Canvas canvas, Size size, Map<String, GraphNode> nodeMap) {
    for (final edge in step.edges) {
      final from = nodeMap[edge.from];
      final to   = nodeMap[edge.to];
      if (from == null || to == null) continue;

      final p1 = Offset(from.x * size.width, from.y * size.height);
      final p2 = Offset(to.x   * size.width, to.y   * size.height);

      final isActive =
          (edge.from == step.activeEdgeFrom && edge.to == step.activeEdgeTo) ||
          (edge.to == step.activeEdgeFrom && edge.from == step.activeEdgeTo);
      final bothVisited = step.visitedNodes.contains(edge.from) &&
          step.visitedNodes.contains(edge.to);

      Color edgeColor;
      double strokeW;
      if (isActive)        { edgeColor = AppColors.orange; strokeW = 2.5; }
      else if (bothVisited){ edgeColor = AppColors.indigo.withValues(alpha: 0.5); strokeW = 1.5; }
      else                 { edgeColor = Colors.white.withValues(alpha: 0.09); strokeW = 1.0; }

      // Active glow
      if (isActive) {
        canvas.drawLine(p1, p2, Paint()
          ..color = AppColors.orange.withValues(alpha: 0.18)
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }

      // Shorten so it doesn't overlap the node circles
      final dir  = p2 - p1;
      final dist = dir.distance;
      if (dist < _r * 2.5) continue;
      final unit  = dir / dist;
      final start = p1 + unit * (_r + 3);
      final end   = p2 - unit * (_r + 3);

      canvas.drawLine(start, end, Paint()
        ..color = edgeColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);

      // Weight label
      if (isWeighted) {
        final mid = (p1 + p2) / 2;
        _label(canvas, edge.weight.toString(), mid,
            color: isActive ? AppColors.orange : Colors.white.withValues(alpha: 0.32),
            fontSize: 9, bgColor: AppColors.background);
      }
    }
  }

  void _drawNodes(Canvas canvas, Size size) {
    for (final node in step.nodes) {
      final c = Offset(node.x * size.width, node.y * size.height);
      final isStart    = node.id == startNodeId;
      final isVisited  = step.visitedNodes.contains(node.id);
      final isCurrent  = node.id == step.currentNodeId;
      final isFrontier = step.frontierNodes.contains(node.id);
      final isDragging = node.id == draggingNodeId;

      // Outer glow
      if (isCurrent || isStart || isDragging) {
        canvas.drawCircle(c, _r + 8, Paint()
          ..color = (isCurrent ? AppColors.orange : AppColors.indigo)
              .withValues(alpha: isDragging ? 0.08 : 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      }

      // Start ring
      if (isStart) {
        canvas.drawCircle(c, _r + 5, Paint()
          ..color = AppColors.indigo.withValues(alpha: 0.3)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);
      }

      // Fill
      final fillColor = isCurrent  ? AppColors.orange.withValues(alpha: 0.2)
          : isVisited              ? AppColors.indigo.withValues(alpha: 0.25)
          : isFrontier             ? AppColors.indigo.withValues(alpha: 0.08)
          :                          Colors.white.withValues(alpha: 0.04);
      canvas.drawCircle(c, _r, Paint()..color = fillColor);

      // Border
      Color borderColor;
      double borderW;
      if (isCurrent)       { borderColor = AppColors.orange;                         borderW = 2.2; }
      else if (isVisited)  { borderColor = AppColors.indigoLight.withValues(alpha:0.75); borderW = 1.8; }
      else if (isFrontier) { borderColor = AppColors.indigo.withValues(alpha: 0.6);  borderW = 1.5; }
      else if (isStart)    { borderColor = AppColors.indigo.withValues(alpha: 0.5);  borderW = 1.5; }
      else                 { borderColor = Colors.white.withValues(alpha: 0.1);      borderW = 1.0; }
      canvas.drawCircle(c, _r, Paint()
        ..color = borderColor
        ..strokeWidth = borderW
        ..style = PaintingStyle.stroke);

      // Node label
      _label(canvas, node.id, c,
          color: isCurrent  ? AppColors.orange
              : isVisited   ? AppColors.indigoLight
              : isStart     ? Colors.white.withValues(alpha: 0.9)
              :               Colors.white.withValues(alpha: 0.5),
          fontSize: 13, bold: true);
    }
  }

  void _label(Canvas canvas, String text, Offset center, {
    required Color color, double fontSize = 11, bool bold = false, Color? bgColor}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        color: color, fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        letterSpacing: bold ? -0.3 : 0,
      )),
      textDirection: TextDirection.ltr,
    )..layout();

    if (bgColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: tp.width + 7, height: tp.height + 3),
          const Radius.circular(4)),
        Paint()..color = bgColor);
    }
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) => true;
}

// ─── Playback bar ─────────────────────────────────────────────────────────────
class _PlaybackBar extends ConsumerWidget {
  final bool isPlaying, canBack, canForward;
  final VoidCallback onPlayPause, onBack, onForward, onRestart;

  const _PlaybackBar({
    required this.isPlaying, required this.canBack, required this.canForward,
    required this.onPlayPause, required this.onBack,
    required this.onForward,  required this.onRestart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed    = ref.watch(playbackSpeedProvider);
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
              Icon(Icons.speed_rounded, color: Colors.white.withValues(alpha: 0.28), size: 13),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.5,
                    activeTrackColor: AppColors.indigoLight.withValues(alpha: 0.55),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.06),
                    thumbColor: Colors.white,
                    overlayColor: AppColors.indigo.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  ),
                  child: Slider(
                    value: speed, min: 0.25, max: 4.0, divisions: 15,
                    onChanged: (v) => ref.read(playbackSpeedProvider.notifier).set(v),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () { ref.read(playbackSpeedProvider.notifier).set(1.0); Feedback.forTap(context); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 24, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isNormal ? AppColors.indigo.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('${speed.toStringAsFixed(2)}x',
                      style: TextStyle(
                        color: isNormal ? AppColors.indigoLight : Colors.white.withValues(alpha: 0.4),
                        fontFamily: 'monospace', fontSize: 10,
                        fontWeight: isNormal ? FontWeight.bold : FontWeight.normal,
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
                _btn(Icons.skip_previous_rounded, canBack ? onBack : null, active: canBack),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onPlayPause,
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.indigo,
                      boxShadow: [BoxShadow(
                        color: AppColors.indigo.withValues(alpha: 0.45),
                        blurRadius: 18, offset: const Offset(0, 4))],
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 8),
                _btn(Icons.skip_next_rounded, canForward ? onForward : null, active: canForward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, {bool active = true}) => IconButton(
    onPressed: onTap,
    icon: Icon(icon,
        color: active ? Colors.white.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.18),
        size: 24),
    padding: EdgeInsets.zero,
    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
  );
}

// ─── Distance table ───────────────────────────────────────────────────────────
class _DistanceTable extends StatelessWidget {
  final Map<String, int> distances;
  final String? currentId;
  static const int _inf = 999999;

  const _DistanceTable({required this.distances, this.currentId});

  @override
  Widget build(BuildContext context) {
    final sorted = distances.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sorted.map((e) {
            final isCurrent = e.key == currentId;
            final isInf     = e.value >= _inf;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.orange.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.orange.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.07),
                ),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(e.key, style: TextStyle(
                  color: isCurrent ? AppColors.orange : AppColors.indigoLight.withValues(alpha: 0.7),
                  fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 1),
                Text(isInf ? '∞' : e.value.toString(), style: TextStyle(
                  color: isInf ? Colors.white.withValues(alpha: 0.2)
                      : isCurrent ? AppColors.orange : Colors.white.withValues(alpha: 0.75),
                  fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────
class _GraphStatusBadge extends StatelessWidget {
  final GraphStepState step;
  const _GraphStatusBadge({required this.step});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;
    switch (step.stepType) {
      case GraphStepType.done:
        color = AppColors.green; icon = Icons.check_circle_rounded; label = 'Done';
      case GraphStepType.visiting:
        color = AppColors.orange; icon = Icons.radio_button_checked_rounded; label = 'Visiting';
      case GraphStepType.relaxing:
        color = AppColors.indigoLight; icon = Icons.bolt_rounded; label = 'Relaxing';
      case GraphStepType.processing:
        color = AppColors.indigo; icon = Icons.loop_rounded; label = 'Processing';
      default:
        color = Colors.white54; icon = Icons.hourglass_empty_rounded; label = 'Ready';
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
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─── Graph Editor Sheet ───────────────────────────────────────────────────────
class _GraphEditorSheet extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String startNodeId;
  final bool isWeighted;
  final ValueChanged<String> onSetStart;
  final ValueChanged<String> onAddNode;
  final ValueChanged<String> onRemoveNode;
  final Function(String, String, int) onAddEdge;
  final Function(String, String) onRemoveEdge;

  const _GraphEditorSheet({
    required this.nodes, required this.edges,
    required this.startNodeId, required this.isWeighted,
    required this.onSetStart, required this.onAddNode,
    required this.onRemoveNode, required this.onAddEdge,
    required this.onRemoveEdge,
  });

  @override
  State<_GraphEditorSheet> createState() => _GraphEditorSheetState();
}

class _GraphEditorSheetState extends State<_GraphEditorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String? _edgeFrom;
  String? _edgeTo;
  final _weightCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(children: [
        // Handle bar
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),

        // Title row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Graph Editor',
                style: TextStyle(color: Colors.white, fontSize: 17,
                    fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle),
                child: Icon(Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.45), size: 16),
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
                boxShadow: [BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.3), blurRadius: 8)]),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Start'), Tab(text: 'Nodes'), Tab(text: 'Edges')],
            ),
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_startTab(), _nodesTab(), _edgesTab()],
          ),
        ),
      ]),
    );
  }

  // ── Start tab ──────────────────────────────────────────────────────────────
  Widget _startTab() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tap a node to set it as the algorithm start point.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
      const SizedBox(height: 18),
      Wrap(
        spacing: 10, runSpacing: 10,
        children: widget.nodes.map((n) {
          final sel = n.id == widget.startNodeId;
          return GestureDetector(
            onTap: () => widget.onSetStart(n.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? AppColors.indigo : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: sel ? AppColors.indigoLight : Colors.white.withValues(alpha: 0.1),
                  width: sel ? 2 : 1),
                boxShadow: sel ? [BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.5), blurRadius: 14)] : [],
              ),
              child: Center(child: Text(n.id,
                  style: TextStyle(
                    color: sel ? Colors.white : Colors.white.withValues(alpha: 0.45),
                    fontSize: 15, fontWeight: FontWeight.bold))),
            ),
          );
        }).toList(),
      ),
    ]),
  );

  // ── Nodes tab ─────────────────────────────────────────────────────────────
  Widget _nodesTab() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final existing  = widget.nodes.map((n) => n.id).toSet();
    final available = letters.split('').where((l) => !existing.contains(l)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add node', style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 10),
        available.isNotEmpty
            ? Wrap(
                spacing: 8, runSpacing: 8,
                children: available.take(12).map((l) => GestureDetector(
                  onTap: () { widget.onAddNode(l); setState(() {}); },
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.indigo.withValues(alpha: 0.3))),
                    child: Center(child: Text(l, style: const TextStyle(
                      color: AppColors.indigoLight, fontSize: 13, fontWeight: FontWeight.bold))),
                  ),
                )).toList())
            : Text('Maximum nodes reached.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 12)),

        const SizedBox(height: 22),
        Divider(color: Colors.white.withValues(alpha: 0.07)),
        const SizedBox(height: 14),

        Text('Remove node  (also removes its edges)',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: widget.nodes.map((n) => GestureDetector(
            onTap: () => widget.onRemoveNode(n.id),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.red.withValues(alpha: 0.25))),
              child: Center(child: Text(n.id, style: TextStyle(
                color: AppColors.red.withValues(alpha: 0.8),
                fontSize: 13, fontWeight: FontWeight.bold))),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  // ── Edges tab ─────────────────────────────────────────────────────────────
  Widget _edgesTab() {
    final nodeIds = widget.nodes.map((n) => n.id).toList();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Add edge', style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 10),

        // Add-edge row
        Row(children: [
          _pill('From', _edgeFrom, nodeIds, (v) => setState(() => _edgeFrom = v)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.22), size: 15)),
          _pill('To', _edgeTo, nodeIds, (v) => setState(() => _edgeTo = v)),
          if (widget.isWeighted) ...[
            const SizedBox(width: 8),
            SizedBox(width: 52, child: _field(_weightCtrl, 'W', numeric: true)),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_edgeFrom == null || _edgeTo == null) return;
              final w = int.tryParse(_weightCtrl.text.trim()) ?? 1;
              widget.onAddEdge(_edgeFrom!, _edgeTo!, w);
              setState(() { _edgeFrom = null; _edgeTo = null; _weightCtrl.text = '1'; });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.indigo.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.indigo.withValues(alpha: 0.38))),
              child: const Text('Add', style: TextStyle(
                  color: AppColors.indigoLight, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),

        const SizedBox(height: 20),
        Divider(color: Colors.white.withValues(alpha: 0.07)),
        const SizedBox(height: 12),
        Text('Tap an edge to remove it', style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38), fontSize: 12)),
        const SizedBox(height: 10),

        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 2.6,
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            children: widget.edges.map((e) => GestureDetector(
              onTap: () { widget.onRemoveEdge(e.from, e.to); setState(() {}); },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red.withValues(alpha: 0.18))),
                child: Text(
                  widget.isWeighted
                      ? '${e.from}→${e.to}  ${e.weight}'
                      : '${e.from}↔${e.to}',
                  style: TextStyle(
                    color: AppColors.red.withValues(alpha: 0.65),
                    fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            )).toList(),
          ),
        ),
      ]),
    );
  }

  Widget _pill(String hint, String? value, List<String> options, ValueChanged<String?> cb) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white30, fontSize: 12)),
          dropdownColor: AppColors.cardBg,
          iconSize: 14, iconEnabledColor: Colors.white30,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          isDense: true,
          items: options.map((id) => DropdownMenuItem(value: id, child: Text(id))).toList(),
          onChanged: cb,
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {bool numeric = false}) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
      child: Center(
        child: TextField(
          controller: ctrl,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          inputFormatters: numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8)),
        ),
      ),
    );
  }
}