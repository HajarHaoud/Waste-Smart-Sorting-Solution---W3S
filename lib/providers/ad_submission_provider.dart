import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:image_picker/image_picker.dart'; // For XFile
import 'dart:convert'; // For base64Encode, base64Decode, jsonEncode, jsonDecode
import 'dart:typed_data'; // Nécessaire pour Uint8List
import 'package:http/http.dart' as http; // For http requests
import 'package:w3s/constants.dart'; // For API_BASE_URL1, DETECT_WASTE_ENDPOINT

enum AdSubmissionStatus { initial, imageSelected, detecting, detectionSuccess, detectionFailed, submitting, submissionSuccess, submissionFailed, error }

class AdSubmissionProvider with ChangeNotifier {
// ... vos variables existantes ...
  XFile? _imageFile; // L'image originale que l'utilisateur a choisie
  Uint8List? _processedImageData; // <<< NOUVEAU : Pour l'image AVEC les boîtes du backend
  List<dynamic> _detections = [];
  AdSubmissionStatus _status = AdSubmissionStatus.initial;

// Getters
  XFile? get imageFile => _imageFile;
  Uint8List? get processedImageData => _processedImageData; // <<< NOUVEAU Getter
  List<dynamic> get detections => _detections;
  AdSubmissionStatus get status => _status;

// Ancien constructeur supprimé dans l'édition manuelle de l'utilisateur
// ApiService _apiService;
// AdSubmissionProvider(this._apiService);

  AdSubmissionProvider(); // Utiliser un constructeur sans argument si ApiService n'est plus injecté

  void setImageFile(XFile? file) { // Note: J'ai renommé 'voidsetImageFile' en 'setImageFile'
    _imageFile = file;
    _processedImageData = null; // Très important: réinitialiser l'image traitée
    _detections = [];         // Réinitialiser les détections
    _status = AdSubmissionStatus.initial; // ou un autre statut approprié
    notifyListeners();
  }

  Future<void> performWasteDetection() async {
    if (_imageFile == null) {
      _status = AdSubmissionStatus.error; // Ou un statut indiquant "pas d'image"
      notifyListeners();
      return;
    }

    _status = AdSubmissionStatus.detecting;
    notifyListeners();

    try {
      final imageBytes = await _imageFile!.readAsBytes();
      String base64Image = base64Encode(imageBytes); // de dart:convert

      // Utilisez vos constantes ici
      // const String API_BASE_URL1 = "http://192.168.240.143:5000";
      // const String DETECT_WASTE_ENDPOINT = "/api/detect_waste";
      // Assurez-vous que API_BASE_URL1 et DETECT_WASTE_ENDPOINT sont accessibles et corrects
      final url = Uri.parse(API_BASE_URL1 + DETECT_WASTE_ENDPOINT);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'image': base64Image}), // Votre backend s'attend à {'image': 'base64_string_here'}
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body); // de dart:convert

        // MISE À JOUR DES DÉTECTIONS
        if (responseData.containsKey('detections')) {
          _detections = List<dynamic>.from(responseData['detections']);
        } else {
          _detections = [];
        }

        // <<< PARTIE CRUCIALE : TRAITEMENT DE L'IMAGE RETOURNÉE PAR LE BACKEND >>>
        if (responseData.containsKey('image') && responseData['image'] != null) {
          String imageBase64WithPrefix = responseData['image'];
          String imageBase64Payload;

          // Supprimer le préfixe 'data:image/jpeg;base64,'
          if (imageBase64WithPrefix.startsWith('data:image/jpeg;base64,')) {
            imageBase64Payload = imageBase64WithPrefix.substring('data:image/jpeg;base64,'.length);
          } else {
            // Au cas où le préfixe serait manquant pour une raison quelconque (ne devrait pas arriver avec votre backend actuel)
            imageBase64Payload = imageBase64WithPrefix;
            print("Attention: Le préfixe 'data:image/jpeg;base64,' est manquant dans la réponse image du backend.");
          }
          _processedImageData = base64Decode(imageBase64Payload); // de dart:convert
        } else {
          _processedImageData = null; // Pas d'image retournée
          print("Avertissement: Le backend n'a pas retourné de champ 'image' dans la réponse.");
        }
        // <<< FIN DE LA PARTIE CRUCIALE >>>

        _status = AdSubmissionStatus.detectionSuccess;
      } else {
        print("Échec de la détection: ${response.statusCode}");
        print("Corps de la réponse: ${response.body}");
        _detections = [];
        _processedImageData = null; // Assurez-vous de réinitialiser en cas d'échec
        _status = AdSubmissionStatus.detectionFailed;
      }
    } catch (e) {
      print("Erreur lors de performWasteDetection: $e");
      _detections = [];
      _processedImageData = null; // Assurez-vous de réinitialiser en cas d'erreur
      _status = AdSubmissionStatus.error;
    } finally {
      notifyListeners();
    }
  }

// Ajoutez les méthodes manquantes que vous avez retirées, comme addEditableWasteType, removeEditableWasteType, etc.
// Je les remets ici pour vous, mais vous pourriez avoir besoin de les adapter à votre nouvelle structure _detections.

// Méthodes pour gérer les types de déchets éditables (basées sur les détections)
// Note: Vous aviez _detectedWasteTypes et _editableWasteTypes séparés. Avec la nouvelle structure _detections,
// vous pourriez vouloir adapter ceci ou revenir à la séparation si l'édition est complexe.

// Pour l'instant, basons l'édition sur les noms des détections.
// Vous devrez peut-être adapter l'écran AdDetailsFormScreen pour utiliser _detections et ces méthodes.

  List<String> get editableWasteTypes {
    return _detections.map((det) => det['name'] as String).toSet().toList();
  }

  void addEditableWasteType(String type) {
// Cette logique pourrait devenir plus complexe si vous stockez plus que le nom.
// Pour l'instant, ajoutons juste le nom. Vous devrez peut-être ajouter une confiance par défaut.
    if (type.isNotEmpty && !_detections.any((det) => det['name'] == type)) {
      _detections.add({'name': type, 'confidence': 1.0}); // Ajouter avec confiance 1.0 par défaut
      notifyListeners();
    }
  }

  void removeEditableWasteType(String type) {
    _detections.removeWhere((det) => det['name'] == type);
    notifyListeners();
  }

// Variables et méthodes pour les autres champs du formulaire (quantité, description, type d'annonce)
  String _quantity = "";
  String get quantity => _quantity;

  String _description = "";
  String get description => _description;

  String _adType = "give"; // 'give' or 'sell'
  String get adType => _adType;

  void updateQuantity(String newQuantity) {
    _quantity = newQuantity;
// notifyListeners(); // Optionnel, si vous voulez que l'UI réagisse immédiatement
  }

  void updateDescription(String newDescription) {
    _description = newDescription;
// notifyListeners(); // Optionnel
  }

  void updateAdType(String newType) {
    _adType = newType;
    notifyListeners();
  }

// --- Gestion du Prix (Nouveau) ---
  double? _price; // Peut être null si l'action est Donner
  double? get price => _price;

  void updatePrice(double? newPrice) {
    _price = newPrice;
    notifyListeners(); // Notifie pour que l'UI (champ prix) se mette à jour si nécessaire
  }
// --- Fin Gestion du Prix ---

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

// Méthode de soumission de l'annonce (à vérifier si elle correspond à votre backend)
  Future<bool> submitAd() async {
// Validez les champs nécessaires avant de soumettre
    if (_imageFile == null || _detections.isEmpty || _quantity.isEmpty || (_adType == "sell" && _price == null)) {
      _errorMessage = "Veuillez sélectionner une image et remplir les champs requis.";
      _status = AdSubmissionStatus.submissionFailed; // Ou un autre état
      notifyListeners();
      return false;
    }

    _status = AdSubmissionStatus.submitting;
    _errorMessage = null; // Réinitialiser les erreurs précédentes
    notifyListeners();

// Préparez les données pour l'API de soumission d'annonce
// Votre API de soumission d'annonce attend peut-être l'image originale, l'image traitée, ou les détections.
// Basons-nous sur ce que vous aviez précédemment (image originale et détections/types modifiables).

// Si votre API de soumission attend l'image originale (comme _apiService.postNewAd le faisait)
// Vous pourriez avoir besoin de la reconstruire ou de la passer différemment si vous n'avez plus ApiService.
// Option 1: Envoyer l'image originale et les détections (potentiellement modifiées)
// Option 2: Envoyer l'image traitée (si votre backend l'accepte pour la soumission)
// Option 3: Revenir à l'injection de ApiService pour postNewAd

// IMPORTANT: L'implémentation de submitAd dépend fortement de votre API de soumission d'annonce.
// Je vais laisser une implémentation simple ici qui utilise les données disponibles,
// mais vous devrez l'adapter pour qu'elle corresponde à votre API réelle (peut-être en réinjectant ApiService).

    try {
      // Exemple simple (peut nécessiter ApiService ou un autre appel HTTP):
      // Supposons que votre API de soumission prend les types, quantité, description, type d'annonce.
      final submitUrl = Uri.parse(API_BASE_URL1 + "/api/submit_ad"); // Remplacez par le bon endpoint
      final submitResponse = await http.post(
        submitUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'wasteTypes': _detections.map((det) => det['name']).toList(), // Envoyer les noms détectés/édités
          'quantity': _quantity,
          'description': _description,
          'adType': _adType,
          'price': _price, // Ajouter le prix
          // Ajouter d'autres champs si nécessaire, comme l'image si l'API de soumission en a besoin.
          // 'image': base64Encode(await _imageFile!.readAsBytes()), // Si l'API a besoin de l'originale
          // 'processed_image': base64Encode(_processedImageData!), // Si l'API a besoin de la traitée
        }),
      );

      if (submitResponse.statusCode == 200 || submitResponse.statusCode == 201) {
        _status = AdSubmissionStatus.submissionSuccess;
        // resetForm(); // Optionnel: réinitialiser après succès
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Échec de la publication de l'annonce: ${submitResponse.body}";
        _status = AdSubmissionStatus.submissionFailed;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Erreur lors de la soumission: ${e.toString()}";
      _status = AdSubmissionStatus.submissionFailed;
      notifyListeners();
      return false;
    }


  }

  void resetForm() {
    _imageFile = null;
    _processedImageData = null;
    _detections = [];
    _quantity = "";
    _description = "";
    _adType = "give";
    _price = null; // Réinitialiser le prix
    _status = AdSubmissionStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
