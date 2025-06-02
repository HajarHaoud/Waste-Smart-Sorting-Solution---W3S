// lib/models/marketplace_item.dart
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
