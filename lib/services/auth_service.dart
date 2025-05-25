import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Pour la gestion web

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '58975256341-d5ukagipcf1pj4sq27oa0gqeiuvnojud.apps.googleusercontent.com', // Uniquement si vous ciblez le web et avez une config spécifique
    scopes: [
      'email',
      'profile'
    ],
  );

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Google Sign-In annulé par l\'utilisateur.');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('Erreur: Tokens Google manquants.');
        throw Exception('Erreur lors de la récupération des tokens Google');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      print('Connecté à Firebase avec Google: ${userCredential.user?.displayName}');
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException lors de la connexion Google: ${e
          .message} (Code: ${e.code})');
      throw _handleFirebaseAuthException(e);
    } on Exception catch(e) {
      print('Erreur Google Sign-In : $e');
      throw Exception('Erreur lors de la connexion avec Google : ${e.toString()}');
    } catch (e) {
      print('Erreur inconnue lors de la connexion Google: $e');
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
    );
  }

  Future<User?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }



  // Méthode pour se déconnecter
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('Utilisateur déconnecté.');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Aucun utilisateur trouvé avec cet e-mail.';
        break;
      case 'wrong-password':
        message = 'Mot de passe incorrect.';
        break;
      case 'email-already-in-use':
        message = 'Cet e-mail est déjà utilisé.';
        break;
      case 'invalid-email':
        message = 'L\'adresse e-mail n\'est pas valide.';
        break;
      case 'weak-password':
        message = 'Le mot de passe est trop faible.';
        break;
      case 'user-disabled':
        message = 'Ce compte utilisateur a été désactivé.';
        break;
      case 'too-many-requests':
        message = 'Trop de tentatives. Réessayez plus tard.';
        break;
      case 'operation-not-allowed':
        message = 'Cette méthode d\'authentification n\'est pas activée.';
        break;
      case 'invalid-credential':
        message = 'Les informations d\'identification sont invalides.';
        break;
      case 'account-exists-with-different-credential':
        message = 'Un compte existe déjà avec cette adresse e-mail mais avec un autre fournisseur.';
        break;
      case 'invalid-verification-code':
        message = 'Le code de vérification est incorrect.';
        break;
      case 'invalid-verification-id':
        message = 'ID de vérification invalide.';
        break;
      case 'quota-exceeded':
        message = 'Quota SMS dépassé. Réessayez plus tard.';
        break;
      case 'invalid-phone-number':
        message = 'Le numéro de téléphone n\'est pas valide.';
        break;
      default:
        message = 'Une erreur d\'authentification s\'est produite: ${e.message}';
    }
    return Exception(message);
  }

  bool get isSignedIn => currentUser != null;

  Map<String, dynamic>? get userInfo {
    final user = currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'emailVerified': user.emailVerified,
    };
  }

}