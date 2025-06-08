// lib/widgets/marketplace_item_card.dart
import 'package:flutter/material.dart';
import 'dart:convert'; // <<< 1. AJOUT DE CET IMPORT
import '../models/marketplace_item.dart';

class MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item;
  final VoidCallback onTap;

  const MarketplaceItemCard({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  Color _getActionColor() {
    // Correction pour correspondre à la traduction dans le modèle
    return item.action == 'Donner' ? Colors.green : Colors.lightGreen;
  }

  IconData _getWasteTypeIcon() {
    // Utiliser toLowerCase pour être insensible à la casse (cardboard vs Cardboard)
    switch (item.wasteType.toLowerCase()) {
      case 'plastic':
        return Icons.local_drink;
      case 'glass':
        return Icons.wine_bar;
      case 'metal':
        return Icons.hardware;
      case 'cardboard': // Correction du nom 'Carton' en 'cardboard'
        return Icons.inventory_2;
      case 'paper':
        return Icons.description;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec overlay d'information
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image principale
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      // Appel à la nouvelle méthode _buildImage
                      child: _buildImage(),
                    ),
                  ),

                  // Badge d'action (Donner/Vendre)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getActionColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        // Correction pour correspondre à la traduction
                        item.action.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Badge de temps
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTimeAgo(item.datePosted),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  // Prix (si vente)
                  if (item.price != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.price!.toStringAsFixed(0)} DH',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Informations de l'article
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Mieux répartir l'espace
                  children: [
                    // Type de déchet avec icône
                    Row(
                      children: [
                        Icon(
                          _getWasteTypeIcon(),
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            // Mettre la première lettre en majuscule pour l'affichage
                            item.wasteType.isNotEmpty ? item.wasteType[0].toUpperCase() + item.wasteType.substring(1) : '',
                            style: TextStyle(
                              fontSize: 14, // Légèrement plus grand
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Quantité
                    Text(
                      'Quantité: ${item.quantity}', // Ajout d'un label pour le contexte
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Localisation
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // <<< 2. REMPLACEMENT DE L'ANCIENNE MÉTHODE _buildImage() PAR CELLE-CI >>>
  Widget _buildImage() {
    final String base64String = item.imagePath;

    print("---- DÉBOGAGE DE L'IMAGE POUR L'ITEM ID: ${item.id} ----");
    print("Le imagePath est-il vide ? ${base64String.isEmpty}");
    print("Le imagePath commence-t-il par 'data:image' ? ${base64String.startsWith('data:image')}");
    // Affiche les 100 premiers caractères pour voir à quoi la chaîne ressemble
    print("Début du contenu de imagePath: ${base64String.substring(0, base64String.length > 100 ? 100 : base64String.length)}");
    print("-------------------------------------------------");

    // Vérifie si la chaîne est valide et commence par le préfixe attendu.
    if (base64String.isNotEmpty && base64String.startsWith('data:image')) {
      try {
        // Sépare le préfixe "data:image/jpeg;base64," du reste de la chaîne.
        final String imagePayload = base64String.split(',')[1];
        // Décode la chaîne base64 en octets.
        final imageBytes = base64Decode(imagePayload);

        // Affiche l'image depuis la mémoire.
        return Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          gaplessPlayback: true, // Évite un clignotement lors du rechargement
        );
      } catch (e) {
        // Si le décodage échoue, affiche le placeholder.
        print("Erreur de décodage de l'image Base64 pour l'item ${item.id}: $e");
        return _buildPlaceholder();
      }
    }

    // Si la chaîne n'est pas valide, affiche le placeholder par défaut.
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          _getWasteTypeIcon(),
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}