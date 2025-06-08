// lib/models/marketplace_item.dart

// AJOUTEZ CET IMPORT
import 'package:w3s/constants.dart';

class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final String wasteType;
  final String quantity;
  final String location;
  final String action; // 'Donate' ou 'Sell'
  final double? price; // null si c'est pour donner
  final String imagePath;
  final DateTime datePosted;
  final String userId;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.wasteType,
    required this.quantity,
    required this.location,
    required this.action,
    this.price,
    required this.imagePath,
    required this.datePosted,
    required this.userId,
  });

  // Convertir en Map pour la sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'wasteType': wasteType,
      'quantity': quantity,
      'location': location,
      'action': action,
      'price': price,
      'imagePath': imagePath,
      'datePosted': datePosted.millisecondsSinceEpoch,
      'userId': userId,
    };
  }

  // Créer depuis une Map
  factory MarketplaceItem.fromMap(Map<String, dynamic> map) {
    return MarketplaceItem(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      wasteType: map['wasteType'],
      quantity: map['quantity'],
      location: map['location'],
      action: map['action'],
      price: map['price']?.toDouble(),
      imagePath: map['imagePath'],
      datePosted: DateTime.fromMillisecondsSinceEpoch(map['datePosted']),
      userId: map['userId'],
    );
  }

  // =========================================================================
  //  IMPLÉMENTATION DE fromJson AVEC TRADUCTION DES DONNÉES
  // =========================================================================
  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> typesFromApi = json['wasteTypes'] ?? [];
    final String translatedWasteType = typesFromApi.isNotEmpty ? typesFromApi.first.toString() : 'Divers';

    final String apiAdType = json['adType'] ?? 'give';
    final String translatedAction = apiAdType == 'give' ? 'Donate' : 'Sell';

    final String apiImageUrl = json['imageUrl'] ?? '';
    final String fullImagePath = apiImageUrl.startsWith('http') ? apiImageUrl : (API_BASE_URL1 + apiImageUrl);

    final DateTime translatedDatePosted = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();

    final String generatedTitle = translatedWasteType.isNotEmpty
        ? (translatedWasteType[0].toUpperCase() + translatedWasteType.substring(1))
        : 'Annonce';

    return MarketplaceItem(
      id: json['id'] as String? ?? '',
      title: generatedTitle,
      description: json['description'] as String? ?? '',
      wasteType: translatedWasteType,
      quantity: json['quantity'] as String? ?? 'N/A',
      location: 'Non spécifié',
      action: translatedAction,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      imagePath: fullImagePath,
      datePosted: translatedDatePosted,
      userId: 'user_placeholder',
    );
  }

  // Créer une copie avec modifications
  MarketplaceItem copyWith({
    String? id,
    String? title,
    String? description,
    String? wasteType,
    String? quantity,
    String? location,
    String? action,
    double? price,
    String? imagePath,
    DateTime? datePosted,
    String? userId,
  }) {
    return MarketplaceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      wasteType: wasteType ?? this.wasteType,
      quantity: quantity ?? this.quantity,
      location: location ?? this.location,
      action: action ?? this.action,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      datePosted: datePosted ?? this.datePosted,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'MarketplaceItem(id: $id, title: $title, wasteType: $wasteType, action: $action, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MarketplaceItem &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.wasteType == wasteType &&
        other.quantity == quantity &&
        other.location == location &&
        other.action == action &&
        other.price == price &&
        other.imagePath == imagePath &&
        other.datePosted == datePosted &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    description.hashCode ^
    wasteType.hashCode ^
    quantity.hashCode ^
    location.hashCode ^
    action.hashCode ^
    price.hashCode ^
    imagePath.hashCode ^
    datePosted.hashCode ^
    userId.hashCode;
  }
}