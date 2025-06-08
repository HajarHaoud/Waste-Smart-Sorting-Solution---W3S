import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:w3s/screens/marketplace_screen.dart';
import 'package:w3s/providers/ad_submission_provider.dart';
import 'package:w3s/widgets/waste_type_chip.dart';

class AdDetailsFormScreen extends StatefulWidget {
  const AdDetailsFormScreen({super.key});

  @override
  State<AdDetailsFormScreen> createState() => _AdDetailsFormScreenState();
}

class _AdDetailsFormScreenState extends State<AdDetailsFormScreen> {
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _newWasteTypeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  final TextEditingController _locationController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
    _quantityController.text = provider.quantity;
    _descriptionController.text = provider.description;

    provider.addListener(_updateControllersFromProvider);
  }

  void _updateControllersFromProvider() {
    final provider = Provider.of<AdSubmissionProvider>(context, listen: false);
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
    try {
      Provider.of<AdSubmissionProvider>(context, listen: false).removeListener(_updateControllersFromProvider);
    } catch (e) {
      print("Erreur lors du retrait du listener du provider: $e");
    }
    _quantityController.dispose();
    _descriptionController.dispose();
    _newWasteTypeController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showAddWasteTypeDialog(AdSubmissionProvider provider) {
    _newWasteTypeController.clear();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Ajouter un type de déchet"),
          content: TextField(
            controller: _newWasteTypeController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Ex: Bouteille en plastique"),
            onSubmitted: (_) {
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
    if (_formKey.currentState!.validate()) {
      provider.updateQuantity(_quantityController.text.trim());
      provider.updateDescription(_descriptionController.text.trim());

      provider.updateLocation(_locationController.text.trim());

      if (provider.adType == "sell") {
        provider.updatePrice(double.tryParse(_priceController.text.trim()));
      } else {
        provider.updatePrice(null);
      }

      bool success = await provider.submitAd();


      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Annonce publiée avec succès !"), backgroundColor: Colors.green),
          );
          // Navigation vers MarketplaceScreen (correction du chemin)
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MarketplaceScreen()),
                  (Route<dynamic> route) => route.isFirst
          );
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
    return Consumer<AdSubmissionProvider>(
      builder: (context, provider, child) {
        if (provider.processedImageData == null && provider.imageFile == null &&
            provider.status != AdSubmissionStatus.submitting && provider.status != AdSubmissionStatus.detecting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Détails de l'annonce"),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AFFICHAGE DE L'IMAGE
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                      minHeight: 180,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImageWidget(provider),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TYPES DE DÉCHETS DÉTECTÉS
                  Text(
                    "Types de déchets détectés :",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWasteTypesSection(provider),
                  const SizedBox(height: 16),

                  // BOUTON AJOUTER TYPE MANUELLEMENT
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    label: const Text("Ajouter un type manuellement", style: TextStyle(color: Colors.green)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _showAddWasteTypeDialog(provider),
                  ),
                  const SizedBox(height: 24),

                  // CHAMP QUANTITÉ
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: "Quantité *",
                      hintText: "Ex: 1kg, 5 pièces, 2L...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.scale, color: Colors.green),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "La quantité est requise.";
                      }
                      return null;
                    },
                    onChanged: (value) => provider.updateQuantity(value),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Localisation *',
                      hintText: 'Ex: Casablanca, Maarif',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une localisation';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // SECTION ACTION (DONNER/VENDRE)
                  Text(
                    "Action : *",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // BOUTONS RADIO DONNER/VENDRE (SUR LA MÊME LIGNE)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RadioListTile<String>(
                            title: const Text("Donner"),
                            subtitle: const Text("Gratuit"),
                            value: "give",
                            groupValue: provider.adType,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              if (value != null) {
                                provider.updateAdType(value);
                                if (value == "give") {
                                  _priceController.clear();
                                  provider.updatePrice(null);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RadioListTile<String>(
                            title: const Text("Vendre"),
                            subtitle: const Text("Prix fixe"),
                            value: "sell",
                            groupValue: provider.adType,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              if (value != null) {
                                provider.updateAdType(value);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // CHAMP PRIX (AFFICHÉ SI VENDRE EST SÉLECTIONNÉ)
                  if (provider.adType == "sell") ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Prix *",
                        hintText: "Ex: 15.50",
                        suffixText: "MAD",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (provider.adType == "sell") {
                          if (value == null || value.trim().isEmpty) {
                            return "Le prix est requis pour la vente.";
                          }
                          final price = double.tryParse(value.trim());
                          if (price == null || price <= 0) {
                            return "Veuillez entrer un prix valide.";
                          }
                        }
                        return null;
                      },
                      onChanged: (value) {
                        provider.updatePrice(double.tryParse(value.trim()));
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  // CHAMP DESCRIPTION (EN DERNIER)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description (optionnel)",
                      hintText: "Ajoutez des détails sur l'état, l'origine...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.description, color: Colors.green),
                    ),
                    maxLines: 4,
                    onChanged: (value) => provider.updateDescription(value),
                  ),
                  const SizedBox(height: 30),

                  // BOUTON PUBLIER
                  if (provider.status == AdSubmissionStatus.submitting)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.green),
                          SizedBox(height: 8),
                          Text("Publication en cours..."),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _submitForm(provider),
                      child: const Text("Publier l'annonce"),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(AdSubmissionProvider provider) {
    if (provider.status == AdSubmissionStatus.detecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 8),
            Text("Analyse en cours..."),
          ],
        ),
      );
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
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Image.file(
          File(provider.imageFile!.path),
          fit: BoxFit.contain,
          width: double.infinity,
          alignment: Alignment.center,
        ),
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text("Aucune image sélectionnée"),
          ],
        ),
      );
    }
  }

  Widget _buildWasteTypesSection(AdSubmissionProvider provider) {
    if (provider.detections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text(
            "Aucun type de déchet détecté automatiquement.\nVous pouvez en ajouter manuellement.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: provider.detections.map((detection) {
          final String name = detection['name'] ?? 'Inconnu';
          final double confidence = detection['confidence'] ?? 0.0;
          return Chip(
            label: Text(
              '$name (${(confidence * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: Colors.green[100],
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              // Logique pour supprimer la détection si nécessaire
              // provider.removeDetection(detection);
            },
          );
        }).toList(),
      ),
    );
  }
}