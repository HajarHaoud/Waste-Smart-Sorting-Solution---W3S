import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:w3s/widgets/auth_button.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _errorMessage;
  String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;
  int _resendToken = 0;
  int _countdown = 0;

  @override
  void initState(){
    super.initState();
    _phoneController.text = '+212';

    _checkFirebaseConfig();
  }

  void _checkFirebaseConfig() async {
    try{
      final instance = FirebaseAuth.instance;
      print('Firebase Auth configuré : ${instance.app.name}');
    }catch(e) {
      print('Erreur de configuration Firebase : $e');
      setState(() {
        _errorMessage = 'Erreur de configuration Firebase';
      });
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if(phoneNumber.startsWith('+212')) {
      if(phoneNumber.length > 4 && phoneNumber.substring(4, 5) == '0') {
        phoneNumber = '+212' + phoneNumber.substring(5);
      }
    }

    return phoneNumber;
  }

  void _startCountdown(){
    setState(() {
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if(mounted) {
        setState(() {
          _countdown-- ;
        });
        return _countdown > 0;
      }
      return false ;
    });
  }

  Future<void> _sendVerificationCode() async {
    if(!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String phoneNumber = _formatPhoneNumber(_phoneController.text.trim());


    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Vérification automatique réussie');
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Erreur de vérification : ${e.code} - ${e.message}');
          setState(() {
            _errorMessage = _handlePhoneAuthError(e.code);
            _isLoading = false ;
          });
        },
        codeSent: (String verificationId, int? resendTken) {
          print('Code envoyé au ${phoneNumber}');
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendTken ?? 0;
            _codeSent = true;
            _isLoading = false;
          });
          _startCountdown();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code de vérification envoyé ! '),
              backgroundColor: Colors.green,
                duration: Duration(seconds:  3),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Timeout de récupération automatique');
          setState(() {
            _verificationId = verificationId;
          });
        },
        forceResendingToken: _resendToken > 0 ? _resendToken : null,
      );
    } catch(e) {
      print('Erreur lors de l\'envoir du code : $e');
      setState(() {
        _errorMessage = 'Erreur lors de l\'envoie du code de vérification';
        _isLoading = false ;
      });
    }
  }

  Future<void> _verifyCode() async {
    if(_codeController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code de vérification';
      });
      return ;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );

      await _signInWithCredential(credential);
    } on FirebaseAuthException catch(e) {
      print('Erreur de vérification du code : ${e.code} - ${e.message}');
      setState(() {
        _errorMessage = _handlePhoneAuthError(e.code);
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur générale : $e');
      setState(() {
        _errorMessage = 'Erreur lors de la vérification du code';
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('Connexion réussie avec le téléphone : ');
      print(' - UID : ${userCredential.user?.uid}');
      print(' - Téléphone : ${userCredential.user?.phoneNumber}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connexion réussie ! '),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      if(mounted) {
        Navigator.of(context).restorablePushNamedAndRemoveUntil('/home', (route) => false);
      }
    }catch(e) {
      print('Erreur lors de la connexion : $e');
      setState(() {
        _errorMessage = 'Erreur lors de la connexion' ;
        _isLoading = false;
      });
    }
  }

  String _handlePhoneAuthError(String errorCode) {
    switch (errorCode) {
      case 'invalid-phone-number':
        return 'Le numéro de téléphone n\'est pas valide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'invalid-verification-code':
        return 'Le code de vérification est incorrect.';
      case 'invalid-verification-id':
        return 'ID de vérification invalide.';
      case 'quota-exceeded':
        return 'Quota SMS dépassé. Réessayez plus tard.';
      case 'missing-phone-number':
        return 'Numéro de téléphone manquant.';
      case 'missing-verification-code':
        return 'Code de vérification manquant.';
      default:
        return 'Erreur lors de l\'authentification par téléphone.';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back , color: Colors.black),
        ),
        title: Text(
          'Connexion par téléphone',
          style: TextStyle(
            color:  Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0 , vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              Text(
                _codeSent
                    ? 'Entrez le code de vérification'
                    : 'Entrez votre numéro de téléphone',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 10),

              Text(
                _codeSent
                    ? 'Nous avons envoyé un code à 6 chiffres au ${_phoneController.text}'
                    : 'Nous vous enverrons un code de vérification par SMS',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 30),

              // Affichage des erreurs
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
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700], fontSize: 14),
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
                    if (!_codeSent) ...[
                      // Champ numéro de téléphone
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '+212 6 12 34 56 78',
                          labelText: 'Numéro de téléphone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        enabled: !_isLoading,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre numéro de téléphone';
                          }
                          if (!value.startsWith('+')) {
                            return 'Le numéro doit commencer par un indicatif pays (+33 pour la France)';
                          }
                          if (value.length < 10) {
                            return 'Numéro de téléphone trop court';
                          }
                          return null;
                        },
                      ),
                    ] else ...[
                      // Champ code de vérification
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: '123456',
                          labelText: 'Code de vérification',
                          prefixIcon: Icon(Icons.sms),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Bouton principal
              AuthButton(
                text: _isLoading ? 'Chargement...' : _codeSent ? 'Vérifier le code' : 'Envoyer le code',
                onPressed: _isLoading ? null : _codeSent ? _verifyCode : _sendVerificationCode,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                fontWeight: FontWeight.w500,
                borderRadius: 8.0,
              ),

              if (_codeSent) ...[
                SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: _countdown > 0 || _isLoading
                        ? null
                        : () {
                      setState(() {
                        _codeSent = false;
                        _codeController.clear();
                      });
                      _sendVerificationCode();
                    },
                    child: Text(
                      _countdown > 0
                          ? 'Renvoyer le code dans ${_countdown}s'
                          : 'Renvoyer le code',
                      style: TextStyle(
                        color: _countdown > 0 ? Colors.grey : Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Bouton modifier le numéro
                Center(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                      setState(() {
                        _codeSent = false;
                        _codeController.clear();
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      'Modifier le numéro',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 40),

              // Information de sécurité
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nous utilisons votre numéro uniquement pour la vérification. Il ne sera pas partagé.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
