import '../models/tree_step_state.dart';
import 'dart:math';

class _AVLNode {
  int value;
  int height = 1;
  _AVLNode? left;
  _AVLNode? right;
  _AVLNode(this.value);
}

class AVLEngine {
  final List<TreeStepState> _steps = [];
  final List<_AVLNode> _nodeList = [];

  // The true root — updated every time a rotation changes it
  _AVLNode? _root;

  int _getHeight(_AVLNode? n) => n?.height ?? 0;
  int _getBalance(_AVLNode? n) =>
      n == null ? 0 : _getHeight(n.left) - _getHeight(n.right);

  // Re-flatten from the CURRENT _root
  void _refreshNodeList() {
    _nodeList.clear();
    _flatten(_root);
  }

  void _flatten(_AVLNode? node) {
    if (node == null) return;
    _flatten(node.left);
    _nodeList.add(node);
    _flatten(node.right);
  }

  int _rootIndex() {
    if (_root == null) return 0;
    final idx = _nodeList.indexOf(_root!);
    return idx < 0 ? 0 : idx;
  }

  List<TreeNodeSnapshot> _snap({int? active, Set<_AVLNode>? highlighted}) {
    _refreshNodeList();
    final indexMap = {
      for (int i = 0; i < _nodeList.length; i++) _nodeList[i]: i
    };
    return _nodeList.asMap().entries.map((e) {
      final n = e.value;
      final idx = e.key;
      final bf = _getBalance(n);
      return TreeNodeSnapshot(
        value: n.value,
        left: n.left != null ? indexMap[n.left] : null,
        right: n.right != null ? indexMap[n.right] : null,
        isActive: idx == active,
        isHighlighted: highlighted?.contains(n) ?? false,
        balanceFactor: bf,
      );
    }).toList();
  }

  void _addStep({
    int? active,
    Set<_AVLNode>? highlighted,
    required TreeStepType type,
    required String description,
    int? codeLine,
  }) {
    _refreshNodeList();
    _steps.add(TreeStepState(
      nodes: _snap(active: active, highlighted: highlighted),
      rootIndex: _rootIndex(),
      stepType: type,
      activeCodeLine: codeLine ?? 0,
      stepDescription: description,
    ));
  }

  List<TreeStepState> generateSteps(List<int> values) {
    _steps.clear();
    _nodeList.clear();
    _root = null;

    // Initial idle step
    _steps.add(TreeStepState(
      nodes: const [],
      rootIndex: 0,
      stepType: TreeStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Starting AVL Tree construction',
    ));

    for (final value in values) {
      _root = _insert(_root, value);
    }

    _addStep(
      type: TreeStepType.done,
      description: 'AVL Tree construction complete',
      codeLine: 7,
    );

    return _steps;
  }

  _AVLNode _insert(_AVLNode? node, int value) {
    // ── 1. BST insert ──────────────────────────────────────────────────────
    if (node == null) {
      final newNode = _AVLNode(value);
      // Temporarily attach to root so we can snapshot
      _addStep(
        active: _nodeList.length, // will be correct after refresh
        type: TreeStepType.inserting,
        description: 'Inserting $value into tree',
        codeLine: 0,
      );
      return newNode;
    }

    if (value < node.value) {
      node.left = _insert(node.left, value);
    } else if (value > node.value) {
      node.right = _insert(node.right, value);
    } else {
      return node; // duplicate
    }

    // ── 2. Update height ───────────────────────────────────────────────────
    node.height =
        1 + max(_getHeight(node.left), _getHeight(node.right));

    // ── 3. Check balance ───────────────────────────────────────────────────
    final balance = _getBalance(node);

    // Snapshot only when imbalanced (|bf| > 1)
    if (balance.abs() > 1) {
      // Find the index of this node BEFORE refresh so we can highlight it
      _refreshNodeList();
      final nodeIdx = _nodeList.indexOf(node);
      _steps.add(TreeStepState(
        nodes: _snap(active: nodeIdx < 0 ? null : nodeIdx),
        rootIndex: _rootIndex(),
        stepType: TreeStepType.rotating,
        activeCodeLine: 3,
        stepDescription:
            'Imbalanced at ${node.value} (bf=$balance) — rotation needed',
      ));
    }

    // ── 4. Rotations ───────────────────────────────────────────────────────
    // Left-Left
    if (balance > 1 && value < node.left!.value) {
      final result = _rightRotate(node);
      return result;
    }
    // Right-Right
    if (balance < -1 && value > node.right!.value) {
      final result = _leftRotate(node);
      return result;
    }
    // Left-Right
    if (balance > 1 && value > node.left!.value) {
      node.left = _leftRotate(node.left!);
      return _rightRotate(node);
    }
    // Right-Left
    if (balance < -1 && value < node.right!.value) {
      node.right = _rightRotate(node.right!);
      return _leftRotate(node);
    }

    return node;
  }

  _AVLNode _rightRotate(_AVLNode y) {
    final x = y.left!;
    final t2 = x.right;

    x.right = y;
    y.left = t2;

    y.height = 1 + max(_getHeight(y.left), _getHeight(y.right));
    x.height = 1 + max(_getHeight(x.left), _getHeight(x.right));

    // If y was root, x is now root
    if (_root == y) _root = x;

    _addStep(
      type: TreeStepType.rotating,
      description:
          'Right rotation at ${y.value}: ${x.value} becomes new subtree root',
      codeLine: 4,
    );

    return x;
  }

  _AVLNode _leftRotate(_AVLNode x) {
    final y = x.right!;
    final t2 = y.left;

    y.left = x;
    x.right = t2;

    x.height = 1 + max(_getHeight(x.left), _getHeight(x.right));
    y.height = 1 + max(_getHeight(y.left), _getHeight(y.right));

    if (_root == x) _root = y;

    _addStep(
      type: TreeStepType.rotating,
      description:
          'Left rotation at ${x.value}: ${y.value} becomes new subtree root',
      codeLine: 5,
    );

    return y;
  }
}