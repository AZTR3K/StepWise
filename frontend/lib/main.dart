import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/auth/auth_wrapper.dart';
import 'presentation/theme/app_theme.dart';
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
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}
