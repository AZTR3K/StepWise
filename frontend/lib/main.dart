import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: StepWiseApp()));
}

class StepWiseApp extends StatelessWidget {
  const StepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StepWise Resonance',
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A6BFF),
          secondary: Colors.orangeAccent,
          surface: Color(0xFF181818),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
