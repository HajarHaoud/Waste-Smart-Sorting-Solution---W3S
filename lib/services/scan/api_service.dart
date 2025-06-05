import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:w3s/constants.dart';
import 'package:w3s/models/scan/ad_model.dart';
import 'package:w3s/models/scan/detection_result_model.dart';

class ApiService {
  final http.Client client;
  // Vous pourriez injecter un service d'authentification pour obtenir le token JWT
  // final AuthService authService;

  ApiService({required this.client /*, required this.authService*/});

  Future<DetectionResult> detectWaste(XFile imageFile) async {
    final uri = Uri.parse(API_BASE_URL1 + DETECT_WASTE_ENDPOINT);
    try {
      final bytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(bytes);
      // Assurez-vous que votre backend attend ce format exact pour le payload Base64
      final payload = {'image': 'data:image/jpeg;base64,$base64Image'};

      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return DetectionResult.fromJson(jsonDecode(response.body));
      } else {
        print("Detect API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Échec de la détection des déchets');
      }
    } catch (e) {
      print("Detect API Exception: $e");
      throw Exception('Erreur de connexion ou de traitement de la détection');
    }
  }

  Future<bool> postNewAd(AdModel adData, XFile imageFile) async {
    final uri = Uri.parse(API_BASE_URL1 + POST_AD_ENDPOINT);
    try {
      var request = http.MultipartRequest('POST', uri);

      // Ajouter l'image
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Ce nom doit correspondre à ce que votre backend attend
        imageFile.path,
        // filename: imageFile.name, // Optionnel mais bon à avoir
      ));

      // Ajouter les autres champs
      // Le backend doit s'attendre à ce que 'waste_types' soit une chaîne JSON
      request.fields['waste_types'] = jsonEncode(adData.wasteTypes);
      request.fields['quantity'] = adData.quantity;
      if (adData.description != null && adData.description!.isNotEmpty) {
        request.fields['description'] = adData.description!;
      }
      request.fields['ad_type'] = adData.adType;
      // request.fields['user_id'] = adData.userId; // Le backend devrait l'obtenir du token

      // Ajouter le token d'authentification si nécessaire
      // String? token = await authService.getToken();
      // if (token != null) {
      //   request.headers['Authorization'] = 'Bearer $token';
      // }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // ou analyser la réponse si le backend renvoie l'annonce créée
      } else {
        print("Post Ad API Error: ${response.statusCode} - ${response.body}");
        throw Exception('Échec de la publication de l\'annonce');
      }
    } catch (e) {
      print("Post Ad API Exception: $e");
      throw Exception('Erreur de connexion ou de publication de l\'annonce');
    }
  }
}