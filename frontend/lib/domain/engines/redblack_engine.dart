import '../models/tree_step_state.dart';

class _RBNode {
  int value;
  _RBNode? left, right, parent;
  bool isRed = true;
  _RBNode(this.value, {this.parent});
}

class RedBlackTreeEngine {
  final List<TreeStepState> _steps = [];
  final List<_RBNode> _nodeList = [];
  _RBNode? _root;

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _refreshNodeList() {
    _nodeList.clear();
    _flatten(_root);
  }

  void _flatten(_RBNode? node) {
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

  List<TreeNodeSnapshot> _snap({int? active}) {
    _refreshNodeList();
    final indexMap = {
      for (int i = 0; i < _nodeList.length; i++) _nodeList[i]: i
    };
    return _nodeList.asMap().entries.map((e) {
      final n = e.value;
      return TreeNodeSnapshot(
        value: n.value,
        left: n.left != null ? indexMap[n.left] : null,
        right: n.right != null ? indexMap[n.right] : null,
        isActive: e.key == active,
        colour: n.isRed ? NodeColour.red : NodeColour.black,
      );
    }).toList();
  }

  void _addStep({
    int? active,
    required TreeStepType type,
    required String description,
    int codeLine = 0,
  }) {
    _refreshNodeList();
    _steps.add(TreeStepState(
      nodes: _snap(active: active),
      rootIndex: _rootIndex(),
      stepType: type,
      activeCodeLine: codeLine,
      stepDescription: description,
    ));
  }

  // ── Public API ────────────────────────────────────────────────────────────
  List<TreeStepState> generateSteps(List<int> values) {
    _steps.clear();
    _nodeList.clear();
    _root = null;

    _steps.add(TreeStepState(
      nodes: const [],
      rootIndex: 0,
      stepType: TreeStepType.idle,
      activeCodeLine: 0,
      stepDescription: 'Starting Red-Black Tree construction',
    ));

    for (final value in values) {
      _insertValue(value);
    }

    _addStep(
      type: TreeStepType.done,
      description: 'Red-Black Tree construction complete',
      codeLine: 5,
    );

    return _steps;
  }

  // ── Insert ────────────────────────────────────────────────────────────────
  void _insertValue(int value) {
    // Standard BST insert
    _RBNode? curr = _root;
    _RBNode? parent;

    while (curr != null) {
      parent = curr;
      if (value < curr.value) {
        curr = curr.left;
      } else if (value > curr.value) {
        curr = curr.right;
      } else {
        return; // duplicate
      }
    }

    final newNode = _RBNode(value, parent: parent);

    if (parent == null) {
      _root = newNode;
    } else if (value < parent.value) {
      parent.left = newNode;
    } else {
      parent.right = newNode;
    }

    _refreshNodeList();
    final newIdx = _nodeList.indexOf(newNode);

    _addStep(
      active: newIdx < 0 ? null : newIdx,
      type: TreeStepType.inserting,
      description: 'Inserted $value as RED node. Checking RB properties...',
      codeLine: 0,
    );

    _fixViolation(newNode);
  }

  // ── Fix violations ────────────────────────────────────────────────────────
  void _fixViolation(_RBNode node) {
    while (node != _root && node.isRed && (node.parent?.isRed ?? false)) {
      final parent = node.parent!;
      final grandParent = parent.parent;

      if (grandParent == null) break;

      // ── Case A: parent is left child ─────────────────────────────────────
      if (parent == grandParent.left) {
        final uncle = grandParent.right;

        if (uncle != null && uncle.isRed) {
          // Case 1: Uncle red → recolour
          grandParent.isRed = true;
          parent.isRed = false;
          uncle.isRed = false;
          node = grandParent;

          _refreshNodeList();
          final gpIdx = _nodeList.indexOf(grandParent);
          _addStep(
            active: gpIdx < 0 ? null : gpIdx,
            type: TreeStepType.recolouring,
            description:
                'Uncle is RED: Recoloured parent, uncle BLACK; grandparent RED',
            codeLine: 2,
          );
        } else {
          // Case 2: node is right child → left rotate parent first
          if (node == parent.right) {
            _leftRotate(parent);
            node = parent; // node now points to what was parent
          }

          // Case 3: right rotate grandparent + swap colours
          final actualParent = node.parent!;
          _rightRotate(grandParent);

          final wasRed = actualParent.isRed;
          actualParent.isRed = grandParent.isRed;
          grandParent.isRed = wasRed;

          _refreshNodeList();
          final pIdx = _nodeList.indexOf(actualParent);
          _addStep(
            active: pIdx < 0 ? null : pIdx,
            type: TreeStepType.rotating,
            description:
                'Uncle BLACK: Rotated + recoloured at ${grandParent.value}',
            codeLine: 3,
          );

          node = actualParent;
        }
      }
      // ── Case B: parent is right child (symmetric) ─────────────────────────
      else {
        final uncle = grandParent.left;

        if (uncle != null && uncle.isRed) {
          grandParent.isRed = true;
          parent.isRed = false;
          uncle.isRed = false;
          node = grandParent;

          _refreshNodeList();
          final gpIdx = _nodeList.indexOf(grandParent);
          _addStep(
            active: gpIdx < 0 ? null : gpIdx,
            type: TreeStepType.recolouring,
            description:
                'Uncle is RED: Recoloured parent, uncle BLACK; grandparent RED',
            codeLine: 2,
          );
        } else {
          if (node == parent.left) {
            _rightRotate(parent);
            node = parent;
          }

          final actualParent = node.parent!;
          _leftRotate(grandParent);

          final wasRed = actualParent.isRed;
          actualParent.isRed = grandParent.isRed;
          grandParent.isRed = wasRed;

          _refreshNodeList();
          final pIdx = _nodeList.indexOf(actualParent);
          _addStep(
            active: pIdx < 0 ? null : pIdx,
            type: TreeStepType.rotating,
            description:
                'Uncle BLACK: Rotated + recoloured at ${grandParent.value}',
            codeLine: 3,
          );

          node = actualParent;
        }
      }
    }

    // Root must always be black
    if (_root!.isRed) {
      _root!.isRed = false;
      _addStep(
        type: TreeStepType.recolouring,
        description: 'Root set to BLACK (RB property)',
        codeLine: 4,
      );
    }
  }

  // ── Rotations (maintain parent pointers + update _root) ───────────────────
  void _leftRotate(_RBNode x) {
    final y = x.right!;
    x.right = y.left;
    if (y.left != null) y.left!.parent = x;
    y.parent = x.parent;

    if (x.parent == null) {
      _root = y;
    } else if (x == x.parent!.left) {
      x.parent!.left = y;
    } else {
      x.parent!.right = y;
    }

    y.left = x;
    x.parent = y;
  }

  void _rightRotate(_RBNode y) {
    final x = y.left!;
    y.left = x.right;
    if (x.right != null) x.right!.parent = y;
    x.parent = y.parent;

    if (y.parent == null) {
      _root = x;
    } else if (y == y.parent!.left) {
      y.parent!.left = x;
    } else {
      y.parent!.right = x;
    }

    x.right = y;
    y.parent = x;
  }
}