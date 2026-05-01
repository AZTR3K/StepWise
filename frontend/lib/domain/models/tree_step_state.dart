enum TreeStepType {
  idle,
  visiting,    // traversal: currently on this node
  visited,     // traversal: node done
  inserting,   // AVL/RB: placing new node
  rotating,    // AVL/RB: rotation happening
  recolouring, // RB: colour flip
  done,
}

enum NodeColour { red, black } // for Red-Black

// ─── Immutable tree node (snapshot per step) ──────────────────────────────────
class TreeNodeSnapshot {
  final int value;
  final int? left;
  final int? right;
  final bool isHighlighted;
  final bool isVisited;
  final bool isActive;
  final bool isNewlyInserted;
  final NodeColour colour;  // Use this for RB colors!
  final int? balanceFactor;

  const TreeNodeSnapshot({
    required this.value,
    this.left,
    this.right,
    this.isHighlighted = false,
    this.isVisited = false,
    this.isActive = false,
    this.isNewlyInserted = false,
    this.colour = NodeColour.black, // Default to black
    this.balanceFactor,
    // Removed boxColor from here
  });

  TreeNodeSnapshot copyWith({
    int? value,
    int? left,
    int? right,
    bool? isHighlighted,
    bool? isVisited,
    bool? isActive,
    bool? isNewlyInserted,
    NodeColour? colour,
    int? balanceFactor,
  }) {
    return TreeNodeSnapshot(
      value: value ?? this.value,
      left: left ?? this.left,
      right: right ?? this.right,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isVisited: isVisited ?? this.isVisited,
      isActive: isActive ?? this.isActive,
      isNewlyInserted: isNewlyInserted ?? this.isNewlyInserted,
      colour: colour ?? this.colour,
      balanceFactor: balanceFactor ?? this.balanceFactor,
    );
  }
}

// ─── One visualisation frame ──────────────────────────────────────────────────
class TreeStepState {
  /// Flat list of nodes. Index 0 is the root.
  /// Children are referenced by index.
  final List<TreeNodeSnapshot> nodes;
  final int? rootIndex;

  final TreeStepType stepType;
  final int activeCodeLine;
  final String? stepDescription;

  /// Index of the node currently active (highlighted orange)
  final int? activeNodeIndex;

  /// Indices of nodes in the visited/traversal order so far
  final List<int> visitedOrder;

  const TreeStepState({
    required this.nodes,
    this.rootIndex,
    this.stepType = TreeStepType.idle,
    this.activeCodeLine = 0,
    this.stepDescription,
    this.activeNodeIndex,
    this.visitedOrder = const [],
  });
}

// ─── Preset tree values ───────────────────────────────────────────────────────
const defaultTreeValues = [50, 30, 70, 20, 40, 60, 80];