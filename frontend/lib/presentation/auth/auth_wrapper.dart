import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still connecting to Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF08080F),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B7FFF),
              ),
            ),
          );
        }

        // User is logged in → go to HomeScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // User is not logged in → show Login or Register
        if (_showLogin) {
          return LoginScreen(
            onNavigateToRegister: () => setState(() => _showLogin = false),
          );
        } else {
          return RegisterScreen(
            onNavigateToLogin: () => setState(() => _showLogin = true),
          );
        }
      },
    );
  }
}