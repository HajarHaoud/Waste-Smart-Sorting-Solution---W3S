import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importe le package image_picker
import 'dart:io'; // Pour utiliser File

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker(); // Crée une instance de ImagePicker
  XFile? _imageFile; // Variable pour stocker l'image capturée

  void _onItemTapped(int index) {
    // Si l'élément "Home" est tapé (index 0), on ne fait rien de spécial pour le moment.
    // Tu peux ajouter une logique ici si tu veux revenir à l'état initial de l'écran d'accueil.
    if (index == 0) {
      // print("Home pressed"); // Déjà géré par la navigation par défaut si on est déjà sur Home
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Fonction pour ouvrir la caméra et prendre une photo
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        print("Image capturée : ${pickedFile.path}");
        // Ici, tu peux ajouter la logique pour afficher l'image,
        // l'envoyer à un serveur, la traiter, etc.
        // Par exemple, afficher un dialogue avec l'image:
        _showCapturedImageDialog(File(pickedFile.path));
      } else {
        print("Aucune image n'a été capturée.");
      }
    } catch (e) {
      print("Erreur lors de l'accès à la caméra : $e");
      // Afficher un message d'erreur à l'utilisateur
      _showErrorDialog("Erreur d'accès à la caméra", "Veuillez vérifier les permissions de l'application.");
    }
  }

  // Fonction pour afficher un dialogue avec l'image capturée
  void _showCapturedImageDialog(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Image Capturée"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(image),
                SizedBox(height: 10),
                Text("Ceci est l'image que vous avez prise."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher un dialogue d'erreur
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 🔍 Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // 🗑 Image des catégories
                Container(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        child: Image.asset(
                          'lib/images/poubelles.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // 🔘 Titre "Category"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Category',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // 🧭 Liste horizontale des catégories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var item in [
                        {'image': 'lib/images/plastique.png', 'label': 'Plastic'},
                        {'image': 'lib/images/verre.png', 'label': 'Glass'},
                        {'image': 'lib/images/metal.jpeg', 'label': 'Metal'},
                        {'image': 'lib/images/carton.jpg', 'label': 'Carton'},
                        {'image': 'lib/images/paper.png', 'label': 'Paper'},
                        {'image': 'lib/images/others.png', 'label': 'Others'},
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    item['image']!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(item['label']!),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💬 Bulle du Chatbot (à DROITE)
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                // Adapte la route si besoin, assure-toi que '/chatbot' est défini dans ton MaterialApp
                Navigator.pushNamed(context, '/chatbot');
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('lib/images/chatboot.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 📷 Bulle de la caméra (à gauche)
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                print("Caméra activée !");
                _takePhoto(); // Appelle la fonction pour prendre une photo
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('lib/images/camera.png'),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 🔻 Barre de navigation en bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(
            // Assure-toi que 'assets/avatar.jpg' existe ou change le chemin
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}