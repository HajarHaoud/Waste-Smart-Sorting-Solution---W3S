import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Pour la gestion web

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optionnel: si vous avez besoin de scopes spécifiques ou d'un clientID web
    // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Uniquement si vous ciblez le web et avez une config spécifique
    // scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  // Stream pour écouter les changements d'état d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Obtenir l'utilisateur actuel
  User? get currentUser => _firebaseAuth.currentUser;

  // Méthode pour se connecter avec Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Déclencher le flux d'authentification Google
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Pour le Web, GoogleSignIn().signIn() ouvre une popup.
        // Assurez-vous que votre client ID OAuth 2.0 pour le web est configuré
        // dans la console Google Cloud et Firebase.
        googleUser = await _googleSignIn.signIn();
      } else {
        // Pour mobile, vérifiez si l'utilisateur est déjà connecté avec Google
        // pour éviter de réafficher le sélecteur de compte si possible.
        if (await _googleSignIn.isSignedIn()) {
          // Tenter de se déconnecter silencieusement pour permettre un nouveau choix
          // ou pour rafraîchir les tokens si nécessaire, peut être optionnel.
          // await _googleSignIn.signOut(); // ou .disconnect() pour révoquer l'accès
        }
        googleUser = await _googleSignIn.signIn();
      }

      // Si l'utilisateur annule la connexion Google
      if (googleUser == null) {
        print('Google Sign-In annulé par l\'utilisateur.');
        return null;
      }

      // 2. Obtenir les détails d'authentification de la requête
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Si les tokens ne sont pas présents (ce qui serait inhabituel après une connexion réussie)
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('Erreur: Tokens Google manquants.');
        return null;
      }

      // 3. Créer une nouvelle crédential Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Se connecter à Firebase avec la crédential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      print('Connecté à Firebase avec Google: ${userCredential.user?.displayName}');
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs spécifiques à Firebase Auth
      print('FirebaseAuthException lors de la connexion Google: ${e.message} (Code: ${e.code})');
      // Vous pouvez renvoyer des messages d'erreur spécifiques basés sur e.code
      // e.g., 'account-exists-with-different-credential', 'invalid-credential', etc.
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