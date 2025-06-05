import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w3s/constants.dart';
import 'package:w3s/providers/chat_provider.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _currentApiUrl = API_BASE_URL; // Utiliser la constante
  String? _currentLocation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentApiUrl = prefs.getString('api_base_url') ?? API_BASE_URL; // Valeur par défaut
      _apiUrlController.text = _currentApiUrl;
      _currentLocation = prefs.getString('user_location');
      if (_currentLocation != null) {
        _locationController.text = _currentLocation!;
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', _apiUrlController.text);
    if (_locationController.text.isNotEmpty) {
      await prefs.setString('user_location', _locationController.text);
      // Mettre à jour le provider aussi si la localisation change ici
      // ignore: use_build_context_synchronously
      Provider.of<ChatProvider>(context, listen: false).handleSetLocation(_locationController.text);

    } else {
      await prefs.remove('user_location');
    }
    setState(() {
      _currentApiUrl = _apiUrlController.text;
      _currentLocation = _locationController.text.isNotEmpty ? _locationController.text : null;
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres sauvegardés! Redémarrez l\'app si l\'URL API a changé.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text('URL de l\'API Actuelle: $_currentApiUrl', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'Nouvelle URL de base de l\'API',
                hintText: 'http://192.168.x.x:8000/api',
              ),
            ),
            const SizedBox(height: 20),
            Text('Localisation par défaut: ${_currentLocation ?? "Non définie"}', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Localisation par défaut',
                hintText: 'Ex: Casablanca',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Sauvegarder les Paramètres'),
            ),
            const SizedBox(height: 20),
            const Text(
              "Note: Si vous changez l'URL de l'API, un redémarrage de l'application peut être nécessaire pour que les changements prennent effet partout.",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
    );
  }
}