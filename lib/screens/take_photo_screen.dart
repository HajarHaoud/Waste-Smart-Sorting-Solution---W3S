import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:w3s/providers/ad_submission_provider.dart';
import 'package:w3s/screens/ad_details_form_screen.dart';
import 'package:w3s/services/scan/camera_service.dart';

class TakePhotoScreen extends StatelessWidget {
  const TakePhotoScreen({super.key});

  Future<void> _processImage(BuildContext context, ImageSource source) async {
    final cameraService = Provider.of<CameraService>(context, listen: false);
    final adProvider = Provider.of<AdSubmissionProvider>(context, listen: false);

    final XFile? image = source == ImageSource.camera
        ? await cameraService.pickImageFromCamera()
        : await cameraService.pickImageFromGallery();

    if (image != null) {
      adProvider.voidsetImageFile(image);
      // Naviguer vers un écran intermédiaire pendant la détection ou déclencher directement
      // la détection et naviguer une fois que les résultats sont prêts (ou en cas d'échec).
      // Pour cet exemple, on suppose que la détection est déclenchée ici.
      await adProvider.performWasteDetection();

      // La navigation vers AdDetailsFormScreen se fera en observant AdSubmissionStatus.detectionSuccess
      // dans le widget parent, ou ici directement si la logique est simple.
      if (adProvider.status == AdSubmissionStatus.detectionSuccess || adProvider.status == AdSubmissionStatus.detectionFailed) {
        // Même si la détection échoue (aucun objet trouvé), on peut aller au formulaire
        // pour que l'utilisateur ajoute manuellement les types.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AdDetailsFormScreen()),
        );
      }
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