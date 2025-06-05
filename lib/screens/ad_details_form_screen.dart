import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // Pour File()

import '../providers/ad_submission_provider.dart';
import '../widgets/waste_type_chip.dart'; // Assurez-vous que le chemin est correct

class AdDetailsFormScreen extends StatefulWidget {
  const AdDetailsFormScreen({super.key});

  @override
  State<AdDetailsFormScreen> createState() => _AdDetailsFormScreenState();
}

class _AdDetailsFormScreenState extends State<AdDetailsFormScreen> {
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newWasteTypeController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Pour la validation du formulaire

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs avec les valeurs du provider si elles existent déjà
    // Cela est utile si l'utilisateur navigue en arrière puis revient.
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
    _quantityController.text = provider.quantity;
    _descriptionController.text = provider.description;

    // Écouter les changements dans le provider pour mettre à jour les champs si nécessaire
    // (par exemple, si le provider est réinitialisé ailleurs)
    provider.addListener(_updateControllersFromProvider);
  }

  void _updateControllersFromProvider() {
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
    // Vérifier si le widget est toujours monté pour éviter les erreurs
    if (mounted) {
      if (_quantityController.text != provider.quantity) {
        _quantityController.text = provider.quantity;
      }
      if (_descriptionController.text != provider.description) {
        _descriptionController.text = provider.description;
      }
    }
  }


  @override
  void dispose() {
    // Retirer l'écouteur
    Provider.of<AdSubmissionProvider>(context, listen: false).removeListener(_updateControllersFromProvider);

    _quantityController.dispose();
    _descriptionController.dispose();
    _newWasteTypeController.dispose();
    super.dispose();
  }

  void _showAddWasteTypeDialog(AdSubmissionProvider provider) {
    _newWasteTypeController.clear(); // S'assurer que le champ est vide
    showDialog(
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
                provider.addEditableWasteType(_newWasteTypeController.text.trim());
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
                  provider.addEditableWasteType(_newWasteTypeController.text.trim());
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
      // La mise à jour des valeurs de quantité et description via onSaved n'est
      // plus nécessaire si on les met à jour via onChanged ou directement
      // avant d'appeler submitAd. Les contrôleurs sont la source de vérité.
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
        // Si aucun fichier image n'est sélectionné (par exemple, accès direct à cet écran),
        // on pourrait afficher un message ou rediriger.
        if (provider.imageFile == null && provider.status != AdSubmissionStatus.submitting) {
          // Optionnel: retourner à l'écran précédent ou afficher un placeholder
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              // Navigator.of(context).pop();
            }
          });
          return Scaffold(
            appBar: AppBar(title: const Text("Détails de l'annonce")),
            body: const Center(child: Text("Aucune image sélectionnée. Veuillez recommencer.")),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Compléter l'annonce"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Optionnel : demander confirmation avant de quitter si des données ont été saisies
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (provider.imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(provider.imageFile!.path),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),

                  Text(
                    "Types de déchets (appuyez pour supprimer, ajoutez si besoin) :",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (provider.editableWasteTypes.isEmpty)
                    const Text("Aucun type de déchet détecté ou ajouté."),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: provider.editableWasteTypes.map((type) {
                      return WasteTypeChip( // Utilisation du widget personnalisé
                        label: type,
                        onDeleted: () {
                          provider.removeEditableWasteType(type);
                        },
                      );
                    }).toList(),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Ajouter un type manuellement"),
                    onPressed: () => _showAddWasteTypeDialog(provider),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantité *",
                      hintText: "Ex: 1 grand sac, environ 5kg, 3 objets",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "La quantité est requise.";
                      }
                      return null;
                    },
                    // `onChanged` n'est plus strictement nécessaire ici si on lit la valeur
                    // du contrôleur au moment de la soumission.
                    // onChanged: (value) => provider.updateQuantity(value),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description (optionnel)",
                      hintText: "Plus de détails sur les déchets...",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    // onChanged: (value) => provider.updateDescription(value),
                  ),
                  const SizedBox(height: 20),

                  Text("Action : *", style: Theme.of(context).textTheme.titleMedium),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text("Donner"),
                          value: "give",
                          groupValue: provider.adType,
                          onChanged: (value) {
                            if (value != null) provider.updateAdType(value);
                          },
                        ),
                      ),
                      // Pour le moment, "Vendre" est désactivé. Vous l'activerez plus tard.
                      // Expanded(
                      //   child: RadioListTile<String>(
                      //     title: Text("Vendre"),
                      //     value: "sell",
                      //     groupValue: provider.adType,
                      //     onChanged: (value) {
                      //       // TODO: Vérifier si l'utilisateur a le droit de vendre (abonnement)
                      //       if (value != null) provider.updateAdType(value);
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (provider.status == AdSubmissionStatus.submitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () => _submitForm(provider),
                      child: const Text("Publier l'annonce"),
                    ),

                  if (provider.errorMessage != null && provider.status == AdSubmissionStatus.submissionFailed)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}