import '../models/graph_step_state.dart';

class BfsEngine {
  List<GraphStepState> generateSteps(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
    String startId,
  ) {
    final steps = <GraphStepState>[];
    final visited = <String>{};
    final frontier = <String>{};
    final queue = <String>[];

    // Build adjacency (undirected)
    final adj = <String, List<String>>{};
    for (final n in nodes) { adj[n.id] = []; }
    for (final e in edges) {
      adj[e.from]!.add(e.to);
      adj[e.to]!.add(e.from);
    }

    // Step 0 — initial
    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      stepType: GraphStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Initialise: enqueue start node $startId',
    ));

    queue.add(startId);
    frontier.add(startId);

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      frontierNodes: Set.from(frontier),
      stepType: GraphStepType.visiting,
      activeCodeLine: 1,
      stepDescription: 'Enqueue $startId → queue: [${queue.join(', ')}]',
    ));

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      frontier.remove(current);
      visited.add(current);

      steps.add(GraphStepState(
        nodes: nodes, edges: edges,
        currentNodeId: current,
        visitedNodes: Set.from(visited),
        frontierNodes: Set.from(frontier),
        stepType: GraphStepType.visiting,
        activeCodeLine: 2,
        stepDescription: 'Dequeue $current → visiting',
      ));

      for (final neighbour in adj[current]!) {
        if (!visited.contains(neighbour) && !frontier.contains(neighbour)) {
          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            currentNodeId: current,
            visitedNodes: Set.from(visited),
            frontierNodes: Set.from(frontier),
            activeEdgeFrom: current,
            activeEdgeTo: neighbour,
            stepType: GraphStepType.processing,
            activeCodeLine: 3,
            stepDescription: 'Check neighbour $neighbour — not visited, enqueue',
          ));

          queue.add(neighbour);
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
            stepDescription: 'Enqueued $neighbour → queue: [${queue.join(', ')}]',
          ));
        } else {
          steps.add(GraphStepState(
            nodes: nodes, edges: edges,
            currentNodeId: current,
            visitedNodes: Set.from(visited),
            frontierNodes: Set.from(frontier),
            activeEdgeFrom: current,
            activeEdgeTo: neighbour,
            stepType: GraphStepType.processing,
            activeCodeLine: 3,
            stepDescription: 'Neighbour $neighbour already visited — skip',
          ));
        }
      }
    }

    steps.add(GraphStepState(
      nodes: nodes, edges: edges,
      visitedNodes: Set.from(visited),
      stepType: GraphStepType.done,
      activeCodeLine: 5,
      stepDescription: 'BFS complete — all reachable nodes visited',
    ));

    return steps;
  }
}