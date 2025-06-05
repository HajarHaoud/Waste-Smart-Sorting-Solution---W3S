enum MessageSender {user , bot , system}

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamps;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
  }) : timestamps = timestamp ?? DateTime.now();
}