import 'package:flutter/material.dart';

// ─── Data Models ───────────────────────────────────────────

class AlgorithmItem {
  final String name;
  final String complexity;
  final String description;
  final Difficulty difficulty;
  final double progress; // 0.0 to 1.0, 0 = not started
  final IconData icon;
  final Color accentColor;

  const AlgorithmItem({
    required this.name,
    required this.complexity,
    required this.description,
    required this.difficulty,
    required this.progress,
    required this.icon,
    required this.accentColor,
  });
}

enum Difficulty { easy, medium, hard }

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return Colors.greenAccent;
      case Difficulty.medium:
        return const Color(0xFFFF9500);
      case Difficulty.hard:
        return const Color(0xFFFF453A);
    }
  }
}

// ─── Category Data ─────────────────────────────────────────

class CategoryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final List<AlgorithmItem> algorithms;

  const CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.algorithms,
  });
}

final Map<String, CategoryData> categoryDataMap = {
  'Sorting': CategoryData(
    title: 'Sorting',
    subtitle: '12 Algorithms',
    icon: Icons.sort,
    accentColor: Colors.blueAccent,
    algorithms: [
      AlgorithmItem(
        name: 'Bubble Sort',
        complexity: 'O(N²)',
        description:
            'Repeatedly swaps adjacent elements that are in the wrong order until the list is sorted.',
        difficulty: Difficulty.easy,
        progress: 1.0,
        icon: Icons.bubble_chart_outlined,
        accentColor: Colors.blueAccent,
      ),
      AlgorithmItem(
        name: 'Merge Sort',
        complexity: 'O(N LOG N)',
        description:
            'Divides the array into halves, sorts each half, then merges them back together.',
        difficulty: Difficulty.medium,
        progress: 0.64,
        icon: Icons.call_split,
        accentColor: Colors.blueAccent,
      ),
      AlgorithmItem(
        name: 'Quick Sort',
        complexity: 'O(N LOG N)',
        description:
            'Selects a pivot element and partitions the array around it recursively.',
        difficulty: Difficulty.medium,
        progress: 0.0,
        icon: Icons.flash_on_outlined,
        accentColor: Colors.blueAccent,
      ),
      AlgorithmItem(
        name: 'Heap Sort',
        complexity: 'O(N LOG N)',
        description:
            'Builds a max-heap from the data and extracts the maximum element repeatedly.',
        difficulty: Difficulty.hard,
        progress: 0.0,
        icon: Icons.layers_outlined,
        accentColor: Colors.blueAccent,
      ),
      AlgorithmItem(
        name: 'Insertion Sort',
        complexity: 'O(N²)',
        description:
            'Builds the sorted array one element at a time by inserting each into its correct position.',
        difficulty: Difficulty.easy,
        progress: 1.0,
        icon: Icons.input_outlined,
        accentColor: Colors.blueAccent,
      ),
      AlgorithmItem(
        name: 'Selection Sort',
        complexity: 'O(N²)',
        description:
            'Finds the minimum element and places it at the beginning, repeating for the rest.',
        difficulty: Difficulty.easy,
        progress: 0.3,
        icon: Icons.select_all_outlined,
        accentColor: Colors.blueAccent,
      ),
    ],
  ),
  'Searching': CategoryData(
    title: 'Searching',
    subtitle: '8 Algorithms',
    icon: Icons.search,
    accentColor: const Color(0xFFFF9500),
    algorithms: [
      AlgorithmItem(
        name: 'Binary Search',
        complexity: 'O(LOG N)',
        description:
            'Efficiently finds a target by repeatedly halving the search interval.',
        difficulty: Difficulty.easy,
        progress: 0.8,
        icon: Icons.find_in_page_outlined,
        accentColor: const Color(0xFFFF9500),
      ),
      AlgorithmItem(
        name: 'Linear Search',
        complexity: 'O(N)',
        description:
            'Sequentially checks each element until the target is found.',
        difficulty: Difficulty.easy,
        progress: 1.0,
        icon: Icons.linear_scale,
        accentColor: const Color(0xFFFF9500),
      ),
      AlgorithmItem(
        name: 'Jump Search',
        complexity: 'O(√N)',
        description:
            'Jumps ahead by fixed steps, then does a linear search in the identified block.',
        difficulty: Difficulty.medium,
        progress: 0.0,
        icon: Icons.skip_next_outlined,
        accentColor: const Color(0xFFFF9500),
      ),
      AlgorithmItem(
        name: 'Exponential Search',
        complexity: 'O(LOG N)',
        description:
            'Finds the range where the element may be present, then uses binary search.',
        difficulty: Difficulty.hard,
        progress: 0.0,
        icon: Icons.trending_up,
        accentColor: const Color(0xFFFF9500),
      ),
    ],
  ),
  'Graphs': CategoryData(
    title: 'Graphs',
    subtitle: '15 Algorithms',
    icon: Icons.hub,
    accentColor: Colors.greenAccent,
    algorithms: [
      AlgorithmItem(
        name: "Dijkstra's",
        complexity: 'O(V²)',
        description:
            'Finds the shortest path between nodes in a weighted graph.',
        difficulty: Difficulty.hard,
        progress: 0.2,
        icon: Icons.route_outlined,
        accentColor: Colors.greenAccent,
      ),
      AlgorithmItem(
        name: 'BFS',
        complexity: 'O(V+E)',
        description:
            'Explores all nodes at the present depth before moving to the next level.',
        difficulty: Difficulty.medium,
        progress: 0.5,
        icon: Icons.account_tree_outlined,
        accentColor: Colors.greenAccent,
      ),
      AlgorithmItem(
        name: 'DFS',
        complexity: 'O(V+E)',
        description:
            'Explores as far as possible along each branch before backtracking.',
        difficulty: Difficulty.medium,
        progress: 0.0,
        icon: Icons.device_hub_outlined,
        accentColor: Colors.greenAccent,
      ),
      AlgorithmItem(
        name: "Bellman-Ford",
        complexity: 'O(VE)',
        description:
            'Computes shortest paths from a source vertex, handles negative weights.',
        difficulty: Difficulty.hard,
        progress: 0.0,
        icon: Icons.timeline_outlined,
        accentColor: Colors.greenAccent,
      ),
    ],
  ),
  'Trees': CategoryData(
    title: 'Trees',
    subtitle: '10 Algorithms',
    icon: Icons.account_tree,
    accentColor: const Color(0xFF8E9BFF),
    algorithms: [
      AlgorithmItem(
        name: 'Inorder Traversal',
        complexity: 'O(N)',
        description: 'Visits left subtree, root, then right subtree.',
        difficulty: Difficulty.easy,
        progress: 1.0,
        icon: Icons.sort_by_alpha_outlined,
        accentColor: const Color(0xFF8E9BFF),
      ),
      AlgorithmItem(
        name: 'Preorder Traversal',
        complexity: 'O(N)',
        description: 'Visits root, left subtree, then right subtree.',
        difficulty: Difficulty.easy,
        progress: 0.6,
        icon: Icons.first_page_outlined,
        accentColor: const Color(0xFF8E9BFF),
      ),
      AlgorithmItem(
        name: 'AVL Tree',
        complexity: 'O(LOG N)',
        description:
            'Self-balancing BST where heights of two child subtrees differ by at most one.',
        difficulty: Difficulty.hard,
        progress: 0.0,
        icon: Icons.balance_outlined,
        accentColor: const Color(0xFF8E9BFF),
      ),
      AlgorithmItem(
        name: 'Red-Black Tree',
        complexity: 'O(LOG N)',
        description:
            'Self-balancing BST with an extra bit per node to ensure balance.',
        difficulty: Difficulty.hard,
        progress: 0.0,
        icon: Icons.circle_outlined,
        accentColor: const Color(0xFF8E9BFF),
      ),
    ],
  ),
};

// ─── Screen ────────────────────────────────────────────────

class CategoryDetailScreen extends StatefulWidget {
  final String categoryTitle;
  final Color accentColor;

  const CategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.accentColor,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _filter = 'ALL';

  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF111118);
  static const _cardBorder = Color(0xFF1E1E2E);
  static const _indigo = Color(0xFF4A6BFF);
  static const _indigoLight = Color(0xFF8E9BFF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<AlgorithmItem> get _filteredAlgorithms {
    final data = categoryDataMap[widget.categoryTitle];
    if (data == null) return [];
    if (_filter == 'ALL') return data.algorithms;
    final diff = Difficulty.values.firstWhere(
      (d) => d.label == _filter,
      orElse: () => Difficulty.easy,
    );
    return data.algorithms.where((a) => a.difficulty == diff).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = categoryDataMap[widget.categoryTitle];

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  widget.accentColor.withValues(alpha: 0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 15),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category icon + title
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: widget.accentColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: widget.accentColor
                                        .withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(data?.icon ?? Icons.category,
                                    color: widget.accentColor, size: 26),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.categoryTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  Text(
                                    data?.subtitle ?? '',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.35),
                                      fontSize: 12,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Progress summary
                          _buildProgressSummary(data),
                          const SizedBox(height: 28),

                          // Filter chips
                          _buildFilterRow(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Algorithm list ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final algo = _filteredAlgorithms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AlgorithmCard(
                            algorithm: algo,
                            index: index,
                          ),
                        );
                      },
                      childCount: _filteredAlgorithms.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary(CategoryData? data) {
    if (data == null) return const SizedBox.shrink();
    final completed =
        data.algorithms.where((a) => a.progress >= 1.0).length;
    final inProgress =
        data.algorithms.where((a) => a.progress > 0 && a.progress < 1.0).length;
    final total = data.algorithms.length;
    final overallProgress =
        data.algorithms.fold(0.0, (sum, a) => sum + a.progress) / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withValues(alpha: 0.08),
            _card,
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statPill('$completed', 'DONE', Colors.greenAccent),
              _statPill('$inProgress', 'IN PROGRESS', _indigoLight),
              _statPill(
                  '${total - completed - inProgress}', 'LOCKED', Colors.white38),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(overallProgress * 100).toInt()}% complete',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
              Text(
                '$completed / $total algorithms',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor:
                  AlwaysStoppedAnimation<Color>(widget.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final filters = ['ALL', 'EASY', 'MEDIUM', 'HARD'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = _filter == f;
          Color chipColor = Colors.white;
          if (f == 'EASY') chipColor = Colors.greenAccent;
          if (f == 'MEDIUM') chipColor = const Color(0xFFFF9500);
          if (f == 'HARD') chipColor = const Color(0xFFFF453A);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? chipColor.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? chipColor.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isActive
                        ? chipColor
                        : Colors.white.withValues(alpha: 0.35),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Algorithm Card ────────────────────────────────────────

class _AlgorithmCard extends StatefulWidget {
  final AlgorithmItem algorithm;
  final int index;

  const _AlgorithmCard({required this.algorithm, required this.index});

  @override
  State<_AlgorithmCard> createState() => _AlgorithmCardState();
}

class _AlgorithmCardState extends State<_AlgorithmCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _card = Color(0xFF111118);
  static const _cardBorder = Color(0xFF1E1E2E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Stagger by index
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final algo = widget.algorithm;
    final isCompleted = algo.progress >= 1.0;
    final isStarted = algo.progress > 0 && algo.progress < 1.0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTap: () {
            // Navigate to visualizer screen later
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? Colors.greenAccent.withValues(alpha: 0.2)
                    : _cardBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Animated icon container
                _AnimatedIconBox(
                  icon: algo.icon,
                  color: algo.accentColor,
                  isCompleted: isCompleted,
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              algo.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          // Difficulty badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: algo.difficulty.color
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: algo.difficulty.color
                                    .withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              algo.difficulty.label,
                              style: TextStyle(
                                color: algo.difficulty.color,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        algo.complexity,
                        style: TextStyle(
                          color: algo.accentColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        algo.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isStarted) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: algo.progress,
                                  minHeight: 3,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.07),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      algo.accentColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(algo.progress * 100).toInt()}%',
                              style: TextStyle(
                                color: algo.accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Arrow
                Icon(
                  isCompleted
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_ios,
                  color: isCompleted
                      ? Colors.greenAccent.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.15),
                  size: isCompleted ? 18 : 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Animated Icon Box ─────────────────────────────────────

class _AnimatedIconBox extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const _AnimatedIconBox({
    required this.icon,
    required this.color,
    required this.isCompleted,
  });

  @override
  State<_AnimatedIconBox> createState() => _AnimatedIconBoxState();
}

class _AnimatedIconBoxState extends State<_AnimatedIconBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (!widget.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isCompleted ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isCompleted
                  ? Colors.greenAccent.withValues(alpha: 0.12)
                  : widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isCompleted
                    ? Colors.greenAccent.withValues(alpha: 0.25)
                    : widget.color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              widget.isCompleted ? Icons.check : widget.icon,
              color: widget.isCompleted ? Colors.greenAccent : widget.color,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}