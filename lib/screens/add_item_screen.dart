// lib/screens/add_item_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/marketplace_item.dart'; // Assurez-vous que ce chemin est correct et que le modèle a copyWith, toMap, fromMap
import '../services/marketplace_service.dart'; // Assurez-vous que ce chemin est correct

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // State variables
  XFile? _selectedImage;
  String _selectedWasteType = 'Plastic'; // Valeur par défaut
  String _selectedAction = 'Donate'; // 'Donate' ou 'Sell'
  bool _isLoading = false;

  static const List<String> _wasteTypes = [
    'Plastic', 'Glass', 'Metal', 'Carton', 'Paper', 'Organic', 'Electronics', 'Textiles', 'Others'
  ];

  // --- Thèmes et Styles (Minimaliste avec accent vert) ---
  final Color _accentColor = const Color(0xFF4CAF50); // Vert comme couleur d'accent
  final Color _appBarBackgroundColor = Colors.white; // AppBar blanche
  final Color _scaffoldBackgroundColor = Colors.grey.shade100; // Fond général
  final Color _textColor = Colors.black87; // Texte principal
  final Color _appBarForegroundColor = Colors.black87; // Texte et icônes de l'AppBar
  final Color _hintColor = Colors.grey.shade600;
  final BorderRadius _borderRadius = BorderRadius.circular(12.0);

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: _hintColor.withOpacity(0.7)),
      labelStyle: TextStyle(color: _textColor),
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(color: _accentColor, width: 2.0), // Bordure focus avec couleur d'accent
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
  // --- Fin Thèmes et Styles ---

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      _showFeedbackSnackBar('Erreur de sélection d\'image: ${e.toString()}', isError: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _scaffoldBackgroundColor, // Fond du BottomSheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: _accentColor), // Icône avec couleur d'accent
                title: Text('Choisir depuis la galerie', style: TextStyle(color: _textColor)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: _accentColor), // Icône avec couleur d'accent
                title: Text('Prendre une photo', style: TextStyle(color: _textColor)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade600 : _accentColor, // Snackbar utilise l'accent
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      _showFeedbackSnackBar('Veuillez sélectionner une image pour votre article.', isError: true);
      return;
    }

    if (_selectedAction == 'Sell' && (_priceController.text.isEmpty || (double.tryParse(_priceController.text) ?? 0) <= 0)) {
      _showFeedbackSnackBar('Veuillez entrer un prix valide pour la vente.', isError: true);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final String itemId = DateTime.now().millisecondsSinceEpoch.toString();
      final item = MarketplaceItem(
        id: itemId,
        title: _titleController.text.isNotEmpty ? _titleController.text : '${_selectedWasteType} à ${_selectedAction == 'Donate' ? 'donner' : 'vendre'}',
        description: _descriptionController.text,
        wasteType: _selectedWasteType,
        quantity: _quantityController.text,
        location: _locationController.text,
        action: _selectedAction,
        price: _selectedAction == 'Sell' ? double.tryParse(_priceController.text) : null,
        imagePath: _selectedImage!.path,
        datePosted: DateTime.now(),
        userId: 'current_user_placeholder',
      );

      await MarketplaceService.addItem(item, File(_selectedImage!.path));

      _showFeedbackSnackBar('Article publié avec succès !');
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      _showFeedbackSnackBar('Erreur lors de la publication : ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackgroundColor, // Fond général défini
      appBar: AppBar(
        title: Text('Ajouter un article', style: TextStyle(fontWeight: FontWeight.w500, color: _appBarForegroundColor)),
        backgroundColor: _appBarBackgroundColor, // AppBar blanche
        foregroundColor: _appBarForegroundColor, // Pour l'icône de retour
        elevation: 0.5, // Ombre très subtile ou 0.0 pour plate
        surfaceTintColor: _appBarBackgroundColor, // Important pour Material 3
        iconTheme: IconThemeData(color: _appBarForegroundColor), // Couleur de l'icône de retour
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_accentColor))) // Progresse avec accent
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSectionTitle('Photo de l\'article'),
              _buildImagePicker(),
              const SizedBox(height: 24),

              _buildSectionTitle('Détails de l\'article'),
              TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Titre', hint: 'Ex: Lot de bouteilles en verre (max 50 caractères)'),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer un titre pour votre article.';
                    }
                    return null;
                  }
              ),
              const SizedBox(height: 16), // Les SizedBox sont bons, 16 est un espacement standard

              DropdownButtonFormField<String>(
                value: _selectedWasteType,
                decoration: _inputDecoration('Type de déchet'),
                items: _wasteTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null && mounted) {
                    setState(() => _selectedWasteType = newValue);
                  }
                },
                validator: (value) => value == null ? 'Veuillez sélectionner un type' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: _inputDecoration('Quantité', hint: 'Ex: 5 kg, 10 pièces...'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Veuillez entrer la quantité' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Localisation', hint: 'Votre ville ou quartier'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Veuillez entrer la localisation' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Action'),
              _buildActionSelector(),

              if (_selectedAction == 'Sell') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Prix (DH)', hint: '0.00'),
                  validator: (value) {
                    if (_selectedAction == 'Sell') {
                      if (value == null || value.trim().isEmpty) return 'Veuillez entrer un prix';
                      final price = double.tryParse(value);
                      if (price == null) return 'Veuillez entrer un nombre valide';
                      if (price <= 0) return 'Le prix doit être positif';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              _buildSectionTitle('Description (optionnel)'),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Description', hint: 'Plus de détails sur votre article...'),
                maxLines: 4,
                minLines: 2,
                maxLength: 300,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor, // Bouton avec la couleur d'accent
                  foregroundColor: Colors.white, // Texte du bouton
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: _borderRadius),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                child: const Text('Publier l\'article'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textColor),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white, // Fond du picker d'image
          borderRadius: _borderRadius,
          border: Border.all(
            color: _selectedImage == null ? Colors.grey.shade400 : _accentColor.withOpacity(0.7),
            width: _selectedImage == null ? 1.5 : 2.0, // Bordure plus marquée si image sélectionnée
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
          borderRadius: _borderRadius,
          child: Image.file(
            File(_selectedImage!.path),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )
            : Center( // Placeholder
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 50, color: _hintColor),
              const SizedBox(height: 8),
              Text('Ajouter une photo', style: TextStyle(color: _hintColor, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionSelector() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, // Fond du sélecteur
          borderRadius: _borderRadius,
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRadioAction('Donate', 'Donner', Icons.volunteer_activism_outlined),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300), // Séparateur
          Expanded(
            child: _buildRadioAction('Sell', 'Vendre', Icons.sell_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioAction(String value, String title, IconData icon) {
    final bool isSelected = _selectedAction == value;
    return Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
              if (mounted) setState(() => _selectedAction = value);
            },
            borderRadius: value == 'Donate' ?
            BorderRadius.only(topLeft: _borderRadius.topLeft, bottomLeft: _borderRadius.bottomLeft) :
            BorderRadius.only(topRight: _borderRadius.topRight, bottomRight: _borderRadius.bottomRight),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? _accentColor.withOpacity(0.1) : Colors.transparent, // Fond léger avec accent si sélectionné
                borderRadius: value == 'Donate' ?
                BorderRadius.only(topLeft: _borderRadius.topLeft, bottomLeft: _borderRadius.bottomLeft) :
                BorderRadius.only(topRight: _borderRadius.topRight, bottomRight: _borderRadius.bottomRight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: isSelected ? _accentColor : _hintColor, size: 20), // Icône avec accent si sélectionné
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? _accentColor : _textColor, // Texte avec accent si sélectionné
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            ),
       );
   }
}
