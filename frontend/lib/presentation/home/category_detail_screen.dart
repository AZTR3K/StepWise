import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../visualizer/visualizer_screen.dart';
import '../visualizer/search_visualizer_screen.dart';
import '../theme/app_colors.dart';
//import '../widgets/glass_panel.dart';
import '../visualizer/graph_visualizer_screen.dart';
import '../visualizer/tree_visualizer_screen.dart';
import '../visualizer/dp_visualizer_screen.dart';

// ─── Data Models ───────────────────────────────────────────

class AlgorithmItem {
  final String name;
  final String complexity;
  final String description;
  final Difficulty difficulty;
  final double progress; // 0.0 to 1.0
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
        return const Color(0xFF34D399);
      case Difficulty.medium:
        return const Color(0xFFFFB020);
      case Difficulty.hard:
        return const Color(0xFFFF5C6C);
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
    accentColor: const Color(0xFF4FC3F7),
    algorithms: [
      AlgorithmItem(name: 'Bubble Sort', complexity: 'O(n²)', description: 'Repeatedly swaps adjacent elements that are in the wrong order until the list is sorted.', difficulty: Difficulty.easy, progress: 1.0, icon: Icons.bubble_chart_outlined, accentColor: const Color(0xFF4FC3F7)),
      AlgorithmItem(name: 'Merge Sort', complexity: 'O(n log n)', description: 'Divides the array into halves, sorts each half, then merges them back together.', difficulty: Difficulty.medium, progress: 0.64, icon: Icons.call_split, accentColor: const Color(0xFF4FC3F7)),
      AlgorithmItem(name: 'Quick Sort', complexity: 'O(n log n)', description: 'Selects a pivot element and partitions the array around it recursively.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.flash_on_outlined, accentColor: const Color(0xFF4FC3F7)),
      AlgorithmItem(name: 'Heap Sort', complexity: 'O(n log n)', description: 'Builds a max-heap from the data and extracts the maximum element repeatedly.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.layers_outlined, accentColor: const Color(0xFF4FC3F7)),
      AlgorithmItem(name: 'Insertion Sort', complexity: 'O(n²)', description: 'Builds the sorted array one element at a time by inserting each into its correct position.', difficulty: Difficulty.easy, progress: 1.0, icon: Icons.input_outlined, accentColor: const Color(0xFF4FC3F7)),
      AlgorithmItem(name: 'Selection Sort', complexity: 'O(n²)', description: 'Finds the minimum element and places it at the beginning, repeating for the rest.', difficulty: Difficulty.easy, progress: 0.3, icon: Icons.select_all_outlined, accentColor: const Color(0xFF4FC3F7)),
    ],
  ),
  'Searching': CategoryData(
    title: 'Searching',
    subtitle: '4 Algorithms',
    icon: Icons.search,
    accentColor: const Color(0xFFFFB020),
    algorithms: [
      AlgorithmItem(name: 'Binary Search', complexity: 'O(log n)', description: 'Efficiently finds a target by repeatedly halving the search interval.', difficulty: Difficulty.easy, progress: 0.8, icon: Icons.find_in_page_outlined, accentColor: const Color(0xFFFFB020)),
      AlgorithmItem(name: 'Linear Search', complexity: 'O(n)', description: 'Sequentially checks each element until the target is found.', difficulty: Difficulty.easy, progress: 1.0, icon: Icons.linear_scale, accentColor: const Color(0xFFFFB020)),
      AlgorithmItem(name: 'Jump Search', complexity: 'O(√n)', description: 'Jumps ahead by fixed steps, then does a linear search in the identified block.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.skip_next_outlined, accentColor: const Color(0xFFFFB020)),
      AlgorithmItem(name: 'Exponential Search', complexity: 'O(log n)', description: 'Finds the range where the element may be present, then uses binary search.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.trending_up, accentColor: const Color(0xFFFFB020)),
    ],
  ),
  'Graphs': CategoryData(
    title: 'Graphs',
    subtitle: '15 Algorithms',
    icon: Icons.hub,
    accentColor: const Color(0xFF34D399),
    algorithms: [
      AlgorithmItem(name: "Dijkstra's", complexity: 'O(V²)', description: 'Finds the shortest path between nodes in a weighted graph.', difficulty: Difficulty.hard, progress: 0.2, icon: Icons.route_outlined, accentColor: const Color(0xFF34D399)),
      AlgorithmItem(name: 'BFS', complexity: 'O(V+E)', description: 'Explores all nodes at the present depth before moving to the next level.', difficulty: Difficulty.medium, progress: 0.5, icon: Icons.account_tree_outlined, accentColor: const Color(0xFF34D399)),
      AlgorithmItem(name: 'DFS', complexity: 'O(V+E)', description: 'Explores as far as possible along each branch before backtracking.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.device_hub_outlined, accentColor: const Color(0xFF34D399)),
      AlgorithmItem(name: 'Bellman-Ford', complexity: 'O(VE)', description: 'Computes shortest paths from a source vertex, handles negative weights.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.timeline_outlined, accentColor: const Color(0xFF34D399)),
    ],
  ),
  'Trees': CategoryData(
    title: 'Trees',
    subtitle: '10 Algorithms',
    icon: Icons.account_tree,
    accentColor: const Color(0xFF8E9BFF),
    algorithms: [
      AlgorithmItem(name: 'Inorder Traversal', complexity: 'O(n)', description: 'Visits left subtree, root, then right subtree.', difficulty: Difficulty.easy, progress: 1.0, icon: Icons.sort_by_alpha_outlined, accentColor: const Color(0xFF8E9BFF)),
      AlgorithmItem(name: 'Preorder Traversal', complexity: 'O(n)', description: 'Visits root, left subtree, then right subtree.', difficulty: Difficulty.easy, progress: 0.6, icon: Icons.first_page_outlined, accentColor: const Color(0xFF8E9BFF)),
      AlgorithmItem(name: 'AVL Tree', complexity: 'O(log n)', description: 'Self-balancing BST where heights of two child subtrees differ by at most one.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.balance_outlined, accentColor: const Color(0xFF8E9BFF)),
      AlgorithmItem(name: 'Red-Black Tree', complexity: 'O(log n)', description: 'Self-balancing BST with an extra bit per node to ensure balance.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.circle_outlined, accentColor: const Color(0xFF8E9BFF)),
    ],
  ),
  'Dynamic Programming': CategoryData(
    title: 'Dynamic Programming',
    subtitle: '10 Algorithms',
    icon: Icons.grid_view_rounded,
    accentColor: const Color(0xFFB388FF),
    algorithms: [
      AlgorithmItem(name: 'Fibonacci Sequence', complexity: 'O(n)', description: 'Computes the nth number in the sequence using a 1D table (Memoization/Tabulation).', difficulty: Difficulty.easy, progress: 0.0, icon: Icons.linear_scale, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: '0/1 Knapsack', complexity: 'O(n·W)', description: 'Maximizes value within weight capacity using a 2D grid to track items and weights.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.grid_on, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Longest Common Subsequence', complexity: 'O(m·n)', description: 'Finds the longest subsequence present in two strings using a 2D matrix.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.table_chart_outlined, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Longest Increasing Subsequence', complexity: 'O(n²)', description: 'Finds the longest subsequence where all elements are sorted, visualized with a 1D table and pointer arrows.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.trending_up, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Coin Change', complexity: 'O(n·C)', description: 'Calculates the minimum coins needed for a total using a 1D table approach.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.monetization_on_outlined, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Matrix Chain Multiplication', complexity: 'O(n³)', description: 'Determines the most efficient way to multiply matrices using an upper-triangular 2D matrix.', difficulty: Difficulty.hard, progress: 0.0, icon: Icons.data_object, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Edit Distance', complexity: 'O(m·n)', description: 'Finds the minimum number of operations to convert one string to another using a 2D grid.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.text_fields_outlined, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Rod Cutting', complexity: 'O(n²)', description: 'Maximizes total revenue by cutting a rod into pieces, visualized via a 1D table.', difficulty: Difficulty.easy, progress: 0.0, icon: Icons.content_cut_outlined, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Max Subarray Sum', complexity: 'O(n)', description: "Kadane's Algorithm: finds the contiguous subarray with the largest sum using 1D DP.", difficulty: Difficulty.easy, progress: 0.0, icon: Icons.add_box_outlined, accentColor: const Color(0xFFB388FF)),
      AlgorithmItem(name: 'Max Subarray Product', complexity: 'O(n)', description: 'Finds the contiguous subarray with the largest product, tracking max and min in a 1D table.', difficulty: Difficulty.medium, progress: 0.0, icon: Icons.calculate_outlined, accentColor: const Color(0xFFB388FF)),
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

  static const _bg = AppColors.background;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
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
          // Subtle ambient atmosphere — single soft top accent only
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 360,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [
                      widget.accentColor.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Faint grid texture
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _DotGridPainter()),
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top bar
                          Row(
                            children: [
                              _IconButton(
                                icon: Icons.arrow_back_ios_new,
                                onTap: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              _IconButton(
                                icon: Icons.bookmark_outline,
                                onTap: () {},
                              ),
                              const SizedBox(width: 8),
                              _IconButton(
                                icon: Icons.tune,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Eyebrow
                          Text(
                            'CATEGORY · ${data?.algorithms.length ?? 0} TOTAL',
                            style: TextStyle(
                              color: widget.accentColor.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Mixed-weight title
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                height: 1.0,
                                letterSpacing: -1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: widget.categoryTitle.split(' ').first,
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                                if (widget.categoryTitle.split(' ').length > 1)
                                  TextSpan(
                                    text: '\n${widget.categoryTitle.split(' ').sublist(1).join(' ')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w200,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Hero progress card
                          _buildHeroCard(data),
                          const SizedBox(height: 28),

                          // Section label + filter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ALGORITHMS',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.4,
                                ),
                              ),
                              Text(
                                '${_filteredAlgorithms.length} shown',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildFilterRow(),
                          const SizedBox(height: 18),
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

  Widget _buildHeroCard(CategoryData? data) {
    if (data == null) return const SizedBox.shrink();
    final completed = data.algorithms.where((a) => a.progress >= 1.0).length;
    final inProgress = data.algorithms.where((a) => a.progress > 0 && a.progress < 1.0).length;
    final total = data.algorithms.length;
    final overall = data.algorithms.fold(0.0, (s, a) => s + a.progress) / total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accentColor.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon block
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor.withValues(alpha: 0.35),
                          widget.accentColor.withValues(alpha: 0.10),
                        ],
                      ),
                      border: Border.all(
                        color: widget.accentColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  // Big % display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR PROGRESS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${(overall * 100).toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              TextSpan(
                                text: '%',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ring
                  _ProgressRing(value: overall, color: widget.accentColor),
                ],
              ),
              const SizedBox(height: 20),
              // Stat strip
              Row(
                children: [
                  Expanded(child: _statTile('$completed', 'DONE', const Color(0xFF34D399))),
                  Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.08)),
                  Expanded(child: _statTile('$inProgress', 'ACTIVE', widget.accentColor)),
                  Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.08)),
                  Expanded(child: _statTile('${total - completed - inProgress}', 'LOCKED', Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statTile(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 9,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
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
          Color chipColor = widget.accentColor;
          if (f == 'EASY') chipColor = const Color(0xFF34D399);
          if (f == 'MEDIUM') chipColor = const Color(0xFFFFB020);
          if (f == 'HARD') chipColor = const Color(0xFFFF5C6C);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive
                      ? chipColor.withValues(alpha: 0.18)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isActive
                        ? chipColor.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: chipColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: chipColor.withValues(alpha: 0.6), blurRadius: 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                    Text(
                      f,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Icon Button ───────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

// ─── Progress Ring ─────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressRing({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
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
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    const searchAlgorithms = {'Linear Search', 'Binary Search', 'Jump Search', 'Exponential Search'};
    const graphAlgorithms = {'BFS', 'DFS', "Dijkstra's", 'Bellman-Ford'};
    const treeAlgorithms = {'Inorder Traversal', 'Preorder Traversal', 'AVL Tree', 'Red-Black Tree'};
    const dpAlgorithms = {
      'Fibonacci Sequence', '0/1 Knapsack', 'Longest Common Subsequence',
      'Longest Increasing Subsequence', 'Coin Change', 'Matrix Chain Multiplication',
      'Edit Distance', 'Rod Cutting', 'Max Subarray Sum', 'Max Subarray Product',
    };

    final name = widget.algorithm.name;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (searchAlgorithms.contains(name)) return SearchVisualizerScreen(algorithmName: name);
          if (graphAlgorithms.contains(name)) return GraphVisualizerScreen(algorithmName: name);
          if (treeAlgorithms.contains(name)) return TreeVisualizerScreen(algorithmName: name);
          if (dpAlgorithms.contains(name)) return DPVisualizerScreen(algorithmName: name);
          return VisualizerScreen(algorithmName: name);
        },
      ),
    );
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
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: _handleTap,
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF34D399).withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Left accent rail
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                algo.accentColor.withValues(alpha: 0.9),
                                algo.accentColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AnimatedIconBox(
                              icon: algo.icon,
                              color: algo.accentColor,
                              isCompleted: isCompleted,
                            ),
                            const SizedBox(width: 14),
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
                                      _DifficultyBadge(diff: algo.difficulty),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Mono complexity tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: algo.accentColor.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      algo.complexity,
                                      style: TextStyle(
                                        color: algo.accentColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    algo.description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.45),
                                      fontSize: 11.5,
                                      height: 1.5,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isStarted) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: algo.progress,
                                              minHeight: 3,
                                              backgroundColor: Colors.white.withValues(alpha: 0.06),
                                              valueColor: AlwaysStoppedAnimation<Color>(algo.accentColor),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(algo.progress * 100).toInt()}%',
                                          style: TextStyle(
                                            color: algo.accentColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Trailing affordance
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? const Color(0xFF34D399).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.04),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCompleted ? Icons.check : Icons.arrow_forward,
                                color: isCompleted
                                    ? const Color(0xFF34D399)
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Difficulty Badge ──────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final Difficulty diff;
  const _DifficultyBadge({required this.diff});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: diff.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: diff.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: diff.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            diff.label,
            style: TextStyle(
              color: diff.color,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
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
      duration: const Duration(milliseconds: 2200),
    );
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
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
        final scale = widget.isCompleted ? 1.0 : _pulseAnimation.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isCompleted
                    ? [
                        const Color(0xFF34D399).withValues(alpha: 0.28),
                        const Color(0xFF34D399).withValues(alpha: 0.08),
                      ]
                    : [
                        widget.color.withValues(alpha: 0.28),
                        widget.color.withValues(alpha: 0.06),
                      ],
              ),
              border: Border.all(
                color: (widget.isCompleted ? const Color(0xFF34D399) : widget.color)
                    .withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              widget.isCompleted ? Icons.check : widget.icon,
              color: widget.isCompleted ? const Color(0xFF34D399) : widget.color,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}

// ─── Subtle dot grid background ────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.025);
    const spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Suppress unused import warning if math becomes unused
// ignore: unused_element
final _kKeepMath = math.pi;
