import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_wrapper.dart';
import 'widgets/category_card.dart';
import 'widgets/stat_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Row(
          children: [
            Text(
              "StepWise ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Flexible(
              child: Text(
              "Algorithm Visualiser",
              style: TextStyle(color: Colors.white54, fontSize: 14),
              overflow: TextOverflow.ellipsis, // optional: graceful truncation
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 100,
            ), // padding for bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildFeaturedLogicCard(),
                const SizedBox(height: 32),

                const Text(
                  "Continue Learning",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContinueLearningCard(),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Algorithm\nArchitectures",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "VIEW ALL\nCATALOG",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF8E9BFF),
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildArchitecturesGrid(),
                const SizedBox(height: 32),

                // Stats Section
                const StatTile(
                  title: "Time Invested",
                  value: "14.5 Hours",
                  icon: Icons.timer,
                  iconColor: Colors.greenAccent,
                ),
                const StatTile(
                  title: "Logic Mastery",
                  value: "42 Solved",
                  icon: Icons.verified,
                  iconColor: Color(0xFF8E9BFF),
                ),
                const StatTile(
                  title: "Complexity Rank",
                  value: "Level 4 Scholar",
                  icon: Icons.trending_up,
                  iconColor: Colors.orangeAccent,
                ),

                // Logout Button (Temporary for testing)
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthWrapper(),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    label: const Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Nav Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavIcon(Icons.home, true),
                  _buildNavIcon(Icons.search, false),
                  _buildNavIcon(Icons.data_object, false),
                  _buildNavIcon(Icons.settings, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4A6BFF) : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.white54,
        size: 24,
      ),
    );
  }

  Widget _buildFeaturedLogicCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "FEATURED LOGIC",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "STEPWISE",
          style: TextStyle(
            color: Color(0xFF8E9BFF),
            fontSize: 10,
            letterSpacing: 3,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Dijkstra's\nPathfinding",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Explore the kinetic movement of the shortest path algorithm. Witness how weights shift and nodes evolve in a complex web of logic.",
          style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 20),
        Container(
          height: 45,
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFF8E9BFF), Color(0xFF4A6BFF)],
            ),
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Launch Visualizer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.play_arrow, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueLearningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.call_split, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text(
            "Merge Sort",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "SORTING • O(N LOG N)",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "You've mastered the 'Divide' phase. Next: The 'Conquer' strategy where sorted sub-arrays are merged into the final solution.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            "64%",
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.64,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("Resume", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitecturesGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: const [
        CategoryCard(
          title: "Sorting",
          subtitle: "12 Algorithms",
          icon: Icons.sort,
          iconColor: Colors.blueAccent,
        ),
        CategoryCard(
          title: "Searching",
          subtitle: "8 Algorithms",
          icon: Icons.search,
          iconColor: Colors.orangeAccent,
        ),
        CategoryCard(
          title: "Graphs",
          subtitle: "15 Algorithms",
          icon: Icons.hub,
          iconColor: Colors.greenAccent,
        ),
        CategoryCard(
          title: "Trees",
          subtitle: "10 Algorithms",
          icon: Icons.account_tree,
          iconColor: Color(0xFF8E9BFF),
        ),
      ],
    );
  }
}
