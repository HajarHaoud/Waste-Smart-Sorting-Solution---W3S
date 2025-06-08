import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Pour la gestion web

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  );

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Obtenir l'utilisateur actuel
  User? get currentUser => _firebaseAuth.currentUser;

  // Méthode pour se connecter avec Google
  Future<User?> signInWithGoogle() async {
    try {
      //  Déclencher le flux d'authentification Google
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {

        googleUser = await _googleSignIn.signIn();
      } else {

        if (await _googleSignIn.isSignedIn()) {

        }
        googleUser = await _googleSignIn.signIn();
      }

      // Si l'utilisateur annule la connexion Google
      if (googleUser == null) {
        print('Google Sign-In annulé par l\'utilisateur.');
        return null;
      }

      // Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Si les tokens ne sont pas présents (ce qui serait inhabituel après une connexion réussie)
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('Erreur: Tokens Google manquants.');
        return null;
      }

      // Créer une nouvelle crédential Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //  Se connecter à Firebase avec la crédential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      print('Connecté à Firebase avec Google: ${userCredential.user?.displayName}');
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à Firebase Auth
      print('FirebaseAuthException lors de la connexion Google: ${e.message} (Code: ${e.code})');
      return null;
    } catch (e) {
      // Gérer les autres erreurs (e.g., réseau, plugin Google Sign-In)
      print('Erreur inconnue lors de la connexion Google: $e');
      return null;
    }
  }

  // Méthode pour se déconnecter
  Future<void> signOut() async {
    try {
      // Se déconnecter de Google d'abord pour s'assurer que le sélecteur de compte apparaît la prochaine fois
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Puis se déconnecter de Firebase
      await _firebaseAuth.signOut();
      print('Utilisateur déconnecté.');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }
}