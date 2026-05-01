import '../models/graph_step_state.dart';

class DijkstraEngine {
  static const int _inf = 999999;

  List<GraphStepState> generateSteps(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
    String startId,
  ) {
    final steps = <GraphStepState>[];
    final visited = <String>{};

    // Build weighted adjacency (undirected)
    final adj = <String, List<(String, int)>>{};
    for (final n in nodes) { adj[n.id] = []; }
    for (final e in edges) {
      adj[e.from]!.add((e.to, e.weight));
      adj[e.to]!.add((e.from, e.weight));
    }

    // Distance map
    final dist = <String, int>{};
    for (final n in nodes) { dist[n.id] = _inf; }
    dist[startId] = 0;

    // Previous map for path reconstruction
    final prev = <String, String?>{};
    final unvisited = nodes.map((n) => n.id).toSet();

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      distances: Map.from(dist),
      stepType: GraphStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Init: dist[$startId]=0, all others=∞',
    ));

    while (unvisited.isNotEmpty) {
      // Pick unvisited node with smallest distance
      String? current;
      int minDist = _inf + 1;
      for (final id in unvisited) {
        if (dist[id]! < minDist) {
          minDist = dist[id]!;
          current = id;
        }
      }

      if (current == null) break; // remaining nodes unreachable

      unvisited.remove(current);
      visited.add(current);

      steps.add(GraphStepState(
        nodes: nodes, edges: edges,
        currentNodeId: current,
        visitedNodes: Set.from(visited),
        frontierNodes: unvisited,
        distances: Map.from(dist),
        stepType: GraphStepType.visiting,
        activeCodeLine: 1,
        stepDescription: 'Pick min-dist node: $current (dist=${dist[current]})',
      ));

      for (final (neighbour, weight) in adj[current]!) {
        if (visited.contains(neighbour)) continue;

        final newDist = dist[current]! + weight;

        steps.add(GraphStepState(
          nodes: nodes, edges: edges,
          currentNodeId: current,
          visitedNodes: Set.from(visited),
          frontierNodes: unvisited,
          activeEdgeFrom: current,
          activeEdgeTo: neighbour,
          distances: Map.from(dist),
          stepType: GraphStepType.relaxing,
          activeCodeLine: 2,
          stepDescription:
              'Relax edge $current→$neighbour: ${dist[current]} + $weight = $newDist vs ${dist[neighbour] == _inf ? '∞' : dist[neighbour]}',
        ));

        if (newDist < dist[neighbour]!) {
          dist[neighbour] = newDist;
          prev[neighbour] = current;

          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            currentNodeId: current,
            visitedNodes: Set.from(visited),
            frontierNodes: unvisited,
            activeEdgeFrom: current,
            activeEdgeTo: neighbour,
            distances: Map.from(dist),
            stepType: GraphStepType.relaxing,
            activeCodeLine: 3,
            stepDescription: 'Updated dist[$neighbour] = $newDist',
          ));
        }
      }
    }

    // Reconstruct shortest path from start (just highlight all reached nodes)
    final pathNodes = <String>{};
    final pathEdgeFroms = <String>{};
    for (final n in nodes) {
      if (dist[n.id]! < _inf) pathNodes.add(n.id);
    }
    for (final entry in prev.entries) {
      if (entry.value != null) pathEdgeFroms.add(entry.value!);
    }

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      visitedNodes: Set.from(visited),
      distances: Map.from(dist),
      pathNodes: pathNodes,
      pathEdgeFroms: pathEdgeFroms,
      stepType: GraphStepType.done,
      activeCodeLine: 4,
      stepDescription: 'Dijkstra complete — shortest distances from $startId found',
    ));

    return steps;
  }
}