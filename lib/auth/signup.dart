import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:w3s/widgets/auth_button.dart';
import 'package:w3s/widgets/text_field.dart';

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


  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // L'utilisateur est maintenant enregistré dans Firebase Authentication.
        print('Utilisateur inscrit : ${userCredential.user?.uid}');
        // Vous pouvez naviguer vers une autre page ici après l'inscription réussie.
        Navigator.of(context).pop(); // Retour à l'écran précédent (par exemple, l'écran de connexion)
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = _handleFirebaseError(e.code);
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Une erreur inattendue s\'est produite.';
        });
        print(e);
      }
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0), // Ajouté un padding vertical
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Image.asset(
                  "lib/images/logo.png",
                ),
              ),
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

              CustomTextField(
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),
              CustomTextField(
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: 25),

              AuthButton(
                text: 'Continue',
                onPressed: () {

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
                    "Don't have an account? ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: (){

                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0,0),
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
                  )
                ],
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child:
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "OR",
                      style:
                        TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14
                        ),
                    ),
                  ),
                  Expanded(
                    child:
                      Divider(
                        color: Colors.grey[300],
                        thickness: 1
                      )
                  ),
                ],
              ),
              SizedBox(height: 20),

              AuthButton(
                text: 'Continue with Google',
                onPressed: () {

                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconPath: 'lib/images/google.png',
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: 8.0,
              ),
              SizedBox(height: 15),

              AuthButton(
                text: 'Continue with Apple',
                onPressed: () {

                },
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconPath: "lib/images/apple.png",
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: 8.0,
              ),
              SizedBox(height: 25),

              AuthButton(
                text: 'Sign up',
                onPressed: () {

                },
                backgroundColor: Colors.grey[200]!,
                foregroundColor: Colors.black,
                borderRadius: 8.0,
              ),
              SizedBox(height: 15),

              AuthButton(
                text: 'Sign in',
                onPressed: () {

                },
                backgroundColor: Colors.grey[200]!,
                foregroundColor: Colors.black,
                borderRadius: 8.0, // Ajusté
              ),
              SizedBox(height: 30),

              // Terms and Privacy Policy
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {

                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
                    child: Text('Term of Use', style: TextStyle(fontSize: 14)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text('|', style: TextStyle(color: Colors.grey[500])),
                  ),
                  TextButton(
                    onPressed: () {

                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.green[700]),
                    child: Text('Privacy Policy', style: TextStyle(fontSize: 14)),
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