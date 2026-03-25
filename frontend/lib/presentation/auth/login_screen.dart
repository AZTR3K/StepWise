import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/primary_button.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const LoginScreen({super.key, required this.onSwitch});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication failed.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            "StepWise\nResonance.",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "KINETIC MANUSCRIPT PROTOCOL\n\nAccess your algorithm workspace and continue the manuscript of data.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                left: BorderSide(color: Color(0xFF4A6BFF), width: 4),
              ),
            ),
            child: Column(
              children: [
                CustomTextField(
                  label: "Identity",
                  hint: "Email or Username",
                  controller: _emailController,
                  suffixIcon: Icons.alternate_email,
                ),
                CustomTextField(
                  label: "Cipher",
                  hint: "••••••••",
                  controller: _passwordController,
                  isPassword: true,
                  suffixIcon: Icons.vpn_key_rounded,
                ),
                const SizedBox(height: 16),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4A6BFF))
                    : PrimaryButton(
                        text: "Initiate Session",
                        onPressed: _handleLogin,
                      ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: widget.onSwitch,
              child: const Text(
                "New to StepWise? Create Account",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
