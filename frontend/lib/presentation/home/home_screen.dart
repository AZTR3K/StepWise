import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/home/category_detail_screen.dart';
import 'package:frontend/presentation/profile/profile_screen.dart';
import 'package:frontend/presentation/visualizer/graph_visualizer_screen.dart';
import 'package:frontend/presentation/visualizer/visualizer_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_panel.dart';
import '../../domain/providers/profile_provider.dart';

final List<({IconData icon, IconData activeIcon, String label})> _navItems = const [
  (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
  (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
  (icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'Profile'),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _activeNav = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  static const _bg = AppColors.background;
  static const _indigo = AppColors.indigo;
  static const _indigoLight = AppColors.indigoLight;
  static const _orange = AppColors.orange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: LiquidGlassView(
        realTimeCapture: true,
        useSync: true,
        pixelRatio: 0.85,
        backgroundWidget: Stack(
          children: [
            Positioned(top: -140, right: -120, child: _ambientGlow(_indigo, 0.12, 380)),
            Positioned(top: 320, left: -140, child: _ambientGlow(_indigoLight, 0.08, 320)),
            Positioned(top: 600, right: -60, child: _ambientGlow(_orange, 0.05, 240)),
            Positioned(bottom: 120, left: -60, child: _ambientGlow(_indigo, 0.06, 280)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentTab(),
            ),
          ],
        ),
        children: [
          _buildBottomNavLens(),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_activeNav) {
      case 0:
        return _buildHomeTab(key: const ValueKey('home_tab'));
      case 1:
        return _buildSearchTab(key: const ValueKey('search_tab'));
      case 2:
        return const ProfileScreen(key: ValueKey('profile_tab'));
      default:
        return _buildHomeTab(key: const ValueKey('home_tab'));
    }
  }

  Widget _buildHomeTab({required Key key}) {
    return FadeTransition(
      key: key,
      opacity: _fadeAnimation,
      child: CustomScrollView(
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildAppBar()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildFeaturedCard(),
                const SizedBox(height: 32),
                _sectionLabel('Continue Learning', eyebrow: 'IN PROGRESS'),
                const SizedBox(height: 14),
                _buildContinueLearningCard(),
                const SizedBox(height: 32),
                _sectionLabel('Quick Stats', eyebrow: 'YOUR PROGRESS'),
                const SizedBox(height: 14),
                _buildStatTile('Logic Mastery', '42 Solved', Icons.verified_outlined, _indigoLight),
                const SizedBox(height: 10),
                _buildStatTile('Complexity Rank', 'Level 4 Scholar', Icons.trending_up, _orange),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab({required Key key}) {
    return FadeTransition(
      key: key,
      opacity: _fadeAnimation,
      child: CustomScrollView(
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: _orange.withValues(alpha: 0.6), blurRadius: 8),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ALGORITHMS · 55 TOTAL',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                            letterSpacing: 2.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Explore\n',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: 'Logic.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Browse algorithm architectures, watch them think.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 160),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCategoryStack(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ambientGlow(Color color, double opacity, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_indigoLight, _indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: _indigo.withValues(alpha: 0.55), blurRadius: 14),
                ],
              ),
              child: const Icon(Icons.blur_on, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            const Text(
              'StepWise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Algorithm Visualiser',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.32),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            _iconBtn(Icons.notifications_outlined, _showNotificationSheet),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        child: Stack(
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 17)),
            Positioned(
              right: 9,
              top: 9,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= FEATURED CARD =============
  Widget _buildFeaturedCard() {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 28,
      alpha: 0.06,
      glowColor: _indigo,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _PathfindingPainter(
                      progress: _pulseController.value,
                      color: _indigoLight,
                      accent: _orange,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 124, 26, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _badge('FEATURED LOGIC', _orange),
                    const SizedBox(width: 8),
                    _monoChip('O((V+E) log V)'),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Dijkstra's\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -1.4,
                        ),
                      ),
                      TextSpan(
                        text: 'pathfinding.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          height: 1.05,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Witness the kinetic dance of the shortest path. Watch how weights shift and nodes evolve in a complex web of logic.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                _primaryCTA(
                  label: 'Launch Visualizer',
                  icon: Icons.play_arrow_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GraphVisualizerScreen(algorithmName: "Dijkstra's"),
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

  Widget _primaryCTA({required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [_indigoLight, _indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(color: _indigo.withValues(alpha: 0.5), blurRadius: 22, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueLearningCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_indigo.withValues(alpha: 0.35), Colors.transparent],
                  ),
                ),
              ),
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _indigo.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _indigo.withValues(alpha: 0.3), width: 1),
                ),
                child: const Icon(Icons.call_split, color: _indigoLight, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Merge Sort',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          _monoChip('SORTING · O(n log n)'),
          const SizedBox(height: 14),
          Text(
            "You've mastered the 'Divide' phase. Next: the 'Conquer' strategy where sorted sub-arrays merge into the final solution.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12.5, height: 1.6),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.6), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '64%',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
              Text(
                'Step 7 of 11',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 6,
              color: Colors.white.withValues(alpha: 0.06),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.64,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.greenAccent, Color(0xFF34D399)]),
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VisualizerScreen(algorithmName: 'Merge Sort'),
              ),
            ),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Resume',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white.withValues(alpha: 0.7), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============= EXPLORE: stack of long animated category cards =============
  Widget _buildCategoryStack() {
    final items = <_CategoryItem>[
      _CategoryItem('Sorting', '6 Algorithms', 'O(n log n)', Icons.sort,
          const Color(0xFF4FC3F7), _CategoryViz.sortingBars,
          tagline: 'Watch chaos arrange itself.'),
      _CategoryItem('Searching', '4 Algorithms', 'O(log n)', Icons.search,
          _orange, _CategoryViz.binarySearch,
          tagline: 'Halve, target, conquer.'),
      _CategoryItem('Graphs', '4 Algorithms', 'O(V+E)', Icons.hub_outlined,
          const Color(0xFF34D399), _CategoryViz.graph,
          tagline: 'Trace paths through networks.'),
      _CategoryItem('Trees', '4 Algorithms', 'O(log n)',
          Icons.account_tree_outlined, const Color(0xFF8E9BFF), _CategoryViz.tree,
          tagline: 'Branch, balance, traverse.'),
      _CategoryItem('Dynamic Programming', '10 Algorithms', 'O(n·m)',
          Icons.grid_view_rounded, const Color(0xFFB388FF), _CategoryViz.dpGrid,
          tagline: 'Fill the table, find the optimum.'),
    ];

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _buildLongCategoryCard(items[i]),
          if (i < items.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildLongCategoryCard(_CategoryItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(
            categoryTitle: item.title,
            accentColor: item.color,
          ),
        ),
      ),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        alpha: 0.05,
        child: SizedBox(
          height: 191,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
            children: [
              // Animated visualization strip across the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 96,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _vizPainterFor(item.viz, item.color, _pulseController.value),
                        size: Size.infinite,
                      );
                    },
                  ),
                ),
              ),

              // Left accent rail
              Positioned(
                left: 0,
                top: 96,
                bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        item.color.withValues(alpha: 0.9),
                        item.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom info row
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 96,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _categoryIcon(item.icon, item.color),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.tagline,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  item.subtitle,
                                  //overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              item.color.withValues(alpha: 0.3),
                              item.color.withValues(alpha: 0.1),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.color.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(Icons.arrow_forward, color: item.color, size: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // Subtle separator between viz and content
              Positioned(
                left: 16,
                right: 16,
                top: 96,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          )
        ),
      ),
    );
  }

  CustomPainter _vizPainterFor(_CategoryViz viz, Color color, double t) {
    switch (viz) {
      case _CategoryViz.sortingBars:
        return _SortBarsPainter(color: color, progress: t);
      case _CategoryViz.binarySearch:
        return _BinarySearchPainter(color: color, progress: t);
      case _CategoryViz.graph:
        return _PathfindingPainter(progress: t, color: color, accent: _orange);
      case _CategoryViz.tree:
        return _TreePainter(color: color, progress: t);
      case _CategoryViz.dpGrid:
        return _DPGridPainter(color: color, progress: t);
    }
  }

  Widget _categoryIcon(IconData icon, Color color, {bool large = false}) {
    final size = large ? 44.0 : 42.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, color: color, size: large ? 22 : 20),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showStatSheet(title, value, icon, color),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        borderRadius: 18,
        child: Row(
          children: [
            _categoryIcon(icon, color),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.4), size: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSheet() {
    final notifications = [
      _NotifItem(
        icon: Icons.local_fire_department_rounded,
        color: _orange,
        title: 'Streak at risk!',
        body: "You haven't visualized anything today. Keep your 7-day streak alive.",
        time: '2m ago',
        isUnread: true,
      ),
      _NotifItem(
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFD700),
        title: 'Milestone unlocked',
        body: 'You solved 40+ problems. You\'ve reached Logic Scholar status.',
        time: '1h ago',
        isUnread: true,
      ),
      _NotifItem(
        icon: Icons.bolt_rounded,
        color: _indigoLight,
        title: 'Daily challenge ready',
        body: "Today's challenge: Trace Dijkstra's on a 6-node weighted graph.",
        time: '3h ago',
        isUnread: true,
      ),
      _NotifItem(
        icon: Icons.add_circle_outline_rounded,
        color: const Color(0xFF34D399),
        title: 'New algorithm added',
        body: 'Floyd-Warshall is now available under Graphs. All-pairs shortest path.',
        time: 'Yesterday',
        isUnread: false,
      ),
      _NotifItem(
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF8E9BFF),
        title: 'Complexity Rank up',
        body: "You've advanced to Level 4 Scholar after completing Merge Sort.",
        time: '2d ago',
        isUnread: false,
      ),
    ];

    final unreadCount = notifications.where((n) => n.isUnread).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.88,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0E1C),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: _indigo.withValues(alpha: 0.22),
                blurRadius: 48,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle + header — fixed, not scrollable
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _orange.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _orange.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '$unreadCount new',
                              style: TextStyle(
                                color: _orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: _indigoLight.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              // Scrollable list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  itemCount: notifications.length,
                  itemBuilder: (_, i) => _buildNotifTile(notifications[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifTile(_NotifItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: item.isUnread
            ? item.color.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isUnread
              ? item.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [item.color.withValues(alpha: 0.28), item.color.withValues(alpha: 0.07)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: item.color.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(color: item.color.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: item.isUnread ? Colors.white : Colors.white.withValues(alpha: 0.6),
                            fontSize: 13.5,
                            fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w500,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: item.isUnread ? 0.5 : 0.35),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            if (item.isUnread) ...[
              const SizedBox(width: 10),
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: item.color.withValues(alpha: 0.6), blurRadius: 6),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatSheet(String title, String value, IconData icon, Color color) {
    // Breakdown data per tile — swap in real provider values when ready
    final breakdowns = <String, List<_StatRow>>{
      'Logic Mastery': [
        _StatRow('Sorting',             14, 18, const Color(0xFF4FC3F7)),
        _StatRow('Searching',           10, 12, _orange),
        _StatRow('Graphs',               8, 14, const Color(0xFF34D399)),
        _StatRow('Trees',                6, 10, const Color(0xFF8E9BFF)),
        _StatRow('Dynamic Programming',  4, 12, const Color(0xFFB388FF)),
      ],
      'Complexity Rank': [
        _StatRow('Current Streak',   7,  14, _orange),
        _StatRow('Best Streak',     12,  14, const Color(0xFF4FC3F7)),
        _StatRow('Perfect Runs',     5,  10, const Color(0xFF34D399)),
        _StatRow('Hints Used',       3,  10, _indigoLight),
      ],
    };

    final rows = breakdowns[title] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0E1C),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 48,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // Header row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.07)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 26),
            // Breakdown rows
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          row.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${row.current} / ${row.total}',
                          style: TextStyle(
                            color: row.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(height: 5, color: Colors.white.withValues(alpha: 0.06)),
                          FractionallySizedBox(
                            widthFactor: (row.current / row.total).clamp(0.0, 1.0),
                            child: Container(
                              height: 5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [row.color, row.color.withValues(alpha: 0.55)],
                                ),
                                boxShadow: [
                                  BoxShadow(color: row.color.withValues(alpha: 0.45), blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============= LIQUID GLASS BOTTOM NAV =============
  // Returns a LiquidGlass lens that sits at the bottom of the LiquidGlassView.
  // The nav icons are overlaid as the lens's child so they render on top of
  // the true glass refraction effect.
  LiquidGlass _buildBottomNavLens() {
    final screenWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final navWidth = screenWidth - 48;

    return LiquidGlass(
      width: navWidth,
      height: 64,
      // Barely-there tint — let the shader do the heavy lifting
      color: Colors.white.withValues(alpha: 0.03),
      distortion: 0.08,
      distortionWidth: 32,
      magnification: 1.0,
      blur: LiquidGlassBlur(sigmaX: 22, sigmaY: 22),
      shape: RoundedRectangleShape(cornerRadius: 36),
      position: LiquidGlassAlignPosition(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 36),
      ),
      child: _buildNavIconRow(navWidth),
    );
  }

  Widget _buildNavIconRow(double navWidth) {
    final itemWidth = navWidth / _navItems.length;
    return Stack(
      children: [
        // Ultra-thin top specular line — like light catching a glass edge
        Positioned(
          top: 0,
          left: 16,
          right: 16,
          height: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.0),
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Frosted white glass pill — pure, no brand tint
        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutExpo,
          left: _activeNav * itemWidth + 5,
          top: 5,
          bottom: 5,
          width: itemWidth - 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              // Pure frosted white — top bright, fades softly
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.10),
                ],
              ),
              // Hairline border catches light subtly
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.60),
                width: 0.8,
              ),
              boxShadow: [
                // Soft white ambient glow — no color
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.18),
                  blurRadius: 14,
                  spreadRadius: -1,
                ),
                // Subtle drop shadow for lift
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            // Inner top shine streak
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 8,
                margin: const EdgeInsets.fromLTRB(10, 2, 10, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Nav icons
        Row(
          children: List.generate(_navItems.length, (i) => _navIcon(i, itemWidth)),
        ),
      ],
    );
  }



Widget _navIcon(int index, double itemWidth) {
  final isActive = _activeNav == index;
  final item = _navItems[index];
  final imageFile = ref.watch(profileProvider);

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      if (_activeNav != index) setState(() => _activeNav = index);
    },
    child: SizedBox(
      width: itemWidth,
      height: 68,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: Tween(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: (index == 2 && imageFile != null)
              ? Container(
                  key: ValueKey('avatar-$isActive'),
                  width: isActive ? 30 : 26,
                  height: isActive ? 30 : 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                    image: DecorationImage(
                      image: FileImage(imageFile),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey('${item.label}-$isActive'),
                  size: isActive ? 26 : 22,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                ),
        ),
      ),
    ),
  );
}



  Widget _sectionLabel(String text, {String? eyebrow}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Row(
            children: [
              Container(width: 14, height: 1.5, color: _orange.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(
                eyebrow,
                style: TextStyle(
                  color: _orange.withValues(alpha: 0.85),
                  fontSize: 9,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.32), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _monoChip(String text, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: compact ? 9 : 10,
          fontFamily: 'monospace',
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

enum _CategoryViz { sortingBars, binarySearch, graph, tree, dpGrid }

class _CategoryItem {
  final String title;
  final String subtitle;
  final String complexity;
  final IconData icon;
  final Color color;
  final _CategoryViz viz;
  final String tagline;
  _CategoryItem(
      this.title, this.subtitle, this.complexity, this.icon, this.color, this.viz,
      {required this.tagline});
}

// ============= Stat breakdown data =============
class _StatRow {
  final String label;
  final int current;
  final int total;
  final Color color;
  const _StatRow(this.label, this.current, this.total, this.color);
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  final bool isUnread;
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
  });
}

// ============= Pathfinding (Graphs) =============
class _PathfindingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color accent;

  _PathfindingPainter({required this.progress, required this.color, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    final activePaint = Paint()..color = color.withValues(alpha: 0.9);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    const cols = 9;
    const rows = 4;
    final dx = size.width / (cols + 1);
    final dy = size.height / (rows + 1);

    final nodes = <Offset>[];
    for (var r = 1; r <= rows; r++) {
      for (var c = 1; c <= cols; c++) {
        nodes.add(Offset(c * dx, r * dy));
      }
    }
    for (final n in nodes) {
      canvas.drawCircle(n, 1.5, nodePaint);
    }

    final path = Path();
    final waypoints = <Offset>[
      Offset(dx * 1, dy * 3),
      Offset(dx * 3, dy * 3),
      Offset(dx * 3, dy * 2),
      Offset(dx * 5, dy * 2),
      Offset(dx * 5, dy * 1),
      Offset(dx * 7, dy * 1),
      Offset(dx * 7, dy * 3),
      Offset(dx * 9, dy * 3),
    ];

    path.moveTo(waypoints.first.dx, waypoints.first.dy);
    for (var i = 1; i < waypoints.length; i++) {
      path.lineTo(waypoints[i].dx, waypoints[i].dy);
    }

    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (s, m) => s + m.length);
    final visibleLen = total * progress;

    final extracted = Path();
    var consumed = 0.0;
    for (final m in metrics) {
      if (consumed + m.length <= visibleLen) {
        extracted.addPath(m.extractPath(0, m.length), Offset.zero);
      } else {
        extracted.addPath(m.extractPath(0, math.max(0, visibleLen - consumed)), Offset.zero);
        break;
      }
      consumed += m.length;
    }

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final lineGlow = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(extracted, lineGlow);
    canvas.drawPath(extracted, linePaint);

    var distSoFar = 0.0;
    for (var i = 0; i < waypoints.length; i++) {
      if (i > 0) distSoFar += (waypoints[i] - waypoints[i - 1]).distance;
      if (distSoFar <= visibleLen) {
        canvas.drawCircle(waypoints[i], 5, glowPaint);
        canvas.drawCircle(waypoints[i], 2.5, activePaint);
      }
    }

    if (visibleLen > 0 && visibleLen < total) {
      Offset? head;
      var c = 0.0;
      for (final m in metrics) {
        if (c + m.length >= visibleLen) {
          final tan = m.getTangentForOffset(visibleLen - c);
          head = tan?.position;
          break;
        }
        c += m.length;
      }
      if (head != null) {
        canvas.drawCircle(
            head,
            9,
            Paint()
              ..color = accent.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
        canvas.drawCircle(head, 4, Paint()..color = accent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathfindingPainter old) => old.progress != progress;
}

// ============= Sorting bars =============
class _SortBarsPainter extends CustomPainter {
  final Color color;
  final double progress;
  _SortBarsPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const count = 22;
    final w = size.width / (count * 1.25);
    final gap = w * 0.25;
    final padX = (size.width - (count * (w + gap) - gap)) / 2;
    final topPad = size.height * 0.1;
    final maxH = size.height - topPad - 4;

    for (var i = 0; i < count; i++) {
      final t = (math.sin((progress * 2 * math.pi) + i * 0.45) + 1) / 2;
      final sortedH = (i + 1) / count;
      // Fade from chaotic to sorted across the loop
      final mix = (math.sin(progress * 2 * math.pi) + 1) / 2;
      final h = (sortedH * (0.5 + 0.4 * mix) + t * (0.5 - 0.4 * mix)) * maxH;
      final x = padX + i * (w + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h - 2, w, h),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.15)],
          ).createShader(rect.outerRect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SortBarsPainter old) => old.progress != progress;
}

// ============= Binary Search =============
class _BinarySearchPainter extends CustomPainter {
  final Color color;
  final double progress;
  _BinarySearchPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const count = 16;
    final w = size.width / (count * 1.2);
    final gap = w * 0.2;
    final padX = (size.width - (count * (w + gap) - gap)) / 2;
    final cellH = size.height * 0.42;
    final cellY = size.height / 2 - cellH / 2;

    // Animated search bracket: collapses toward target
    final target = 11; // index of target
    final phase = (progress * 4) % 4; // 4 collapse stages
    int lo = 0, hi = count - 1;
    int stage = phase.floor();
    for (var s = 0; s < stage; s++) {
      final mid = (lo + hi) ~/ 2;
      if (mid < target) {
        lo = mid + 1;
      } else if (mid > target) {
        hi = mid - 1;
      }
    }
    final mid = (lo + hi) ~/ 2;

    for (var i = 0; i < count; i++) {
      final x = padX + i * (w + gap);
      final inRange = i >= lo && i <= hi;
      final isMid = i == mid;
      final isTarget = i == target;

      Color fill;
      double alpha;
      if (isTarget && stage >= 3) {
        fill = color;
        alpha = 0.95;
      } else if (isMid) {
        fill = color;
        alpha = 0.7;
      } else if (inRange) {
        fill = color;
        alpha = 0.28;
      } else {
        fill = Colors.white;
        alpha = 0.05;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, cellY, w, cellH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, Paint()..color = fill.withValues(alpha: alpha));

      if (isMid || (isTarget && stage >= 3)) {
        canvas.drawRRect(
          rect,
          Paint()
            ..color = color.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // Brackets [lo  hi]
    final loX = padX + lo * (w + gap);
    final hiX = padX + hi * (w + gap) + w;
    final bracketPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final bracketY = cellY - 6;
    final bracketY2 = cellY + cellH + 6;
    canvas.drawLine(Offset(loX, bracketY), Offset(loX, bracketY2), bracketPaint);
    canvas.drawLine(Offset(hiX, bracketY), Offset(hiX, bracketY2), bracketPaint);

    // Mid pointer
    final midCenterX = padX + mid * (w + gap) + w / 2;
    final pointerPath = Path()
      ..moveTo(midCenterX, bracketY2 + 3)
      ..lineTo(midCenterX - 4, bracketY2 + 9)
      ..lineTo(midCenterX + 4, bracketY2 + 9)
      ..close();
    canvas.drawPath(pointerPath, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BinarySearchPainter old) => old.progress != progress;
}

// ============= Tree =============
class _TreePainter extends CustomPainter {
  final Color color;
  final double progress;
  _TreePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Build tree: 3 levels (1 + 2 + 4 = 7 nodes)
    final cx = size.width / 2;
    final topY = size.height * 0.18;
    final midY = size.height * 0.55;
    final botY = size.height * 0.92;

    final root = Offset(cx, topY);
    final l1 = Offset(cx - size.width * 0.22, midY);
    final r1 = Offset(cx + size.width * 0.22, midY);
    final l1l = Offset(cx - size.width * 0.36, botY);
    final l1r = Offset(cx - size.width * 0.10, botY);
    final r1l = Offset(cx + size.width * 0.10, botY);
    final r1r = Offset(cx + size.width * 0.36, botY);

    // Edges
    final edges = [
      [root, l1], [root, r1],
      [l1, l1l], [l1, l1r],
      [r1, r1l], [r1, r1r],
    ];
    final edgePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (final e in edges) {
      canvas.drawLine(e[0], e[1], edgePaint);
    }

    // Inorder traversal sequence highlights:
    // l1l, l1, l1r, root, r1l, r1, r1r
    final sequence = [l1l, l1, l1r, root, r1l, r1, r1r];
    final activeIdx = (progress * sequence.length).floor() % sequence.length;

    final allNodes = [root, l1, r1, l1l, l1r, r1l, r1r];
    for (final n in allNodes) {
      canvas.drawCircle(n, 5, Paint()..color = Colors.white.withValues(alpha: 0.08));
      canvas.drawCircle(
        n,
        4,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Highlight visited so far
    for (var i = 0; i <= activeIdx; i++) {
      canvas.drawCircle(sequence[i], 4, Paint()..color = color.withValues(alpha: 0.6));
    }

    // Active node — pulsing glow
    final active = sequence[activeIdx];
    final pulse = (math.sin(progress * 2 * math.pi * sequence.length) + 1) / 2;
    canvas.drawCircle(
      active,
      10 + pulse * 4,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(active, 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TreePainter old) => old.progress != progress;
}

// ============= DP Grid =============
class _DPGridPainter extends CustomPainter {
  final Color color;
  final double progress;
  _DPGridPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 12;
    const rows = 4;
    final cellW = (size.width - 24) / cols;
    final cellH = (size.height - 16) / rows;
    final padX = 12.0;
    final padY = 8.0;

    final total = rows * cols;
    final filled = (progress * total).floor();

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final idx = r * cols + c;
        final x = padX + c * cellW;
        final y = padY + r * cellH;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1, y + 1, cellW - 2, cellH - 2),
          const Radius.circular(3),
        );

        if (idx < filled) {
          // Filled cell — value intensity grows with row+col (mimic DP table)
          final intensity = ((r + c) / (rows + cols - 2)).clamp(0.0, 1.0);
          canvas.drawRRect(
            rect,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2 + intensity * 0.5),
                  color.withValues(alpha: 0.1 + intensity * 0.3),
                ],
              ).createShader(rect.outerRect),
          );
        } else {
          canvas.drawRRect(
            rect,
            Paint()..color = Colors.white.withValues(alpha: 0.04),
          );
        }
      }
    }

    // Active cell (currently being filled) — pulsing
    if (filled < total) {
      final r = filled ~/ cols;
      final c = filled % cols;
      final x = padX + c * cellW;
      final y = padY + r * cellH;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, y + 1, cellW - 2, cellH - 2),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawRRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DPGridPainter old) => old.progress != progress;
}