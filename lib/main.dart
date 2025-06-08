import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:w3s/auth/login.dart';
import 'package:w3s/auth/signup.dart';
import 'package:w3s/auth/welcome_screen.dart';
import 'package:w3s/providers/ad_submission_provider.dart';
import 'package:w3s/providers/chat_provider.dart';
import 'package:w3s/screens/chat_screen.dart';
import 'package:w3s/screens/home_screen.dart';
import 'package:w3s/screens/profile_screen.dart';
import 'package:w3s/services/scan/api_service.dart';
import 'package:w3s/services/scan/camera_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyDarT6-zSEMRkIllBIuBWYh8B9rM4QSd_k', // ATTENTION: Clé à remplacer
          appId: '1:58975256341:android:037eccf38e31bbb5f6f31c',
          messagingSenderId: '58975256341',
          projectId: 'waste-smart-sorting-solu-53fc4'
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final http.Client httpClient = http.Client();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4CAF50);
    const accentColor = Color(0xFF8BC34A);
    const backgroundColor = Color(0xFFF5F5F5);
    const textColor = Color(0xFF333333);

    // Envelopper avec MultiProvider pour gérer tous les providers
    return MultiProvider(
      providers: [
        // Provider pour le service de caméra
        Provider<CameraService>(create: (_) => CameraService()),

        // Provider pour le service API
        Provider<ApiService>(create: (_) => ApiService(client: httpClient)),

        // Provider pour la soumission d'annonce (ne prend pas d'argument)
        ChangeNotifierProvider<AdSubmissionProvider>(
          create: (_) => AdSubmissionProvider(),
        ),

        // Provider pour le chat
        ChangeNotifierProvider<ChatProvider>(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Waste Smart Sorting',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
            primary: primaryColor,
            secondary: accentColor,
          ),
          scaffoldBackgroundColor: backgroundColor,
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme).copyWith(
            bodyLarge: TextStyle(color: textColor, fontSize: 16),
            bodyMedium: TextStyle(color: textColor, fontSize: 14),
            titleLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1.0,
            iconTheme: const IconThemeData(color: primaryColor),
            titleTextStyle: GoogleFonts.montserrat(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/home': (context) => HomeScreen(),
          '/login': (context) => const Login(),
          '/signup': (context) => const Signup(),
          '/profile': (context) => ProfileScreen(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}