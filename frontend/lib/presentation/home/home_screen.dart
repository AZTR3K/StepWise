import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _activeNav = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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

  // ─── Colours ───────────────────────────────────────────────
  static const _bg = Color(0xFF08080F);
  static const _card = Color(0xFF111118);
  static const _cardBorder = Color(0xFF1E1E2E);
  static const _indigo = Color(0xFF4A6BFF);
  static const _indigoLight = Color(0xFF8E9BFF);
  static const _orange = Color(0xFFFF9500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Ambient glows (outside scroll, no BackdropFilter) ──
          Positioned(
            top: -120,
            right: -100,
            child: _ambientGlow(_indigo, 0.09, 340),
          ),
          Positioned(
            top: 380,
            left: -120,
            child: _ambientGlow(_indigoLight, 0.06, 300),
          ),
          Positioned(
            bottom: 160,
            right: -80,
            child: _ambientGlow(_indigo, 0.05, 260),
          ),

          // ── Scrollable body ────────────────────────────────────
          FadeTransition(
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
                      _sectionLabel('Continue Learning'),
                      const SizedBox(height: 14),
                      _buildContinueLearningCard(),
                      const SizedBox(height: 32),
                      _buildArchitecturesHeader(),
                      const SizedBox(height: 14),
                      _buildGrid(),
                      const SizedBox(height: 32),
                      _sectionLabel('Your Progress'),
                      const SizedBox(height: 14),
                      _buildStatTile('Time Invested', '14.5 Hours',
                          Icons.timer_outlined, Colors.greenAccent),
                      const SizedBox(height: 10),
                      _buildStatTile('Logic Mastery', '42 Solved',
                          Icons.verified_outlined, _indigoLight),
                      const SizedBox(height: 10),
                      _buildStatTile('Complexity Rank', 'Level 4 Scholar',
                          Icons.trending_up, _orange),
                      const SizedBox(height: 28),
                      _buildSignOut(),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom nav (only BackdropFilter here — not scrolling) ─
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // ─── Ambient glow helper ──────────────────────────────────
  Widget _ambientGlow(Color color, double opacity, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: opacity),
          Colors.transparent,
        ]),
      ),
    );
  }

  // ─── App bar ──────────────────────────────────────────────
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            _iconBtn(Icons.menu, () {}),
            const SizedBox(width: 12),
            // Logo dot
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_indigoLight, _indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _indigo.withValues(alpha: 0.45),
                    blurRadius: 10,
                  )
                ],
              ),
              child:
                  const Icon(Icons.blur_on, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            const Text(
              'StepWise',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Algorithm Visualiser',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
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
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }

  // ─── Featured card ────────────────────────────────────────
  Widget _buildFeaturedCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: _card,
        border: Border.all(color: _indigo.withValues(alpha: 0.25), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _indigo.withValues(alpha: 0.12),
            _card,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _indigo.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge('FEATURED LOGIC', _orange),
              const SizedBox(width: 8),
              Text(
                'STEPWISE',
                style: TextStyle(
                  color: _indigoLight.withValues(alpha: 0.6),
                  fontSize: 9,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Dijkstra's\nPathfinding",
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.05,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore the kinetic movement of the shortest path algorithm. Witness how weights shift and nodes evolve in a complex web of logic.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                gradient: const LinearGradient(
                  colors: [_indigoLight, _indigo],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _indigo.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Launch Visualizer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Continue learning ────────────────────────────────────
  Widget _buildContinueLearningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _indigo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: _indigo.withValues(alpha: 0.2), width: 1),
            ),
            child:
                const Icon(Icons.call_split, color: _indigoLight, size: 26),
          ),
          const SizedBox(height: 14),
          const Text(
            'Merge Sort',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SORTING  •  O(N LOG N)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "You've mastered the 'Divide' phase. Next: The 'Conquer' strategy where sorted sub-arrays are merged into the final solution.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '64%',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                'Step 7 of 11',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.64,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'Resume',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Architectures header ─────────────────────────────────
  Widget _buildArchitecturesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Algorithm\nArchitectures',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _indigo.withValues(alpha: 0.2), width: 1),
            ),
            child: const Text(
              'VIEW ALL',
              style: TextStyle(
                color: _indigoLight,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Grid ─────────────────────────────────────────────────
  Widget _buildGrid() {
    final items = [
      ('Sorting', '12 Algorithms', Icons.sort, Colors.blueAccent),
      ('Searching', '8 Algorithms', Icons.search, _orange),
      ('Graphs', '15 Algorithms', Icons.hub_outlined, Colors.greenAccent),
      ('Trees', '10 Algorithms', Icons.account_tree_outlined, _indigoLight),
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items
          .map((e) => _buildGridCard(e.$1, e.$2, e.$3, e.$4))
          .toList(),
    );
  }

  Widget _buildGridCard(
      String title, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
              border:
                  Border.all(color: color.withValues(alpha: 0.18), width: 1),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stat tile ────────────────────────────────────────────
  Widget _buildStatTile(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
              border:
                  Border.all(color: color.withValues(alpha: 0.18), width: 1),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.15), size: 13),
        ],
      ),
    );
  }

  // ─── Sign out ─────────────────────────────────────────────
  Widget _buildSignOut() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const AuthWrapper()));
          }
        },
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.redAccent.withValues(alpha: 0.18), width: 1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 15),
              SizedBox(width: 7),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 34),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.white.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 4;
              return Stack(
                children: [
                  // ── Liquid glass sliding pill ──
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    left: _activeNav * itemWidth + 8,
                    top: 8,
                    bottom: 8,
                    width: itemWidth - 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Nav icons on top ──
                  Row(
                    children: [
                      _navIcon(Icons.home_rounded, 0, itemWidth),
                      _navIcon(Icons.search_rounded, 1, itemWidth),
                      _navIcon(Icons.data_object, 2, itemWidth),
                      _navIcon(Icons.settings_rounded, 3, itemWidth),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

Widget _navIcon(IconData icon, int index, double itemWidth) {
  final isActive = _activeNav == index;
  return GestureDetector(
    onTap: () => setState(() => _activeNav = index),
    child: SizedBox(
      width: itemWidth,
      height: 56,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: const TextStyle(),
          child: Icon(
            icon,
            size: 26,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    ),
  );
}
  // ─── Helpers ──────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}