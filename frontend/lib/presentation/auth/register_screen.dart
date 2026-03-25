import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/primary_button.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onSwitch;
  const RegisterScreen({super.key, required this.onSwitch});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptedTerms = false;

  Future<void> _handleRegister() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must acknowledge the Protocol Terms.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
        SnackBar(content: Text(e.message ?? 'Registration failed.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2015),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "• INITIALIZE PROTOCOL",
              style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
              children: [
                TextSpan(text: "Create "),
                TextSpan(
                  text: "Account",
                  style: TextStyle(color: Color(0xFF4A6BFF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Join the editorial interface for high-precision\nalgorithm visualization and data choreography.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: "Full Name",
            hint: "Alan Turing",
            controller: _nameController,
            suffixIcon: Icons.person,
          ),
          CustomTextField(
            label: "Logic Node (Email)",
            hint: "logic@kinetic.io",
            controller: _emailController,
            suffixIcon: Icons.alternate_email,
          ),
          CustomTextField(
            label: "Access Key (Password)",
            hint: "••••••••",
            controller: _passwordController,
            isPassword: true,
            suffixIcon: Icons.vpn_key_rounded,
          ),
          Row(
            children: [
              Checkbox(
                value: _acceptedTerms,
                onChanged: (val) =>
                    setState(() => _acceptedTerms = val ?? false),
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? const Color(0xFF4A6BFF)
                      : const Color(0xFF333333),
                ),
              ),
              const Expanded(
                child: Text(
                  "I acknowledge the Protocol Terms and the data handling procedures of StepWise.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A6BFF)),
                )
              : PrimaryButton(
                  text: "Create Account",
                  onPressed: _handleRegister,
                ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: widget.onSwitch,
              child: const Text(
                "Already have an account? Log In",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
