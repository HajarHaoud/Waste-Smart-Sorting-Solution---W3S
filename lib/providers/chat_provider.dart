import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w3s/models/chatbot/api_responses.dart';
import 'package:w3s/models/chatbot/chat_message.dart';
import 'package:w3s/services/chatbot/api_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  int _userPoints = 0;
  List<String> _badges = [];
  String? _currentLocation;
  DailyChallenge? _dailyChallenge;
  UserStats? _userStats;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get userPoints => _userPoints;
  List<String> get badges => _badges;
  String? get currentLocation => _currentLocation;
  DailyChallenge? get dailyChallenge => _dailyChallenge;
  UserStats? get userStats => _userStats;


  ChatProvider() {
    _loadInitialData();
    // Ajouter un message de bienvenue initial
    _messages.add(ChatMessage(
        text: "Bonjour ! Je suis Waste Smart Sorting, votre assistant de tri. Comment puis-je vous aider ?",
        sender: MessageSender.bot));
  }

  Future<void> _loadInitialData() async {
    await _loadLocation();
    await fetchUserStats(); // Charger les stats au démarrage
    await fetchDailyChallenge(); // Charger le défi au démarrage
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocation = prefs.getString('user_location');
    if (_currentLocation != null) {
      _messages.add(ChatMessage(text: "Localisation actuelle: $_currentLocation", sender: MessageSender.system));
    }
    notifyListeners();
  }

  Future<void> _saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_location', location);
  }


  Future<void> handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, sender: MessageSender.user));
    _isLoading = true;
    notifyListeners();

    try {
      // Vérifier les commandes spéciales
      String? specialResponse;
      if (text.toLowerCase() == "défi du jour" || text.toLowerCase() == "défi quotidien") {
        await fetchDailyChallenge();
        if (_dailyChallenge != null) {
          specialResponse = "🌟 DÉFI: ${_dailyChallenge!.title} 🌟\n${_dailyChallenge!.description}";
        } else {
          specialResponse = "Je n'ai pas pu récupérer le défi du jour.";
        }
      } else if (text.toLowerCase() == "mes points" || text.toLowerCase() == "score") {
        await fetchUserStats();
        specialResponse = "🏆 POINTS: ${_userStats?.points ?? _userPoints} | BADGES: ${(_userStats?.badges ?? _badges).join(', ')}";
      } else if (text.toLowerCase() == "quiz") {
        final quizData = await _apiService.getQuiz();
        final quizQuestion = quizData['quiz'];
        specialResponse = "❓ ${quizQuestion['question']} ❓\nOptions: ${(quizQuestion['options'] as List).join(', ')}";
      }


      if (specialResponse != null) {
        _messages.add(ChatMessage(text: specialResponse, sender: MessageSender.bot));
      } else {
        final backendResponse = await _apiService.sendMessage(text);
        _messages.add(ChatMessage(text: backendResponse.response, sender: MessageSender.bot));
        _userPoints = backendResponse.userPoints;
        _badges = backendResponse.badges;
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleSetLocation(String location) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.setLocation(location);
      _currentLocation = response.location;
      await _saveLocation(response.location);
      _messages.add(ChatMessage(text: response.message, sender: MessageSender.system));
      _messages.add(ChatMessage(text: "Localisation mise à jour : $currentLocation", sender: MessageSender.bot));
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur localisation: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAnalyzeImage(File imageFile, {String query = ""}) async {
    _messages.add(ChatMessage(text: "Analyse de l'image en cours...", sender: MessageSender.system));
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.analyzeImage(imageFile, query: query);
      _messages.add(ChatMessage(text: "Analyse de l'image:\n${response.analysis}", sender: MessageSender.bot));
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur analyse image: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyChallenge() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getDailyChallenge();
      _dailyChallenge = response.challenge;
      // Optionnel: ajouter un message dans le chat pour informer du défi
      // _messages.add(ChatMessage(text: "Nouveau défi du jour : ${_dailyChallenge?.title}", sender: MessageSender.system));
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur récupération défi: ${e.toString()}", sender: MessageSender.system));
      _dailyChallenge = null; // Assurez-vous qu'il est nul en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeChallenge(String challengeTitle) async {
    _isLoading = true;
    notifyListeners();
    try {
      final responseData = await _apiService.completeChallenge(challengeTitle);
      _messages.add(ChatMessage(text: responseData['message'], sender: MessageSender.bot));
      _userPoints = responseData['user_points'];
      _badges = List<String>.from(responseData['badges']);
      await fetchUserStats(); // Mettre à jour les stats complètes
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur complétion défi: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserStats() async {
    _isLoading = true;
    // notifyListeners(); // Peut causer des rebuilds non désirés si appelé trop souvent
    try {
      final stats = await _apiService.getUserStats();
      _userStats = stats;
      _userPoints = stats.points; // Synchroniser les points locaux
      _badges = stats.badges;     // Synchroniser les badges locaux
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur récupération stats: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuiz() async {
    _isLoading = true;
    notifyListeners();
    try {
      final quizData = await _apiService.getQuiz();
      final quiz = quizData['quiz'];
      final question = "❓ ${quiz['question']} ❓\nOptions: ${(quiz['options'] as List).join(', ')}\n(Répondez avec l'option correcte)";
      _messages.add(ChatMessage(text: question, sender: MessageSender.bot));
      // Ici, vous pourriez stocker la réponse correcte pour la vérifier plus tard
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur récupération quiz: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkApiHealth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final healthData = await _apiService.healthCheck();
      _messages.add(ChatMessage(text: "Santé API: ${healthData['message']} (Version: ${healthData['version']})", sender: MessageSender.system));
    } catch (e) {
      _messages.add(ChatMessage(text: "Erreur santé API: ${e.toString()}", sender: MessageSender.system));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}