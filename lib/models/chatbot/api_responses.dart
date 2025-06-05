class BackendChatResponse {
  final String response;
  final int userPoints;
  final List<String> badges;
  final String status;

  BackendChatResponse({
    required this.response,
    required this.userPoints,
    required this.badges,
    required this.status,
  });

  factory BackendChatResponse.fromJson(Map<String, dynamic> json) {
    return BackendChatResponse(
      response: json['response'] as String,
      userPoints: json['user_points'] as int,
      badges: List<String>.from(json['badges'] as List),
      status: json['status'] as String,
    );
  }
}

class LocationApiResponse {
  final String message;
  final String location;
  final String status;

  LocationApiResponse({
    required this.message,
    required this.location,
    required this.status,
  });

  factory LocationApiResponse.fromJson(Map<String, dynamic> json) {
    return LocationApiResponse(
      message: json['message'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
    );
  }
}

class ImageAnalysisApiResponse {
  final String analysis;
  final String status;

  ImageAnalysisApiResponse({
    required this.analysis,
    required this.status,
  });

  factory ImageAnalysisApiResponse.fromJson(Map<String, dynamic> json) {
    return ImageAnalysisApiResponse(
      analysis: json['analysis'] as String,
      status: json['status'] as String,
    );
  }
}

class DailyChallenge {
  final String title;
  final String description;
  // Ajoutez d'autres champs si nécessaire (difficulty, tips, etc.)

  DailyChallenge({required this.title, required this.description});

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class ChallengeApiResponse {
  final DailyChallenge challenge;
  final String status;

  ChallengeApiResponse({required this.challenge, required this.status});

  factory ChallengeApiResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeApiResponse(
      challenge: DailyChallenge.fromJson(json['challenge'] as Map<String, dynamic>),
      status: json['status'] as String,
    );
  }
}

class UserStats {
  final int points;
  final List<String> badges;
  final int completedChallenges;
  final String knowledgeLevel;
  final List<String> conversationTopics;
  final String status;

  UserStats({
    required this.points,
    required this.badges,
    required this.completedChallenges,
    required this.knowledgeLevel,
    required this.conversationTopics,
    required this.status,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      points: json['points'] as int,
      badges: List<String>.from(json['badges'] as List),
      completedChallenges: json['completed_challenges'] as int,
      knowledgeLevel: json['knowledge_level'] as String,
      conversationTopics: List<String>.from(json['conversation_topics'] as List),
      status: json['status'] as String,
    );
  }
}

// Ajoutez d'autres modèles pour Quiz, etc. si nécessaire

