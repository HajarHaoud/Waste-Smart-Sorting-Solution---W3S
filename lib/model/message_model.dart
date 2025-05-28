import 'package:flutter/material.dart'; // Peut-être pas nécessaire ici, dépend de l'utilisation
import 'dart:io';

class MessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? image;
  // Ajoutez d'autres champs si MessageBubble les utilisait à l'origine

  MessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.image,
  });

  // Ajoutez ici d'éventuelles méthodes fromJson ou toJson si nécessaires pour l'ancien code
}
