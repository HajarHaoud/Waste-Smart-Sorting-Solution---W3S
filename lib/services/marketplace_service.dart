// lib/services/marketplace_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/marketplace_item.dart';

class MarketplaceService {
  static const String _fileName = 'marketplace_items.json';
  static List<MarketplaceItem> _items = [];

  // Obtenir le chemin du fichier de sauvegarde
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Charger les articles depuis le fichier
  static Future<void> _loadItems() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        _items = jsonData.map((item) => MarketplaceItem.fromMap(item)).toList();
      }
    } catch (e) {
      print('Erreur lors du chargement des articles: $e');
      _items = [];
    }
  }

  // Sauvegarder les articles dans le fichier
  static Future<void> _saveItems() async {
    try {
      final file = await _localFile;
      final jsonData = _items.map((item) => item.toMap()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Erreur lors de la sauvegarde des articles: $e');
      throw Exception('Impossible de sauvegarder les articles');
    }
  }

  // Ajouter un nouvel article
  static Future<void> addItem(MarketplaceItem item) async {
    await _loadItems();
    _items.add(item);
    await _saveItems();
  }

  // Obtenir tous les articles
  static Future<List<MarketplaceItem>> getAllItems() async {
    await _loadItems();
    // Trier par date de publication (plus récent en premier)
    _items.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return List.from(_items);
  }

  // Obtenir les articles d'un utilisateur spécifique
  static Future<List<MarketplaceItem>> getUserItems(String userId) async {
    await _loadItems();
    final userItems = _items.where((item) => item.userId == userId).toList();
    userItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return userItems;
  }

  // Obtenir les articles par type de déchet
  static Future<List<MarketplaceItem>> getItemsByWasteType(String wasteType) async {
    await _loadItems();
    final filteredItems = _items.where((item) => item.wasteType == wasteType).toList();
    filteredItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return filteredItems;
  }

  // Obtenir les articles par action (Donate/Sell)
  static Future<List<MarketplaceItem>> getItemsByAction(String action) async {
    await _loadItems();
    final filteredItems = _items.where((item) => item.action == action).toList();
    filteredItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return filteredItems;
  }

  // Rechercher des articles
  static Future<List<MarketplaceItem>> searchItems(String query) async {
    await _loadItems();
    final searchQuery = query.toLowerCase();
    final searchResults = _items.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
          item.description.toLowerCase().contains(searchQuery) ||
          item.wasteType.toLowerCase().contains(searchQuery) ||
          item.location.toLowerCase().contains(searchQuery);
    }).toList();
    searchResults.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return searchResults;
  }

  // Mettre à jour un article
  static Future<void> updateItem(MarketplaceItem updatedItem) async {
    await _loadItems();
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      await _saveItems();
    } else {
      throw Exception('Article non trouvé');
    }
  }

  // Supprimer un article
  static Future<void> deleteItem(String itemId) async {
    await _loadItems();
    _items.removeWhere((item) => item.id == itemId);
    await _saveItems();
  }

  // Obtenir un article par ID
  static Future<MarketplaceItem?> getItemById(String itemId) async {
    await _loadItems();
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // Nettoyer les anciens articles (plus de 30 jours)
  static Future<void> cleanOldItems() async {
    await _loadItems();
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    _items.removeWhere((item) => item.datePosted.isBefore(thirtyDaysAgo));
    await _saveItems();
  }

  // Obtenir les statistiques
  static Future<Map<String, int>> getStatistics() async {
    await _loadItems();

    final stats = <String, int>{
      'total': _items.length,
      'donate': _items.where((item) => item.action == 'Donate').length,
      'sell': _items.where((item) => item.action == 'Sell').length,
      'plastic': _items.where((item) => item.wasteType == 'Plastic').length,
      'glass': _items.where((item) => item.wasteType == 'Glass').length,
      'metal': _items.where((item) => item.wasteType == 'Metal').length,
      'carton': _items.where((item) => item.wasteType == 'Carton').length,
      'paper': _items.where((item) => item.wasteType == 'Paper').length,
      'others': _items.where((item) => item.wasteType == 'Others').length,
    };

    return stats;
  }

  // Initialiser avec des données de démonstration
  static Future<void> initializeWithDemoData() async {
    await _loadItems();

    if (_items.isEmpty) {
      final demoItems = [
        MarketplaceItem(
          id: 'demo_1',
          title: 'Bouteilles Plastique - À Donner',
          description: 'Lot de bouteilles en plastique propres, parfaites pour le recyclage.',
          wasteType: 'Plastic',
          quantity: '20 bouteilles',
          location: 'Casablanca Centre',
          action: 'Donate',
          imagePath: 'lib/images/demo_plastic.jpg',
          datePosted: DateTime.now().subtract(Duration(days: 2)),
          userId: 'demo_user_1',
        ),
        MarketplaceItem(
          id: 'demo_2',
          title: 'Cartons - À Vendre',
          description: 'Cartons en bon état, idéals pour déménagement ou stockage.',
          wasteType: 'Carton',
          quantity: '15 cartons',
          location: 'Rabat',
          action: 'Sell',
          price: 50.0,
          imagePath: 'lib/images/demo_carton.jpg',
          datePosted: DateTime.now().subtract(Duration(days: 1)),
          userId: 'demo_user_2',
        ),
        MarketplaceItem(
          id: 'demo_3',
          title: 'Bocaux en Verre - À donner',
          description: 'Collection de bocaux en verre de différentes tailles.',
          wasteType: 'Glass',
          quantity: '12 bocaux',
          location: 'Berrechid',
          action: 'Donate',
          imagePath: 'lib/images/demo_glass.jpg',
          datePosted: DateTime.now().subtract(Duration(hours: 6)),
          userId: 'current_user',
        ),
      ];

      for (final item in demoItems) {
        await addItem(item);
<<<<<<< HEAD
      }
    }
  }
}
=======
}
}
   }
}
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
