enum GraphStepType { idle, visiting, visited, processing, relaxing, found, done }

// ─── Graph data structures ────────────────────────────────────────────────────

class GraphNode {
  final String id;
  final double x; // 0.0–1.0 normalised
  final double y;

  const GraphNode({required this.id, required this.x, required this.y});

  GraphNode copyWith({String? id, double? x, double? y}) =>
      GraphNode(id: id ?? this.id, x: x ?? this.x, y: y ?? this.y);
}

class GraphEdge {
  final String from;
  final String to;
  final int weight;

  const GraphEdge({required this.from, required this.to, this.weight = 1});

  GraphEdge copyWith({String? from, String? to, int? weight}) =>
      GraphEdge(from: from ?? this.from, to: to ?? this.to, weight: weight ?? this.weight);
}

// ─── One visualisation frame ──────────────────────────────────────────────────

class GraphStepState {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  /// Node currently being dequeued / popped / relaxed
  final String? currentNodeId;

  /// Nodes already fully processed
  final Set<String> visitedNodes;

  /// Nodes in queue / frontier (BFS) or stack (DFS)
  final Set<String> frontierNodes;

  /// Edge being traversed this step  (from → to)
  final String? activeEdgeFrom;
  final String? activeEdgeTo;

  /// For Dijkstra / Bellman-Ford: current known distances
  final Map<String, int> distances;

  /// For path highlighting after completion
  final Set<String> pathNodes;
  final Set<String> pathEdgeFroms; // parallel list – "from" side of path edges

  final GraphStepType stepType;
  final int activeCodeLine;

  /// Human-readable explanation shown below pseudocode
  final String? stepDescription;

  const GraphStepState({
    required this.nodes,
    required this.edges,
    this.currentNodeId,
    this.visitedNodes = const {},
    this.frontierNodes = const {},
    this.activeEdgeFrom,
    this.activeEdgeTo,
    this.distances = const {},
    this.pathNodes = const {},
    this.pathEdgeFroms = const {},
    this.stepType = GraphStepType.idle,
    this.activeCodeLine = 0,
    this.stepDescription,
  });

  GraphStepState copyWith({
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    String? currentNodeId,
    Set<String>? visitedNodes,
    Set<String>? frontierNodes,
    String? activeEdgeFrom,
    String? activeEdgeTo,
    Map<String, int>? distances,
    Set<String>? pathNodes,
    Set<String>? pathEdgeFroms,
    GraphStepType? stepType,
    int? activeCodeLine,
    String? stepDescription,
  }) {
    return GraphStepState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      currentNodeId: currentNodeId,
      visitedNodes: visitedNodes ?? this.visitedNodes,
      frontierNodes: frontierNodes ?? this.frontierNodes,
      activeEdgeFrom: activeEdgeFrom,
      activeEdgeTo: activeEdgeTo,
      distances: distances ?? this.distances,
      pathNodes: pathNodes ?? this.pathNodes,
      pathEdgeFroms: pathEdgeFroms ?? this.pathEdgeFroms,
      stepType: stepType ?? this.stepType,
      activeCodeLine: activeCodeLine ?? this.activeCodeLine,
      stepDescription: stepDescription,
    );
  }
}

// ─── Default preset graph ─────────────────────────────────────────────────────

const defaultGraphNodes = [
  GraphNode(id: 'A', x: 0.20, y: 0.15),
  GraphNode(id: 'B', x: 0.70, y: 0.10),
  GraphNode(id: 'C', x: 0.10, y: 0.50),
  GraphNode(id: 'D', x: 0.50, y: 0.45),
  GraphNode(id: 'E', x: 0.85, y: 0.45),
  GraphNode(id: 'F', x: 0.30, y: 0.80),
  GraphNode(id: 'G', x: 0.75, y: 0.80),
];

const defaultGraphEdges = [
  GraphEdge(from: 'A', to: 'B', weight: 4),
  GraphEdge(from: 'A', to: 'C', weight: 2),
  GraphEdge(from: 'A', to: 'D', weight: 5),
  GraphEdge(from: 'B', to: 'D', weight: 1),
  GraphEdge(from: 'B', to: 'E', weight: 3),
  GraphEdge(from: 'C', to: 'F', weight: 6),
  GraphEdge(from: 'D', to: 'E', weight: 2),
  GraphEdge(from: 'D', to: 'F', weight: 4),
  GraphEdge(from: 'D', to: 'G', weight: 3),
  GraphEdge(from: 'E', to: 'G', weight: 2),
  GraphEdge(from: 'F', to: 'G', weight: 1),
];