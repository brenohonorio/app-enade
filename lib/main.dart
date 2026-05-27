import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 


import './core/theme/app_theme.dart';
import './features/auth/screens/login_screen.dart';
import './features/auth/screens/register_screen.dart';
import './features/dashboard/screens/dashboard_screen.dart';
import './features/questions/screens/question_screen.dart';
import './features/flashcards/screens/flashcard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eyrqirvobfsnbthznqis.supabase.co', 
    anonKey: 'sb_publishable_rNTWGk2LFu0AwlupmEHeVA_LzR0Xx2F',
  );

  runApp(const EnadeApp());
}

class EnadeApp extends StatelessWidget {
  const EnadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'App de Estudos CS',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme, 
      
      initialRoute: session == null ? '/login' : '/', 
      routes: {
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/questions': (context) => const QuestionScreen(),
        '/flashcards': (context) => const FlashcardScreen(),
      },
    );
  }
}