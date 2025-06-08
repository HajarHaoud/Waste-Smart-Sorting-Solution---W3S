import 'dart:io'; // Pour File, si vous avez un fallback sur Image.file
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Pour base64Decode si nécessaire (mais Image.memory gère déjà la base64)
import 'dart:typed_data'; // Pour Uint8List

import 'package:w3s/providers/ad_submission_provider.dart'; // Adaptez le chemin
import 'package:w3s/widgets/waste_type_chip.dart'; // Assurez-vous que le chemin est correct

class AdDetailsFormScreen extends StatefulWidget { // Revenir à StatefulWidget pour gérer le formulaire
  const AdDetailsFormScreen({super.key});

  @override
  State<AdDetailsFormScreen> createState() => _AdDetailsFormScreenState();
}

class _AdDetailsFormScreenState extends State<AdDetailsFormScreen> {
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newWasteTypeController = TextEditingController(); // Contrôleur pour ajouter un type manuellement
  final _formKey = GlobalKey<FormState>(); // Pour la validation du formulaire

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs du provider si elles existent déjà
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
    _quantityController.text = provider.quantity;
    _descriptionController.text = provider.description;

    // Écouter les changements dans le provider pour mettre à jour les champs si nécessaire
    provider.addListener(_updateControllersFromProvider);
  }

  void _updateControllersFromProvider() {
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
    if (mounted) { // Vérifier si le widget est toujours monté
      // Mettre à jour les contrôleurs UNIQUEMENT si les valeurs du provider changent
      if (_quantityController.text != provider.quantity) {
        _quantityController.text = provider.quantity;
      }
      if (_descriptionController.text != provider.description) {
        _descriptionController.text = provider.description;
      }
      // Les types de déchets sont gérés directement par le Consumer
    }
  }


  @override
  void dispose() {
    // Retirer l'écouteur
    try {
      Provider.of<AdSubmissionProvider>(context, listen: false).removeListener(_updateControllersFromProvider);
    } catch (e) {
      // Gérer l'erreur si le provider n'est plus accessible (rare mais possible)
      print("Erreur lors du retrait du listener du provider: $e");
    }
    _quantityController.dispose();
    _descriptionController.dispose();
    _newWasteTypeController.dispose();
    super.dispose();
  }

  void _showAddWasteTypeDialog(AdSubmissionProvider provider) {
    _newWasteTypeController.clear(); // S'assurer que le champ est vide
    showDialog( // Utiliser le contexte du widget principal
      context: context,
      builder: (BuildContext dialogContext) { // Utiliser un contexte différent pour le dialogue
        return AlertDialog(
          title: const Text("Ajouter un type de déchet"),
          content: TextField(
            controller: _newWasteTypeController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Ex: Bouteille en plastique"),
            onSubmitted: (_) { // Permet d'ajouter avec la touche "Entrée"
              if (_newWasteTypeController.text.trim().isNotEmpty) {
                provider.addEditableWasteType(_newWasteTypeController.text.trim()); // Utiliser la méthode du provider
              }
              Navigator.of(dialogContext).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text("Ajouter"),
              onPressed: () {
                if (_newWasteTypeController.text.trim().isNotEmpty) {
                  provider.addEditableWasteType(_newWasteTypeController.text.trim()); // Utiliser la méthode du provider
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm(AdSubmissionProvider provider) async {
    if (_formKey.currentState!.validate()) { // Déclenche la validation
      // Mettre à jour les valeurs dans le provider avant de soumettre
      provider.updateQuantity(_quantityController.text.trim());
      provider.updateDescription(_descriptionController.text.trim());

      bool success = await provider.submitAd();

      if (mounted) { // Vérifier si le widget est toujours dans l'arbre
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Annonce publiée avec succès !"), backgroundColor: Colors.green),
          );
          // Naviguer en arrière ou vers la page d'accueil/marketplace
          // Pop jusqu'à la première route pour un "reset" propre du flux de soumission
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Optionnel: reset le provider après navigation si submitAd ne le fait pas
          provider.resetForm();

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(provider.errorMessage ?? "Échec de la publication."),
                backgroundColor: Colors.red),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez corriger les erreurs dans le formulaire."), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser Consumer pour reconstruire uniquement les parties nécessaires de l'UI
    // ou `context.watch<AdSubmissionProvider>()` si vous préférez.
    return Consumer<AdSubmissionProvider>(
      builder: (context, provider, child) {
        // Si aucun fichier image traitée n'est disponible après détection et pas d'image originale
        if (provider.processedImageData == null && provider.imageFile == null && provider.status != AdSubmissionStatus.submitting && provider.status != AdSubmissionStatus.detecting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              // Retourner à l'écran précédent si pas d'image et pas en cours de traitement
              Navigator.of(context).pop();
            }
          });
          return Scaffold(
            appBar: AppBar(title: const Text("Détails de l'annonce")),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AFFICHER L'IMAGE ICI (amélioré)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                      minHeight: 180,
                    ),
                    child: Consumer<AdSubmissionProvider>(
                      builder: (context, provider, child) {
                        if (provider.status == AdSubmissionStatus.detecting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (provider.processedImageData != null) {
                          return InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.memory(
                              provider.processedImageData!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              alignment: Alignment.center,
                            ),
                          );
                        } else if (provider.imageFile != null) {
                          return Image.file(
                            File(provider.imageFile!.path),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            alignment: Alignment.center,
                          );
                        } else {
                          return Center(child: Text("Aucune image sélectionnée"));
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),

                  // AFFICHAGE DES TYPES DE DÉCHETS
                  Text(
                    "Types de déchets (appuyez pour supprimer, ajoutez si besoin) :",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Consumer<AdSubmissionProvider>(
                      builder: (context, provider, child) {
                        if (provider.detections.isEmpty) {
                          return Text("Aucun type de déchet détecté ou ajouté.");
                        }
                        // Ici, vous listeriez les détections (provider.detections)
                        // Exemple simple:
                        return Wrap(
                          spacing: 8.0,
                          children: provider.detections.map((detection) {
                            // Supposons que 'detection' est un Map et a une clé 'name'
                            final String name = detection['name'] ?? 'Inconnu';
                            final double confidence = detection['confidence'] ?? 0.0;
                            return Chip(label: Text('$name (${(confidence * 100).toStringAsFixed(1)}%)'));
                          }).toList(),
                        );
                      }
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_circle_outline),
                    label: Text("Ajouter un type manuellement"),
                    onPressed: () {
                      _showAddWasteTypeDialog(provider);
                    },
                  ),
                  SizedBox(height: 20),

                  // Vos autres champs de formulaire...
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: "Quantité *"),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: "Description (optionnel)"),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  Text("Action : *", style: Theme.of(context).textTheme.titleMedium),
                  // ... vos boutons radio ...
                  SizedBox(height: 30),
                  ElevatedButton(
                    child: Text("Publier l'annonce"),
                    onPressed: () {
                      _submitForm(provider);
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Détails de l'annonce")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AFFICHER L'IMAGE ICI (amélioré)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                    minHeight: 180,
                  ),
                  child: Consumer<AdSubmissionProvider>(
                    builder: (context, provider, child) {
                      if (provider.status == AdSubmissionStatus.detecting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (provider.processedImageData != null) {
                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Image.memory(
                            provider.processedImageData!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            alignment: Alignment.center,
                          ),
                        );
                      } else if (provider.imageFile != null) {
                        return Image.file(
                          File(provider.imageFile!.path),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          alignment: Alignment.center,
                        );
                      } else {
                        return Center(child: Text("Aucune image sélectionnée"));
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),

                // AFFICHAGE DES TYPES DE DÉCHETS
                Text(
                  "Types de déchets (appuyez pour supprimer, ajoutez si besoin) :",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Consumer<AdSubmissionProvider>(
                    builder: (context, provider, child) {
                      if (provider.detections.isEmpty) {
                        return Text("Aucun type de déchet détecté ou ajouté.");
                      }
                      // Ici, vous listeriez les détections (provider.detections)
                      // Exemple simple:
                      return Wrap(
                        spacing: 8.0,
                        children: provider.detections.map((detection) {
                          // Supposons que 'detection' est un Map et a une clé 'name'
                          final String name = detection['name'] ?? 'Inconnu';
                          final double confidence = detection['confidence'] ?? 0.0;
                          return Chip(label: Text('$name (${(confidence * 100).toStringAsFixed(1)}%)'));
                        }).toList(),
                      );
                    }
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add_circle_outline),
                  label: Text("Ajouter un type manuellement"),
                  onPressed: () {
                    _showAddWasteTypeDialog(provider);
                  },
                ),
                SizedBox(height: 20),

                // Vos autres champs de formulaire...
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: "Quantité *"),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Description (optionnel)"),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Text("Action : *", style: Theme.of(context).textTheme.titleMedium),
                // ... vos boutons radio ...
                SizedBox(height: 30),
                ElevatedButton(
                  child: Text("Publier l'annonce"),
                  onPressed: () {
                    _submitForm(provider);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}