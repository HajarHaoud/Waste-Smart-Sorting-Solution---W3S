import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:w3s/providers/ad_submission_provider.dart';
import 'package:w3s/screens/ad_details_form_screen.dart';
// import 'package:w3s/services/scan/camera_service.dart'; // Si vous utilisez toujours CameraService, assurez-vous qu'il est bien importé

// Assurez-vous que AdSubmissionStatus est accessible, si ce fichier ne l'importe pas directement,
// assurez-vous qu'il est bien défini et exporté depuis le provider.
// Si l'enum est dans le provider et que le provider est importé, cela devrait suffire.

class TakePhotoScreen extends StatelessWidget {
  const TakePhotoScreen({super.key});

  Future<void> _processImage(BuildContext context, ImageSource source) async {
    // final cameraService = Provider.of<CameraService>(context, listen: false); // Si vous utilisez CameraService
    final adProvider = Provider.of<AdSubmissionProvider>(context, listen: false);

    final ImagePicker _picker = ImagePicker(); // Utilisez ImagePicker directement si CameraService n'est plus utilisé
    final XFile? image = source == ImageSource.camera
        ? await _picker.pickImage(source: ImageSource.camera) // Utilisez _picker
        : await _picker.pickImage(source: ImageSource.gallery); // Utilisez _picker

    if (image != null) {
      adProvider.setImageFile(image); // Correction: utilise la méthode renommée
      // Naviguer vers un écran intermédiaire pendant la détection ou déclencher directement
      // la détection et naviguer une fois que les résultats sont prêts (ou en cas d'échec).

      await adProvider.performWasteDetection();

      // La navigation vers AdDetailsFormScreen se fera en observant AdSubmissionStatus.detectionSuccess
      // ou detectionFailed (pour édition manuelle) dans le widget parent, ou ici directement.
      // Utilisez le listener dans le widget build ou ici si c'est simple.

      // Option 1: Naviguer ici après la détection (plus simple pour le moment)
      // Vérifiez l'état du provider après la détection.
      if (adProvider.status == AdSubmissionStatus.detectionSuccess || adProvider.status == AdSubmissionStatus.detectionFailed) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdDetailsFormScreen()),
        );
      } else if (adProvider.status == AdSubmissionStatus.error) {
        // Gérer l'erreur si la détection a échoué pour une raison technique
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la détection: ${adProvider.errorMessage}"), backgroundColor: Colors.red),
        );
      }


      // Option 2 (alternative, plus propre avec un listener):
      // Dans le build de TakePhotoScreen, écouter les changements de status
      // et naviguer quand status devient detectionSuccess ou detectionFailed.
      // Cela est plus robuste si performWasteDetection prend du temps.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer pour réagir aux changements d'état, par ex. pour afficher un loader
    final adStatus = context.watch<AdSubmissionProvider>().status;

    return Scaffold(
      appBar: AppBar(title: Text("Prendre une photo du déchet")),
      body: Center(
        child: adStatus == AdSubmissionStatus.detecting
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Détection en cours..."),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Utiliser la Caméra"),
              onPressed: () => _processImage(context, ImageSource.camera),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text("Choisir de la Galerie"),
              onPressed: () => _processImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}