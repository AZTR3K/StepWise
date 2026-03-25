import 'package:flutter/material.dart';
import 'auth_components.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onNavigateToLogin;

  const RegisterScreen({super.key, this.onNavigateToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _termsAccepted = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080F),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4A6BFF).withValues(alpha: .1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8E9BFF).withValues(alpha: .07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StepWiseLogo(),
                          IconButton(
                            onPressed: widget.onNavigateToLogin ?? () {},
                            icon: const Icon(Icons.close,
                                color: Colors.white38, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9500).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFF9500).withValues(alpha: .25),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle,
                                color: Color(0xFFFF9500), size: 6),
                            SizedBox(width: 6),
                            Text(
                              'INITIALIZE PROTOCOL',
                              style: TextStyle(
                                color: Color(0xFFFF9500),
                                fontSize: 9,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Create ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Account',
                              style: TextStyle(
                                color: Color(0xFF8E9BFF),
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Join the editorial interface for high-precision\nalgorithm visualization.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .45),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 36),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel('FULL NAME'),
                            const SizedBox(height: 8),
                            GlassInputField(
                              controller: _nameController,
                              hint: 'Algorithm Architect',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: 20),
                            const FieldLabel('LOGIC NODE (EMAIL)'),
                            const SizedBox(height: 8),
                            GlassInputField(
                              controller: _emailController,
                              hint: 'logic@kinetic.io',
                              prefixIcon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            const FieldLabel('ACCESS KEY (PASSWORD)'),
                            const SizedBox(height: 8),
                            GlassInputField(
                              controller: _passwordController,
                              hint: '••••••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Terms checkbox
                            GestureDetector(
                              onTap: () => setState(
                                  () => _termsAccepted = !_termsAccepted),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: _termsAccepted
                                          ? const Color(0xFF6B7FFF)
                                          : Colors.white.withValues(alpha: .05),
                                      border: Border.all(
                                        color: _termsAccepted
                                            ? const Color(0xFF6B7FFF)
                                            : Colors.white.withValues(alpha: .15),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _termsAccepted
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 13)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color:
                                              Colors.white.withValues(alpha: 0.45),
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                        children: const [
                                          TextSpan(
                                              text: 'I acknowledge the '),
                                          TextSpan(
                                            text: 'Protocol Terms',
                                            style: TextStyle(
                                              color: Color(0xFF8E9BFF),
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  Color(0xFF8E9BFF),
                                            ),
                                          ),
                                          TextSpan(
                                              text:
                                                  ' and data handling procedures of StepWise.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            GradientButton(
                              label: 'Create Account',
                              icon: Icons.arrow_forward,
                              onPressed: _termsAccepted
                              ? () async {
                                try {
                                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );
                                } on FirebaseAuthException catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.message ?? 'Registration failed'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        : null,
                      ),

                            const SizedBox(height: 20),

                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 12,
                                  ),
                                  children: [
                                    const TextSpan(
                                        text: 'Already an architect? '),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: widget.onNavigateToLogin ??
                                            () {},
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Color(0xFF8E9BFF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: BottomTabSwitcher(
                          activeTab: 1,
                          onLoginTap: widget.onNavigateToLogin ?? () {},
                          onRegisterTap: () {},
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}