// lib/services/marketplace_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_util; // Pour manipuler les chemins et extensions
import 'package:w3s/constants.dart';
import '../models/marketplace_item.dart';
import 'package:http/http.dart' as http;// Assurez-vous que ce modèle a fromMap, toMap et copyWith

class MarketplaceService {
  static const String _jsonFileName = 'marketplace_items.json'; // Nom du fichier JSON
  static const String _imagesDirName = 'item_images';      // Nom du répertoire pour les images
  static List<MarketplaceItem> _itemsCache = []; // Cache en mémoire
  static bool _isCacheInitialized = false;

  // Obtenir le chemin du répertoire des documents de l'application
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Obtenir le chemin du fichier JSON de sauvegarde
  static Future<File> get _localJsonFile async {
    final appPath = await _localPath;
    return File('$appPath/$_jsonFileName');
  }

  // Obtenir le chemin du répertoire des images
  static Future<Directory> get _localImagesDirectory async {
    final appPath = await _localPath;
    final imagesDir = Directory('$appPath/$_imagesDirName');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  // Charger les articles depuis le fichier JSON vers le cache
  static Future<void> _loadItemsToCache() async {
    if (_isCacheInitialized) return;

    try {
      final file = await _localJsonFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isNotEmpty) {
          final List<dynamic> jsonData = json.decode(contents);
          _itemsCache = jsonData.map((itemData) {
            try {
              return MarketplaceItem.fromMap(itemData as Map<String, dynamic>);
            } catch (e) {
              print('Erreur désérialisation item: $itemData. Erreur: $e');
              return null;
            }
          }).whereType<MarketplaceItem>().toList();
        } else {
          _itemsCache = [];
        }
      } else {
        _itemsCache = [];
      }
      _isCacheInitialized = true;
      print('${_itemsCache.length} articles chargés depuis JSON.');
    } catch (e) {
      print('Erreur chargement articles depuis JSON: $e');
      _itemsCache = [];
      _isCacheInitialized = false;
    }
  }

  // Sauvegarder les articles du cache dans le fichier JSON
  static Future<void> _saveItemsFromCache() async {
    try {
      final file = await _localJsonFile;
      final jsonData = _itemsCache.map((item) => item.toMap()).toList();
      await file.writeAsString(json.encode(jsonData));
      print('${_itemsCache.length} articles sauvegardés en JSON.');
    } catch (e) {
      print('Erreur sauvegarde articles en JSON: $e');
      throw Exception('Impossible de sauvegarder les articles.');
    }
  }

  // Copier le fichier image et retourner son nouveau chemin
  static Future<String> _storeImageFile(File tempImageFile, String itemId) async {
    final imagesDir = await _localImagesDirectory;
    final fileExtension = path_util.extension(tempImageFile.path);
    final newFileName = '${itemId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final newPath = path_util.join(imagesDir.path, newFileName);

    try {
      await tempImageFile.copy(newPath);
      print('Image sauvegardée vers: $newPath');
      return newPath;
    } catch (e) {
      print('Erreur copie fichier image: $e');
      throw Exception('Impossible de sauvegarder l\'image.');
    }
  }

  // Supprimer un fichier image
  static Future<void> _deleteStoredImageFile(String imagePath) async {
    if (imagePath.startsWith('lib/images/')) {
      print('Ignorer suppression image asset: $imagePath');
      return;
    }
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Image supprimée: $imagePath');
      } else {
        print('Image à supprimer non trouvée: $imagePath');
      }
    } catch (e) {
      print('Erreur suppression image: $e');
    }
  }

  // Ajouter un nouvel article (avec image physique)
  static Future<void> addItem(MarketplaceItem itemFromUi, File tempImageFile) async {
    await _loadItemsToCache();

    final String permanentImagePath = await _storeImageFile(tempImageFile, itemFromUi.id);
    final itemToSave = itemFromUi.copyWith(imagePath: permanentImagePath);

    _itemsCache.add(itemToSave);
    await _saveItemsFromCache();
  }

  // Obtenir tous les articles
  static Future<List<MarketplaceItem>> getAllItems() async {
    // Utilise la constante GET_ADS_ENDPOINT de votre fichier constants.dart
    final url = Uri.parse(API_BASE_URL1 + GET_ADS_ENDPOINT);

    try {
      print("MarketplaceService: Appel de l'API à l'adresse $url");

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      print("MarketplaceService: Réponse reçue - Statut ${response.statusCode}");

      if (response.statusCode == 200) {
        // Décoder la réponse JSON, qui est une liste d'objets
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Mapper chaque objet JSON en un objet MarketplaceItem
        final List<MarketplaceItem> items = jsonList
            .map((jsonItem) => MarketplaceItem.fromJson(jsonItem))
            .toList();

        print("MarketplaceService: ${items.length} articles parsés avec succès.");
        return items;

      } else {
        // Si le serveur retourne une erreur
        throw Exception('Échec du chargement des articles (Statut: ${response.statusCode})');
      }
    } catch (e) {
      // Gérer les erreurs de connexion, timeout, etc.
      print("MarketplaceService: Erreur lors de l'appel API - $e");
      throw Exception('Erreur de connexion: $e');
    }
  }


  // Mettre à jour un article (gère aussi le changement d'image)
  static Future<void> updateItem(MarketplaceItem updatedItem, {File? newTempImageFile}) async {
    await _loadItemsToCache();
    final index = _itemsCache.indexWhere((item) => item.id == updatedItem.id);

    if (index != -1) {
      MarketplaceItem itemToUpdate = updatedItem;
      String oldImagePath = _itemsCache[index].imagePath;

      if (newTempImageFile != null) {
        final String newPermanentImagePath = await _storeImageFile(newTempImageFile, updatedItem.id);
        itemToUpdate = updatedItem.copyWith(imagePath: newPermanentImagePath);
        if (oldImagePath != newPermanentImagePath && !oldImagePath.startsWith('lib/images/')) { // Vérifier si ce n'est pas un asset
          await _deleteStoredImageFile(oldImagePath);
        }
      } else {
        // Si aucune nouvelle image n'est fournie, on s'assure que l'imagePath est conservé
        itemToUpdate = updatedItem.copyWith(imagePath: oldImagePath);
      }

      _itemsCache[index] = itemToUpdate;
      await _saveItemsFromCache();
    } else {
      throw Exception('Article non trouvé pour mise à jour (ID: ${updatedItem.id})');
    }
  }

  // Supprimer un article
  static Future<void> deleteItem(String itemId) async {
    await _loadItemsToCache();
    final index = _itemsCache.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      final itemToDelete = _itemsCache[index];
      await _deleteStoredImageFile(itemToDelete.imagePath);
      _itemsCache.removeAt(index);
      await _saveItemsFromCache();
    } else {
      print('Article non trouvé pour suppression (ID: $itemId)');
    }
  }

  // Initialiser avec des données de démonstration si le cache est vide
  static Future<void> initializeWithDemoDataIfEmpty() async {
    await _loadItemsToCache(); // S'assurer que le cache est chargé pour vérifier s'il est vide

    if (_itemsCache.isEmpty) {
      print('Cache vide, initialisation avec données de démo...');
      final demoItems = [
        MarketplaceItem(
          id: 'demo_1',
          title: 'Bouteilles Plastique - À Donner',
          description: 'Lot de bouteilles en plastique propres, parfaites pour le recyclage.',
          wasteType: 'Plastic',
          quantity: '20 bouteilles',
          location: 'Casablanca Centre',
          action: 'Donate',
          imagePath: 'lib/images/demo_plastic.jpg', // Chemin d'asset
          datePosted: DateTime.now().subtract(const Duration(days: 2)),
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
          imagePath: 'lib/images/demo_carton.jpg', // Chemin d'asset
          datePosted: DateTime.now().subtract(const Duration(days: 1)),
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
          imagePath: 'lib/images/demo_glass.jpg', // Chemin d'asset
          datePosted: DateTime.now().subtract(const Duration(hours: 6)),
          userId: 'current_user_placeholder',
        ),
      ];
      // Pour les items de démo, on les ajoute directement car leur imagePath est un asset
      _itemsCache.addAll(demoItems);
      await _saveItemsFromCache(); // Sauvegarder les items de démo dans le JSON
      print('${demoItems.length} articles de démo ajoutés.');
    } else {
      print('Articles existent, pas d\'initialisation de démo.');
    }
  }

  // --- Autres méthodes de récupération ---
  static Future<List<MarketplaceItem>> getUserItems(String userId) async {
    await _loadItemsToCache();
    final userItems = _itemsCache.where((item) => item.userId == userId).toList();
    userItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return userItems;
  }

  static Future<List<MarketplaceItem>> getItemsByWasteType(String wasteType) async {
    await _loadItemsToCache();
    final filteredItems = _itemsCache.where((item) => item.wasteType == wasteType).toList();
    filteredItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return filteredItems;
  }

  static Future<List<MarketplaceItem>> getItemsByAction(String action) async {
    await _loadItemsToCache();
    final filteredItems = _itemsCache.where((item) => item.action == action).toList();
    filteredItems.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return filteredItems;
  }

  static Future<List<MarketplaceItem>> searchItems(String query) async {
    await _loadItemsToCache();
    final searchQuery = query.toLowerCase();
    final searchResults = _itemsCache.where((item) {
      return item.title.toLowerCase().contains(searchQuery) ||
          item.description.toLowerCase().contains(searchQuery) ||
          item.wasteType.toLowerCase().contains(searchQuery) ||
          item.location.toLowerCase().contains(searchQuery);
    }).toList();
    searchResults.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    return searchResults;
  }

  static Future<MarketplaceItem?> getItemById(String itemId) async {
    await _loadItemsToCache();
    try {
      return _itemsCache.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> cleanOldItems() async {
    await _loadItemsToCache();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    List<MarketplaceItem> itemsToRemove = _itemsCache.where((item) => item.datePosted.isBefore(thirtyDaysAgo)).toList();

    for (var item in itemsToRemove) {
      await _deleteStoredImageFile(item.imagePath);
    }

    _itemsCache.removeWhere((item) => item.datePosted.isBefore(thirtyDaysAgo));
    await _saveItemsFromCache();
  }

  static Future<Map<String, int>> getStatistics() async {
    await _loadItemsToCache();
    final stats = <String, int>{
      'total': _itemsCache.length,
      'donate': _itemsCache.where((item) => item.action == 'Donate').length,
      'sell': _itemsCache.where((item) => item.action == 'Sell').length,
    };
    // Assurez-vous que cette liste correspond à celle utilisée dans AddItemScreen
    final wasteTypes = ['Plastic', 'Glass', 'Metal', 'Carton', 'Paper', 'Organic', 'Electronics', 'Textiles', 'Others'];
    for (var type in wasteTypes) {
      stats[type.toLowerCase()] = _itemsCache.where((item) => item.wasteType == type).length;
    }
    return stats;
  }
}