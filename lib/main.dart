import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:w3s/auth/login.dart';
import 'package:w3s/auth/signup.dart';
import 'package:w3s/auth/welcome_screen.dart';
import 'package:w3s/screens/home_screen.dart';
import 'package:w3s/screens/profile_screen.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyDarT6-zSEMRkIllBIuBWYh8B9rM4QSd_k',
          appId: '1:58975256341:android:037eccf38e31bbb5f6f31c',
          messagingSenderId: '58975256341',
          projectId: 'waste-smart-sorting-solu-53fc4'
      )
  );
  runApp(
    // Envelopper l'app avec ProviderScope pour Riverpod
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Smart Sorting',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Optionnel : Ajoutez des routes nommées si nécessaire
    routes: {
      '/': (context) => WelcomeScreen(),
      '/home': (context) => HomeScreen(), // Votre page principale
      '/login': (context) => Login(),
      '/signup': (context) => Signup(),
      '/profile': (context) => ProfileScreen(),
    },
    );
  }
}