class DetectedObject {
  final String type;
  final double confidence;
  // final List<double> box; // Si vous voulez les coordonnées des boîtes

  DetectedObject({required this.type, required this.confidence});

  factory DetectedObject.fromJson(Map<String, dynamic> json) {
    return DetectedObject(
      type: json['type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class DetectionResult { // Renommé pour éviter confusion avec un widget
  final bool success;
  final List<DetectedObject> detectedObjects;
  final String? imageWithDetectionsBase64; // Optionnel

  DetectionResult({
    required this.success,
    required this.detectedObjects,
    this.imageWithDetectionsBase64,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    var list = json['detected_objects'] as List?;
    List<DetectedObject> objectsList = list?.map((i) => DetectedObject.fromJson(i as Map<String, dynamic>)).toList() ?? [];
    return DetectionResult(
      success: json['success'] as bool,
      detectedObjects: objectsList,
      imageWithDetectionsBase64: json['image_with_detections_base64'] as String?,
    );
  }
}