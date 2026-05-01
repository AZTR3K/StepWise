import '../models/tree_step_state.dart';

// ─── Internal mutable node used only during engine computation ────────────────
class _Node {
  final int value;
  _Node? left;
  _Node? right;
  _Node(this.value);
}

_Node? _insert(_Node? node, int value) {
  if (node == null) return _Node(value);
  if (value < node.value) {
    node.left = _insert(node.left, value);
  } else if (value > node.value) {
    node.right = _insert(node.right, value);
  }
  return node;
}

class InorderEngine {
  List<TreeStepState> generateSteps(List<int> values) {
    final steps = <TreeStepState>[];

    // Build BST
    _Node? root;
    for (final v in values) {
      root = _insert(root, v);
    }
    if (root == null) return steps;

    // Flatten tree into snapshot list
    final nodeList = <_Node>[];
    _flatten(root, nodeList);
    final indexMap = {for (int i = 0; i < nodeList.length; i++) nodeList[i]: i};
    final rootIdx = indexMap[root]!;

    List<TreeNodeSnapshot> _snap({int? active, Set<int>? visited}) {
      return nodeList.asMap().entries.map((e) {
        final n = e.value;
        final idx = e.key;
        return TreeNodeSnapshot(
          value: n.value,
          left: n.left != null ? indexMap[n.left] : null,
          right: n.right != null ? indexMap[n.right] : null,
          isActive: idx == active,
          isVisited: visited?.contains(idx) ?? false,
        );
      }).toList();
    }

    // Initial state
    steps.add(TreeStepState(
      nodes: _snap(),
      rootIndex: rootIdx,
      stepType: TreeStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Starting in-order traversal (Left → Root → Right)',
    ));

    final visited = <int>{};
    final visitedOrder = <int>[];

    void inorder(_Node? node) {
      if (node == null) return;
      final idx = indexMap[node]!;

      // Go left
      steps.add(TreeStepState(
        nodes: _snap(active: idx, visited: visited),
        rootIndex: rootIdx,
        stepType: TreeStepType.visiting,
        activeCodeLine: 1,
        activeNodeIndex: idx,
        visitedOrder: List.from(visitedOrder),
        stepDescription: 'At node ${node.value} — recurse left first',
      ));
      inorder(node.left);

      // Visit this node
      visited.add(idx);
      visitedOrder.add(idx);
      steps.add(TreeStepState(
        nodes: _snap(active: idx, visited: visited),
        rootIndex: rootIdx,
        stepType: TreeStepType.visited,
        activeCodeLine: 2,
        activeNodeIndex: idx,
        visitedOrder: List.from(visitedOrder),
        stepDescription: 'Visit ${node.value}  →  order so far: ${visitedOrder.map((i) => nodeList[i].value).join(', ')}',
      ));

      // Go right
      steps.add(TreeStepState(
        nodes: _snap(active: idx, visited: visited),
        rootIndex: rootIdx,
        stepType: TreeStepType.visiting,
        activeCodeLine: 3,
        activeNodeIndex: idx,
        visitedOrder: List.from(visitedOrder),
        stepDescription: 'At node ${node.value} — recurse right',
      ));
      inorder(node.right);
    }

    inorder(root);

    steps.add(TreeStepState(
      nodes: _snap(visited: visited),
      rootIndex: rootIdx,
      stepType: TreeStepType.done,
      activeCodeLine: 4,
      visitedOrder: List.from(visitedOrder),
      stepDescription:
          'In-order complete: ${visitedOrder.map((i) => nodeList[i].value).join(' → ')}',
    ));

    return steps;
  }

  void _flatten(_Node? node, List<_Node> list) {
    if (node == null) return;
    _flatten(node.left, list);
    list.add(node);
    _flatten(node.right, list);
  }
}