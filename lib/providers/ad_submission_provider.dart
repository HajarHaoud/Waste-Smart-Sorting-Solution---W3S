import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:image_picker/image_picker.dart';
import 'package:w3s/models/scan/ad_model.dart';
import 'package:w3s/services/scan/api_service.dart';

// import '../services/auth_service.dart'; // Si vous avez un service d'authentification

enum AdSubmissionStatus { initial, imageSelected, detecting, detectionSuccess, detectionFailed, submitting, submissionSuccess, submissionFailed }

class AdSubmissionProvider with ChangeNotifier {
  final ApiService _apiService;
  // final AuthService _authService; // Injectez votre service d'auth

  AdSubmissionProvider(this._apiService /*, this._authService*/);

  AdSubmissionStatus _status = AdSubmissionStatus.initial;
  AdSubmissionStatus get status => _status;

  XFile? _imageFile;
  XFile? get imageFile => _imageFile;

  List<String> _detectedWasteTypes = []; // Types bruts de la détection
  List<String> get detectedWasteTypes => List.unmodifiable(_detectedWasteTypes);

  List<String> _editableWasteTypes = []; // Types que l'utilisateur peut modifier
  List<String> get editableWasteTypes => List.unmodifiable(_editableWasteTypes);

  String _quantity = "";
  String get quantity => _quantity;

  String _description = "";
  String get description => _description;

  String _adType = "give"; // 'give' or 'sell'
  String get adType => _adType;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  voidsetImageFile(XFile? file) {
    _imageFile = file;
    if (file != null) {
      _status = AdSubmissionStatus.imageSelected;
      _detectedWasteTypes = []; // Réinitialiser les détections précédentes
      _editableWasteTypes = [];
    } else {
      _status = AdSubmissionStatus.initial;
    }
    notifyListeners();
  }

  Future<void> performWasteDetection() async {
    if (_imageFile == null) return;
    _status = AdSubmissionStatus.detecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.detectWaste(_imageFile!);
      if (result.success) {
        _detectedWasteTypes = result.detectedObjects.map((obj) => obj.type).toSet().toList(); // Uniques
        _editableWasteTypes = List.from(_detectedWasteTypes); // Copie pour édition
        _status = AdSubmissionStatus.detectionSuccess;
      } else {
        _errorMessage = "La détection n'a retourné aucun résultat.";
        _status = AdSubmissionStatus.detectionFailed;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdSubmissionStatus.detectionFailed;
    }
    notifyListeners();
  }

  void addEditableWasteType(String type) {
    if (type.isNotEmpty && !_editableWasteTypes.contains(type)) {
      _editableWasteTypes.add(type);
      notifyListeners();
    }
  }

  void removeEditableWasteType(String type) {
    _editableWasteTypes.remove(type);
    notifyListeners();
  }

  void updateQuantity(String newQuantity) {
    _quantity = newQuantity;
    // Pas besoin de notifyListeners() si le TextField met à jour l'UI directement
  }

  void updateDescription(String newDescription) {
    _description = newDescription;
  }
  void updateAdType(String newType) {
    _adType = newType;
    notifyListeners();
  }


  Future<bool> submitAd() async {
    if (_imageFile == null || _editableWasteTypes.isEmpty || _quantity.isEmpty) {
      _errorMessage = "Veuillez remplir tous les champs requis.";
      _status = AdSubmissionStatus.submissionFailed; // Ou un autre état pour indiquer une validation échouée
      notifyListeners();
      return false;
    }
    _status = AdSubmissionStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    // String? currentUserId = await _authService.getCurrentUserId();
    // if (currentUserId == null) {
    //   _errorMessage = "Utilisateur non authentifié.";
    //   _status = AdSubmissionStatus.submissionFailed;
    //   notifyListeners();
    //   return false;
    // }

    final adData = AdModel(
      userId: "placeholder_user", // Remplacez par currentUserId
      wasteTypes: _editableWasteTypes,
      quantity: _quantity,
      description: _description.isEmpty ? null : _description,
      adType: _adType,
    );

    try {
      final success = await _apiService.postNewAd(adData, _imageFile!);
      if (success) {
        _status = AdSubmissionStatus.submissionSuccess;
        resetForm(); // Optionnel: réinitialiser après succès
      } else {
        _errorMessage = "La soumission de l'annonce a échoué sur le serveur.";
        _status = AdSubmissionStatus.submissionFailed;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AdSubmissionStatus.submissionFailed;
    }
    notifyListeners();
    return _status == AdSubmissionStatus.submissionSuccess;
  }

  void resetForm() {
    _imageFile = null;
    _detectedWasteTypes = [];
    _editableWasteTypes = [];
    _quantity = "";
    _description = "";
    _adType = "give";
    _status = AdSubmissionStatus.initial;
    _errorMessage = null;
    // Ne notifie pas les listeners ici, sauf si vous voulez que l'UI se réinitialise immédiatement.
    // Souvent, la navigation se chargera de "nettoyer" l'état.
  }
}