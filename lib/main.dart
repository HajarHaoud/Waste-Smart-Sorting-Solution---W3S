import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Importer provider
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
      options: const FirebaseOptions( // Utilisez const
          apiKey: 'AIzaSyDarT6-zSEMRkIllBIuBWYh8B9rM4QSd_k', // ATTENTION: Clé d'exemple, ne pas utiliser en prod
          appId: '1:58975256341:android:037eccf38e31bbb5f6f31c',
          messagingSenderId: '58975256341',
          projectId: 'waste-smart-sorting-solu-53fc4'
      )
  );
  runApp(
    // Envelopper l'application avec ChangeNotifierProvider pour le ChatProvider
    ChangeNotifierProvider(
      create: (context) => ChatProvider(), // Crée une instance de votre ChatProvider
      child: MyApp(), // Votre application principale
    ),
  );
}

class MyApp extends StatelessWidget {
  final http.Client httpClient = http.Client();// MyApp peut être StatelessWidget
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Définir une palette de couleurs (similaire à celle du chatbot pour la cohérence)
    const primaryColor = Color(0xFF4CAF50);
    const accentColor = Color(0xFF8BC34A);
    const backgroundColor = Color(0xFFF5F5F5);
    const textColor = Color(0xFF333333);

    return MultiProvider(
      providers: [
        Provider<CameraService>(create: (_) => CameraService()),
        Provider<ApiService>(create: (_) => ApiService(client: httpClient)),
        ChangeNotifierProvider<AdSubmissionProvider>(
          create: (context) => AdSubmissionProvider(
            context.read<ApiService>(),
            // context.read<AuthService>(), // Si vous avez un AuthService
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Waste Smart Sorting',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: primaryColor,
          // primarySwatch est moins utilisé avec Material 3, préférez colorScheme
          // primarySwatch: Colors.green, // Vous pouvez le garder si certains widgets en dépendent encore
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor, // Utiliser votre primaryColor comme base
            brightness: Brightness.light,
            primary: primaryColor, // Explicitement définir la couleur primaire du scheme
            secondary: accentColor, // Explicitement définir la couleur secondaire
            // Vous pouvez définir d'autres couleurs du scheme ici si besoin
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
        initialRoute: '/', // WelcomeScreen est votre page d'accueil
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/home': (context) =>  HomeScreen(),
          '/login': (context) => const Login(),
          '/signup': (context) => const Signup(),
          '/profile': (context) =>  ProfileScreen(),
          '/chat': (context) => const ChatScreen(), // La route pour votre chatbot
        },
      ),
    );
  }
}