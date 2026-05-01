import '../models/tree_step_state.dart';

// ─── Internal mutable node used only during engine computation ────────────────
class _Node {
  final int value;
  _Node? left;
  _Node? right;
  _Node(this.value);
}

class PreorderEngine {
  // Helper to insert values and build a standard BST
  _Node? _insert(_Node? node, int value) {
    if (node == null) return _Node(value);
    if (value < node.value) {
      node.left = _insert(node.left, value);
    } else if (value > node.value) {
      node.right = _insert(node.right, value);
    }
    return node;
  }

  // Flatten helper to map nodes to fixed indices for the UI
  void _flatten(_Node? node, List<_Node> list) {
    if (node == null) return;
    list.add(node); // Pre-order flattening (Root first)
    _flatten(node.left, list);
    _flatten(node.right, list);
  }

  List<TreeStepState> generateSteps(List<int> values) {
    final steps = <TreeStepState>[];

    // 1. Build the Binary Search Tree
    _Node? root;
    for (final v in values) {
      root = _insert(root, v);
    }
    if (root == null) return steps;

    // 2. Map nodes to indices so the UI has stable references
    final nodeList = <_Node>[];
    _flatten(root, nodeList);
    final indexMap = {for (int i = 0; i < nodeList.length; i++) nodeList[i]: i};
    final rootIdx = indexMap[root]!;

    // 3. Snapshot helper function
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

    // 4. Initial State
    steps.add(TreeStepState(
      nodes: _snap(),
      rootIndex: rootIdx,
      stepType: TreeStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Starting Pre-order traversal (Root → Left → Right)',
    ));

    final visited = <int>{};
    final visitedOrder = <int>[];

    // 5. Recursive Pre-order Traversal
    void traverse(_Node? node) {
      if (node == null) return;
      final idx = indexMap[node]!;

      // --- STEP: Visit the Root ---
      visited.add(idx);
      visitedOrder.add(idx);
      steps.add(TreeStepState(
        nodes: _snap(active: idx, visited: visited),
        rootIndex: rootIdx,
        stepType: TreeStepType.visited,
        activeCodeLine: 1, // "print(node.value)"
        activeNodeIndex: idx,
        visitedOrder: List.from(visitedOrder),
        stepDescription: 'Visit Node ${node.value} first',
      ));

      // --- STEP: Recurse Left ---
      if (node.left != null) {
        steps.add(TreeStepState(
          nodes: _snap(active: idx, visited: visited),
          rootIndex: rootIdx,
          stepType: TreeStepType.visiting,
          activeCodeLine: 2, // "preorder(node.left)"
          activeNodeIndex: idx,
          visitedOrder: List.from(visitedOrder),
          stepDescription: 'Moving to the left child of ${node.value}',
        ));
        traverse(node.left);
      }

      // --- STEP: Recurse Right ---
      if (node.right != null) {
        steps.add(TreeStepState(
          nodes: _snap(active: idx, visited: visited),
          rootIndex: rootIdx,
          stepType: TreeStepType.visiting,
          activeCodeLine: 3, // "preorder(node.right)"
          activeNodeIndex: idx,
          visitedOrder: List.from(visitedOrder),
          stepDescription: 'Moving to the right child of ${node.value}',
        ));
        traverse(node.right);
      }
    }

    traverse(root);

    // 6. Final State
    steps.add(TreeStepState(
      nodes: _snap(visited: visited),
      rootIndex: rootIdx,
      stepType: TreeStepType.done,
      activeCodeLine: 4,
      visitedOrder: List.from(visitedOrder),
      stepDescription:
          'Pre-order Traversal Complete: ${visitedOrder.map((i) => nodeList[i].value).join(' → ')}',
    ));

    return steps;
  }
}