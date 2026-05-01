import '../models/graph_step_state.dart';

class DfsEngine {
  List<GraphStepState> generateSteps(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
    String startId,
  ) {
    final steps = <GraphStepState>[];
    final visited = <String>{};
    final stack = <String>[];
    final frontier = <String>{};

    // Build adjacency (undirected)
    final adj = <String, List<String>>{};
    for (final n in nodes) { adj[n.id] = []; }
    for (final e in edges) {
      adj[e.from]!.add(e.to);
      adj[e.to]!.add(e.from);
    }

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      stepType: GraphStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Initialise: push start node $startId onto stack',
    ));

    stack.add(startId);
    frontier.add(startId);

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      frontierNodes: Set.from(frontier),
      stepType: GraphStepType.visiting,
      activeCodeLine: 1,
      stepDescription: 'Push $startId → stack: [${stack.join(', ')}]',
    ));

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      frontier.remove(current);

      if (visited.contains(current)) continue;
      visited.add(current);

      steps.add(GraphStepState(
        nodes: nodes, edges: edges,
        currentNodeId: current,
        visitedNodes: Set.from(visited),
        frontierNodes: Set.from(frontier),
        stepType: GraphStepType.visiting,
        activeCodeLine: 2,
        stepDescription: 'Pop $current → mark visited',
      ));

      // Push neighbours in reverse so we explore in natural order
      final neighbours = List<String>.from(adj[current]!.reversed);
      for (final neighbour in neighbours) {
        if (!visited.contains(neighbour)) {
          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            currentNodeId: current,
            visitedNodes: Set.from(visited),
            frontierNodes: Set.from(frontier),
            activeEdgeFrom: current,
            activeEdgeTo: neighbour,
            stepType: GraphStepType.processing,
            activeCodeLine: 3,
            stepDescription: 'Push unvisited neighbour $neighbour',
          ));

          stack.add(neighbour);
          frontier.add(neighbour);

          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            currentNodeId: current,
            visitedNodes: Set.from(visited),
            frontierNodes: Set.from(frontier),
            activeEdgeFrom: current,
            activeEdgeTo: neighbour,
            stepType: GraphStepType.visiting,
            activeCodeLine: 4,
            stepDescription: 'Stack: [${stack.join(', ')}]',
          ));
        }
      }
    }

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      visitedNodes: Set.from(visited),
      stepType: GraphStepType.done,
      activeCodeLine: 5,
      stepDescription: 'DFS complete — all reachable nodes visited',
    ));

    return steps;
  }
}