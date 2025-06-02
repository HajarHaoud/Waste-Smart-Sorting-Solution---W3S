import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:w3s/auth/login.dart';
import 'package:w3s/screens/home_screen.dart';
import 'package:w3s/widgets/auth_button.dart';

class Signup extends StatefulWidget {
  const Signup({super.key}); // Changé pour utiliser const

  @override
  State<Signup> createState() => _SignupState(); // Changé pour utiliser createState
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '58975256341-d5ukagipcf1pj4sq27oa0gqeiuvnojud.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Connexion Google annulée par l\'utilisateur');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      print(
        'Utilisateur connecté avec Google : ${userCredential.user?.displayName}',
      );
      print('Email : ${userCredential.user?.email}');
      print('UID : ${userCredential.user?.uid}');

      if (mounted) {
        Navigator.of(
          context,
        ).restorablePushNamedAndRemoveUntil('/home', (route) => false);
      }

      //Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseError(e.code);
      });
      print('Erreur Firebase : ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la connexion avec Google';
      });
      print('Erreur Google Sign-In : $e');
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });

      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Veuillez remplir tous les champs';
        });
        return;
      }

      if (!RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(_emailController.text.trim())) {
        setState(() {
          _errorMessage = 'Veuillez entrer un email valide';
        });
        return;
      }

      if (_passwordController.text.length < 6) {
        setState(() {
          _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
        });
        return;
      }

      // Effacer les messages d'erreur précédents
      setState(() {
        _errorMessage = null;
      });

      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email:
                  _emailController.text
                      .trim(), // trim() enlève les espaces avant/après
              password: _passwordController.text,
            );

        print('✅ Utilisateur inscrit avec succès :');
        print('   - UID : ${userCredential.user?.uid}');
        print('   - Email : ${userCredential.user?.email}');
        print('   - Email vérifié : ${userCredential.user?.emailVerified}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Compte créé avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(Duration(seconds: 1));

        //Navigator.of(context).pop(); // Retour à l'écran précédent
      } on FirebaseAuthException catch (e) {
        print('❌ Erreur Firebase lors de l\'inscription : ${e.code}');
        print('   Message : ${e.message}');
        setState(() {
          _errorMessage = _handleFirebaseError(e.code);
        });
      } catch (e) {
        print('❌ Erreur générale lors de l\'inscription : $e');
        setState(() {
          _errorMessage =
              'Une erreur inattendue s\'est produite. Vérifiez votre connexion internet.';
        });
      }
    } else {
      print(
        '❌ Formulaire invalide - vérifiez les champs email et mot de passe',
      );
    }
  }

  String _handleFirebaseError(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Cet e-mail est déjà utilisé.';
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      // AJOUT : Gestion des erreurs spécifiques à Google Sign-In
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cette adresse e-mail mais avec un autre fournisseur.';
      case 'invalid-credential':
        return 'Les informations d\'identification fournies sont invalides.';
      case 'operation-not-allowed':
        return 'L\'authentification Google n\'est pas activée pour ce projet.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      default:
        return 'Erreur lors de la création du compte.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ), // Ajouté un padding vertical
          child: Column(
            children: [
              SizedBox(height: 100, child: Image.asset("lib/images/logo.png")),
              SizedBox(height: 20),
              Text(
                "Create an account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                  fontFamily: 'CalSans',
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: 'Email address'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 15),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(hintText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              AuthButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                fontWeight: FontWeight.w500,
                borderRadius: 8.0,
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => Login()));
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      foregroundColor: Colors.black,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "OR",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[300], thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: 20),

              AuthButton(
                text: 'Continue with Google',
                onPressed: _signInWithGoogle,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconPath: 'lib/images/google.png',
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: 8.0,
              ),

              SizedBox(height: 15),

              AuthButton(
                text: 'Continue with Apple',
                onPressed: () {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconPath: "lib/images/apple.png",
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: 8.0,
              ),

              SizedBox(height: 30),

              // Terms and Privacy Policy
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                    child: Text('Term of Use', style: TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('|', style: TextStyle(color: Colors.grey[500])),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
