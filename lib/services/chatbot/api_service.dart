import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:w3s/constants.dart';
import 'package:w3s/models/chatbot/api_responses.dart';

class ApiService {
  final String _baseUrl = API_BASE_URL;

  Future<BackendChatResponse> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      return BackendChatResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to send message: ${response.statusCode} ${response.body}');
    }
  }

  Future<LocationApiResponse> setLocation(String location) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'location': location}),
    );
    if (response.statusCode == 200) {
      return LocationApiResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to set location: ${response.statusCode} ${response.body}');
    }
  }

  Future<ImageAnalysisApiResponse> analyzeImage(File imageFile, {String query = ""}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/analyze-image-upload'));
    request.fields['query'] = query;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ImageAnalysisApiResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to analyze image: ${response.statusCode} ${response.body}');
    }
  }

  Future<ChallengeApiResponse> getDailyChallenge() async {
    final response = await http.get(Uri.parse('$_baseUrl/daily-challenge'));
    if (response.statusCode == 200) {
      return ChallengeApiResponse.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get daily challenge: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> completeChallenge(String challengeTitle) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/complete-challenge'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'challenge_title': challengeTitle}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to complete challenge: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getQuiz() async {
    final response = await http.get(Uri.parse('$_baseUrl/quiz'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to get quiz: ${response.statusCode} ${response.body}');
    }
  }

  Future<UserStats> getUserStats() async {
    final response = await http.get(Uri.parse('$_baseUrl/user-stats'));
    if (response.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to get user stats: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(Uri.parse('$_baseUrl/health'));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to check health: ${response.statusCode} ${response.body}');
    }
  }
}