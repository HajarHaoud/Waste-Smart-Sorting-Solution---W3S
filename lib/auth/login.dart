import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:w3s/auth/phone_auth_page.dart';
import 'package:w3s/auth/signup.dart';
import 'package:w3s/widgets/auth_button.dart';

class Login extends StatefulWidget {
  const Login({super.key}); // Changé pour utiliser const

  @override
  State<Login> createState() => _LoginState(); // Changé pour utiliser createState
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '58975256341-d5ukagipcf1pj4sq27oa0gqeiuvnojud.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _loginInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Connexion Google annulée par l\'utilisateur');
        setState(() {
          _isLoading = false;
        });
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

      //Navigator.of(context).pop();
      if (mounted) {
        Navigator.of(
          context,
        ).restorablePushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseError(e.code);
        _isLoading = false;
      });
      print('Erreur Firebase : ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la connexion avec Google';
        _isLoading = false;
      });
      print('Erreur Google Sign-In : $e');
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
        _isLoading = true;
      });

      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email:
                  _emailController.text
                      .trim(), // trim() enlève les espaces avant/après
              password: _passwordController.text,
            );

        print('✅ Utilisateur inscrit avec succès :');
        print('   - UID : ${userCredential.user?.uid}');
        print('   - Email : ${userCredential.user?.email}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion réussie !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(Duration(seconds: 1));

        //Navigator.of(context).pop(); // Retour à l'écran précédent
        if (mounted) {
          Navigator.of(
            context,
          ).restorablePushNamedAndRemoveUntil('/home', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        print('Erreur Firebase lors de la connexion : ${e.code}');
        print('   Message : ${e.message}');
        setState(() {
          _errorMessage = _handleFirebaseError(e.code);
          _isLoading = false;
        });
      } catch (e) {
        print('Erreur générale lors de la connexion : $e');
        setState(() {
          _errorMessage =
              'Une erreur inattendue s\'est produite. Vérifiez votre connexion internet.';
          _isLoading = false;
        });
      }
    }
  }

  String _handleFirebaseError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet e-mail.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'L\'adresse e-mail n\'est pas valide.';
      case 'user-disabled':
        return 'Ce compte utilisateur a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Réessayez plus tard.';
      case 'invalid-credential':
        return 'Les informations d\'identification sont invalides.';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cette adresse e-mail mais avec un autre fournisseur.';
      case 'operation-not-allowed':
        return 'L\'authentification Google n\'est pas activée pour ce projet.';
      default:
        return 'Erreur lors de la connexion.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'CalSans',
                ),
              ),
              SizedBox(height: 30),

              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(hintText: 'Email address'),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
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
                      enabled: !_isLoading,
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

              AuthButton(
                text: _isLoading ? 'Connexion...' : 'Continue',
                onPressed: _isLoading ? null : _login,
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
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Signup(),
                                ),
                              );
                            },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      foregroundColor: Colors.black,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Sign up",
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
                onPressed: _loginInWithGoogle,
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
              SizedBox(height: 25),

              AuthButton(
                text: 'Continue with phone',
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PhoneAuthPage(),
                            ),
                          );
                        },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconPath: "assets/images/phone.png",
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: 8.0,
              ),
              SizedBox(height: 15),

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
