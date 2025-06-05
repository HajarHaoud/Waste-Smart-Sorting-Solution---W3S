import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:w3s/models/chatbot/api_responses.dart';
import 'package:w3s/models/chatbot/chat_message.dart';
import 'package:w3s/providers/chat_provider.dart';
import 'package:w3s/screens/settings_screen.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin { // Pour les animations
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  late AnimationController _typingIndicatorAnimationController;

  @override
  void initState() {
    super.initState();
    _typingIndicatorAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.checkApiHealth();
      // Optionnel: charger les données initiales ici si non fait dans le provider
      // chatProvider.fetchUserStats();
      // chatProvider.fetchDailyChallenge();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingIndicatorAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () { // Petit délai pour s'assurer que la liste est construite
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false)
          .handleSendMessage(_textController.text);
      _textController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      String? userQuery;
      if (!context.mounted) return;

      userQuery = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          TextEditingController queryController = TextEditingController();
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Question sur l\'image?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            content: TextField(
              controller: queryController,
              decoration: const InputDecoration(hintText: "Ex: Où jeter ceci ?"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Annuler', style: TextStyle(color: Theme.of(context).primaryColor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('Envoyer'),
                onPressed: () => Navigator.of(context).pop(queryController.text),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return;
      Provider.of<ChatProvider>(context, listen: false)
          .handleAnalyzeImage(File(image.path), query: userQuery ?? "");
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _showMoreOptions(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Pour permettre un fond personnalisé
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.location_on_outlined,
                  text: 'Définir ma localisation',
                  onTap: () async {
                    Navigator.pop(context);
                    _showLocationDialog(context);
                  },
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.emoji_events_outlined,
                  text: 'Défi du jour',
                  onTap: () async {
                    Navigator.pop(context);
                    await chatProvider.fetchDailyChallenge();
                    final challenge = chatProvider.dailyChallenge;
                    if (challenge != null && context.mounted) {
                      _showChallengeDialog(context, challenge, chatProvider);
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pas de défi disponible ou erreur.'))
                      );
                    }
                  },
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.quiz_outlined,
                  text: 'Obtenir un Quiz',
                  onTap: () {
                    Navigator.pop(context);
                    chatProvider.fetchQuiz();
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  },
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.insights_outlined,
                  text: 'Mes Statistiques',
                  onTap: () async {
                    Navigator.pop(context);
                    await chatProvider.fetchUserStats();
                    if(context.mounted) _showUserStatsDialog(context, chatProvider.userStats);
                  },
                ),
                _buildBottomSheetOption(
                  context,
                  icon: Icons.monitor_heart_outlined,
                  text: 'Vérifier Santé API',
                  onTap: () {
                    Navigator.pop(context);
                    chatProvider.checkApiHealth();
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(text, style: GoogleFonts.roboto(fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showLocationDialog(BuildContext context) {
    final TextEditingController locationController = TextEditingController();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Définir la localisation', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(hintText: "Entrez votre ville (ex: Casablanca)"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Définir'),
              onPressed: () {
                if (locationController.text.trim().isNotEmpty) {
                  chatProvider.handleSetLocation(locationController.text.trim());
                  Navigator.of(context).pop();
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChallengeDialog(BuildContext context, DailyChallenge challenge, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("🌟 Défi du Jour : ${challenge.title} 🌟", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).primaryColor)),
          content: Text(challenge.description, style: GoogleFonts.roboto(fontSize: 16)),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Compléter ce défi'),
              onPressed: () {
                Navigator.of(context).pop();
                chatProvider.completeChallenge(challenge.title);
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              },
            ),
          ],
        );
      },
    );
  }

  void _showUserStatsDialog(BuildContext context, UserStats? stats) {
    if (stats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistiques non disponibles.'))
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('📊 Mes Statistiques', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildStatItem('Points:', stats.points.toString()),
                _buildStatItem('Badges:', stats.badges.isNotEmpty ? stats.badges.join(" 🏆, ") + " 🏆" : "Aucun"),
                _buildStatItem('Défis complétés:', stats.completedChallenges.toString()),
                _buildStatItem('Niveau:', stats.knowledgeLevel),
                _buildStatItem('Sujets abordés:', stats.conversationTopics.isNotEmpty ? stats.conversationTopics.join(", ") : "Aucun"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer', style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.roboto(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Waste Smart Sorting', style: GoogleFonts.montserrat()), // Utilisez la police définie dans le thème
        actions: [
          if (chatProvider.userPoints > 0 || chatProvider.badges.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                  child: Chip(
                    avatar: Icon(Icons.star, color: Colors.amber[600], size: 18),
                    label: Text(
                      '${chatProvider.userPoints} Pts ${chatProvider.badges.isNotEmpty ? "| ${chatProvider.badges.length} 🏆" : ""}',
                      style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  )
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showMoreOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container( // Ajout d'un conteneur pour un éventuel arrière-plan
        // decoration: BoxDecoration( // Exemple d'arrière-plan subtil
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       Theme.of(context).scaffoldBackgroundColor,
        //       Theme.of(context).primaryColor.withOpacity(0.05),
        //     ],
        //   ),
        // ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12.0),
                itemCount: chatProvider.messages.length,
                itemBuilder: (BuildContext context, int index) {
                  final message = chatProvider.messages[index];
                  // Ajout d'une animation pour l'apparition des messages
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _buildMessageBubble(message, key: ValueKey(message.timestamps)), // Key pour l'animation
                  );
                },
              ),
            ),
            if (chatProvider.isLoading) _buildTypingIndicator(),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9), // Bot message color
            child: Icon(Icons.android_rounded, color: Color(0xFF4CAF50), size: 20), // Primary color
          ),
          const SizedBox(width: 8),
          RotationTransition( // Simple animation de points
            turns: _typingIndicatorAnimationController,
            child: Text(
              "● ● ●", // Ou utilisez un widget comme `flutter_spinkit`
              style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageBubble(ChatMessage message, {Key? key}) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;

    // Couleurs définies dans le thème ou ici
    const botMessageColor = Color(0xFFE8F5E9);
    const userMessageColor = Color(0xFFDCEDC8); // Un peu plus foncé que le vert du bot
    const systemMessageColor = Color(0xFFECEFF1); // Gris clair

    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? userMessageColor : (isSystem ? systemMessageColor : botMessageColor);
    final textColor = isUser ? Colors.black87 : (isSystem ? Colors.grey[700] : Colors.black87);

    // Styles de bordure pour les bulles
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
    );

    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end, // Aligner l'avatar avec le bas de la bulle
            children: <Widget>[
              if (!isUser && !isSystem)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 2.0), // Ajuster si nécessaire
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Icon(Icons.support_agent_rounded, size: 20, color: Theme.of(context).primaryColor),
                    radius: 16,
                  ),
                ),
              if (isSystem)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 2.0),
                  child: Icon(Icons.info_outline_rounded, color: Colors.grey[500], size: 20),
                ),
              Flexible(
                child: Material( // Utiliser Material pour l'élévation et la forme
                  elevation: 1.0,
                  color: bubbleColor,
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    child: Text(
                      message.text,
                      style: GoogleFonts.roboto(fontSize: 15.5, color: textColor, height: 1.4),
                    ),
                  ),
                ),
              ),
              // if (isUser) // Avatar utilisateur à droite
              //   Padding(
              //     padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
              //     child: CircleAvatar(
              //       backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              //       child: Icon(Icons.person_outline_rounded, size: 20, color: Theme.of(context).colorScheme.secondary),
              //       radius: 16,
              //     ),
              //   ),
            ],
          ),
          Padding( // Timestamp
            padding: EdgeInsets.only(
              top: 4.0,
              left: isUser ? 0 : (isSystem ? 28 : 48), // Aligner avec la bulle
              right: isUser ? 8 : 0,
            ),
            child: Text(
              "${message.timestamps.hour.toString().padLeft(2,'0')}:${message.timestamps.minute.toString().padLeft(2,'0')}",
              style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Ou Colors.white
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.15),
            offset: const Offset(0, -2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SafeArea( // Pour éviter les intrusions du système (encoches, etc.)
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add_photo_alternate_outlined, color: Theme.of(context).primaryColor),
              onPressed: _pickImage,
              tooltip: "Envoyer une image",
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (text) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Votre message...',
                  hintStyle: GoogleFonts.roboto(color: Colors.grey[500]),
                  border: InputBorder.none, // On a déjà défini le style dans le thème
                  focusedBorder: InputBorder.none, // Peut être redéfini si besoin
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), // Ajuster si le thème ne suffit pas
                ),
                style: GoogleFonts.roboto(fontSize: 16),
                minLines: 1,
                maxLines: 4, // Permet plusieurs lignes de texte
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: Theme.of(context).primaryColor),
              onPressed: _sendMessage,
              tooltip: "Envoyer",
            ),
          ],
        ),
      ),
    );
  }
}