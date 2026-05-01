import '../models/graph_step_state.dart';

class BellmanFordEngine {
  static const int _inf = 999999;

  List<GraphStepState> generateSteps(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
    String startId,
  ) {
    final steps = <GraphStepState>[];
    final n = nodes.length;

    // Directed edges (we treat undirected as two directed edges)
    final allEdges = <GraphEdge>[];
    for (final e in edges) {
      allEdges.add(e);
      allEdges.add(GraphEdge(from: e.to, to: e.from, weight: e.weight));
    }

    final dist = <String, int>{};
    for (final node in nodes) { dist[node.id] = _inf; }
    dist[startId] = 0;

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      distances: Map.from(dist),
      stepType: GraphStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Init: dist[$startId]=0, all others=∞',
    ));

    // Relax all edges n-1 times
    for (int i = 0; i < n - 1; i++) {
      bool anyUpdate = false;

      steps.add(GraphStepState(
        nodes: nodes, edges: edges,
        distances: Map.from(dist),
        stepType: GraphStepType.processing,
        activeCodeLine: 1,
        stepDescription: 'Iteration ${i + 1} of ${n - 1}: relax all edges',
      ));

      for (final e in allEdges) {
        if (dist[e.from]! == _inf) continue;

        final newDist = dist[e.from]! + e.weight;

        steps.add(GraphStepState(
          nodes: nodes, edges: edges,
          activeEdgeFrom: e.from,
          activeEdgeTo: e.to,
          distances: Map.from(dist),
          stepType: GraphStepType.relaxing,
          activeCodeLine: 2,
          stepDescription:
              'Check ${e.from}→${e.to}: ${dist[e.from]} + ${e.weight} = $newDist vs ${dist[e.to] == _inf ? '∞' : dist[e.to]}',
        ));

        if (newDist < dist[e.to]!) {
          dist[e.to] = newDist;
          anyUpdate = true;

          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            activeEdgeFrom: e.from,
            activeEdgeTo: e.to,
            distances: Map.from(dist),
            stepType: GraphStepType.relaxing,
            activeCodeLine: 3,
            stepDescription: 'Updated dist[${e.to}] = $newDist',
          ));
        }
      }

      if (!anyUpdate) {
        steps.add(GraphStepState(
          nodes: nodes, edges: edges,
          distances: Map.from(dist),
          stepType: GraphStepType.processing,
          activeCodeLine: 4,
          stepDescription: 'No updates in iteration ${i + 1} — early exit',
        ));
        break;
      }
    }

    // Negative cycle check
    bool hasNegCycle = false;
    for (final e in allEdges) {
      if (dist[e.from]! != _inf && dist[e.from]! + e.weight < dist[e.to]!) {
        hasNegCycle = true;
        break;
      }
    }

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      distances: Map.from(dist),
      stepType: GraphStepType.done,
      activeCodeLine: hasNegCycle ? 5 : 4,
      stepDescription: hasNegCycle
          ? '⚠ Negative-weight cycle detected!'
          : 'Bellman-Ford complete — shortest distances from $startId found',
    ));

    return steps;
  }
}