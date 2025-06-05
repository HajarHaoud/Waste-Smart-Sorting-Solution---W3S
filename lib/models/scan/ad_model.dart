class AdModel {
  final String? id;
  final String userId; // À gérer avec votre système d'authentification
  // Pour l'image, on enverra le fichier, mais on stockera l'URL après upload
  final List<String> wasteTypes;
  final String quantity;
  final String? description;
  final String adType; // 'give' ou 'sell'
  final DateTime? createdAt;
  final String? imageUrl; // URL de l'image une fois stockée sur le serveur

  AdModel({
    this.id,
    required this.userId, // Sera obtenu depuis l'état d'authentification
    required this.wasteTypes,
    required this.quantity,
    this.description,
    required this.adType,
    this.createdAt,
    this.imageUrl,
  });

  // Pour la création d'annonce, l'image sera envoyée séparément (multipart)
  Map<String, dynamic> toJsonForCreation() {
    return {
      // 'user_id': userId, // Le backend doit l'extraire du token d'authentification
      'waste_types': wasteTypes, // Sera encodé en JSON string pour multipart
      'quantity': quantity,
      'description': description,
      'ad_type': adType,
    };
  }

  // Factory pour créer une AdModel à partir d'un JSON reçu du serveur (pour afficher les annonces)
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      wasteTypes: List<String>.from(json['waste_types'] as List),
      quantity: json['quantity'] as String,
      description: json['description'] as String?,
      adType: json['ad_type'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}