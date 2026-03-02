import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:clean_togo/ui/auth/login_screen.dart';
import 'package:clean_togo/ui/dashboard/dashboard_screen.dart';

void main() async {
  // 1. Indispensable pour Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Togo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      // 3. Pas de "const" ici si le constructeur de LoginScreen ne l'est pas
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : const DashboardScreen(),
    );
  }
}