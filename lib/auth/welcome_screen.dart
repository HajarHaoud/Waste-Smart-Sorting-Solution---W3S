// welcome_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:w3s/auth/signup.dart';
import 'package:w3s/services/auth_service.dart';

import '../widgets/auth_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final AuthService _authService = AuthService(); // Instance de votre service
  bool _isLoading = false; // Pour gérer l'état de chargement

  void _handleGoogleSignInPressed() {
    _handleGoogleSignIn(); // on appelle la fonction async mais sans attendre le résultat ici
  }


  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      User? user = await _authService.signInWithGoogle();
      if (user != null) {
        // Connexion réussie !
        // Naviguez vers l'écran d'accueil ou l'écran principal de l'application
        print("Connexion Google réussie: ${user.displayName}");
        // Exemple de navigation:
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        if (mounted) { // Vérifiez si le widget est toujours monté avant d'utiliser context
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bienvenue, ${user.displayName ?? 'Utilisateur'} !')),
          );
          // TODO: Naviguez vers votre page principale
        }
      } else {
        // La connexion a échoué ou a été annulée
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La connexion avec Google a échoué ou a été annulée.')),
          );
        }
      }
    } catch (e) {
      // Gérer les erreurs inattendues de l'UI si AuthService ne les gère pas toutes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                "lib/images/w3slogo.png"
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthButton(
                  text: "Continue with Apple",
                  onPressed: () {

                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  iconPath: "lib/images/apple.png", // Assurez-vous que cette image existe
                ),
                SizedBox(height: 16),
                AuthButton(
                  text: "Continue with Google",
                  onPressed: !_isLoading
                      ? () {
                    _handleGoogleSignIn();
                  }
                      : null,
                  backgroundColor: Colors.grey[800]!,
                  foregroundColor: Colors.white,
                  iconPath: "lib/images/google.png",
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: "Sign up",
                  onPressed: () {

                  },
                  backgroundColor: Colors.grey[800]!,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: "Log in",
                  onPressed: () {

                  },
                  backgroundColor: Colors.black, // Fond noir
                  foregroundColor: Colors.grey,    // Texte gris
                  borderSide: const BorderSide(color: Colors.grey), // Bordure grise
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10), // Ajout d'un peu de marge en bas
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}