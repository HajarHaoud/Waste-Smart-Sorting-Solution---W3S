// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'add_item_screen.dart';
import 'marketplace_screen.dart';
=======
import 'package:image_picker/image_picker.dart'; // Potentiellement utilisé par AddItemScreen ou si la fonctionnalité caméra revient
import 'dart:io'; // Potentiellement utilisé pour la même raison

// Imports des écrans de navigation
import 'category_detail_screen.dart'; // Écran pour les détails d'une catégorie
import 'add_item_screen.dart';       // Écran pour ajouter un nouvel article
import 'marketplace_screen.dart';    // Écran pour la place de marché (Marketplace)
// import 'chatbot_screen.dart';    // Décommentez si vous avez un écran dédié au chatbot
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
<<<<<<< HEAD
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
=======
  int _selectedIndex = 0; // Index de l'onglet actuellement sélectionné dans la barre de navigation
  final ImagePicker _picker = ImagePicker(); // Instance pour choisir des images (caméra/galerie)
  XFile? _imageFile; // Pour stocker le fichier image sélectionné/capturé
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba

  // Gère le clic sur un élément de la BottomNavigationBar
  void _onItemTapped(int index) {
<<<<<<< HEAD
    if (index == 2) { // Shopping cart - Marketplace
=======
    if (index == 2) { // Index 2 correspond à l'icône du panier (Marketplace)
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MarketplaceScreen()),
      );
<<<<<<< HEAD
      return;
    }

    if (index == 0) {
      // Already on home
    } else {
      setState(() {
        _selectedIndex = index;
      });
=======
      // Après avoir navigué, on ne change pas _selectedIndex pour que "Home" reste actif visuellement
      // si l'utilisateur revient. Si vous voulez que "Marketplace" soit actif, décommentez le setState ci-dessous.
      // setState(() {
      //   _selectedIndex = index;
      // });
      return; // Sortir de la fonction pour éviter le setState général
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
    }

    // Si l'utilisateur clique sur l'onglet "Home" (index 0) alors qu'il est déjà dessus
    if (index == _selectedIndex && index == 0) {
      // Optionnel : actions spécifiques comme remonter en haut de la page ou rafraîchir.
      // print("Déjà sur Home, action spécifique possible ici.");
      return;
    }

    // Mettre à jour l'index sélectionné pour les autres onglets qui ne sont pas des navigations "push"
    setState(() {
      _selectedIndex = index;
    });

    // Logique de navigation pour d'autres onglets si nécessaire :
    // if (index == 1) { Navigator.pushNamed(context, '/map_screen'); }
    // if (index == 3) { Navigator.pushNamed(context, '/notifications_screen'); }
    // if (index == 4) { Navigator.pushNamed(context, '/profile_screen'); }
  }

  // Fonction pour ouvrir la caméra et prendre une photo
  // Note: Cette fonction pourrait être déplacée vers AddItemScreen si c'est son seul usage.
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        print("Image capturée : ${pickedFile.path}");
<<<<<<< HEAD
        _showCapturedImageDialog(File(pickedFile.path));
=======
        _showCapturedImageDialog(File(pickedFile.path)); // Affiche l'image capturée
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
      } else {
        print("Aucune image n'a été capturée.");
      }
    } catch (e) {
      print("Erreur lors de l'accès à la caméra : $e");
      _showErrorDialog("Erreur d'accès à la caméra", "Veuillez vérifier les permissions de l'application.");
    }
  }

<<<<<<< HEAD
=======
  // Affiche un dialogue avec l'image capturée
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
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
                Image.file(image, height: 200, fit: BoxFit.cover),
                SizedBox(height: 10),
                Text("Ceci est l'image que vous avez prise."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
          ],
        );
      },
    );
  }

<<<<<<< HEAD
=======
  // Affiche un dialogue d'erreur générique
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
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
                Navigator.of(context).pop(); // Ferme le dialogue
              },
            ),
          ],
        );
      },
    );
  }

<<<<<<< HEAD
=======
  // Construit un item de catégorie cliquable
  Widget _buildCategoryItem(BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        // Navigue vers l'écran de détail de la catégorie
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(categoryName: label),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 85, // Largeur de l'item de catégorie
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prend la hauteur minimale nécessaire
            children: [
              ClipOval( // Rend l'image circulaire
                child: Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover, // Assure que l'image remplit le cercle
                  errorBuilder: (context, error, stackTrace) {
                    // Affiche une icône si l'image ne peut pas être chargée
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              SizedBox(height: 8), // Espace entre l'image et le texte
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis, // Ajoute "..." si le texte est trop long
                maxLines: 1, // Limite le texte à une seule ligne
              ),
            ],
          ),
        ),
      ),
    );
  }

>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
  @override
  Widget build(BuildContext context) {
    // Liste des données pour les catégories
    final List<Map<String, String>> categories = [
      {'image': 'lib/images/plastique.png', 'label': 'Plastic'},
      {'image': 'lib/images/verre.png', 'label': 'Glass'},
      {'image': 'lib/images/metal.jpeg', 'label': 'Metal'},
      {'image': 'lib/images/carton.jpg', 'label': 'Carton'},
      {'image': 'lib/images/paper.png', 'label': 'Paper'},
      {'image': 'lib/images/others.png', 'label': 'Others'},
    ];

    return Scaffold(
      body: Stack( // Permet de superposer les boutons flottants sur le contenu principal
        children: [
<<<<<<< HEAD
          SafeArea(
            child: Column(
              children: [
                // Barre de recherche
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
                // Image des catégories
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
=======
          SafeArea( // Assure que le contenu ne déborde pas dans les zones système (barre d'état, etc.)
            child: SingleChildScrollView( // Permet au contenu de défiler si l'écran est trop petit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Étire les enfants sur toute la largeur
                children: [
                  // Barre de recherche stylisée
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[200], // Fond de la barre de recherche
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Coins arrondis
                          borderSide: BorderSide.none, // Pas de bordure visible
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      ),
                    ),
                  ),
                  // Bannière d'image pour les catégories
                  Container(
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0), // Coins arrondis pour la bannière
                      image: DecorationImage(
                        image: AssetImage('lib/images/poubelles.png'), // Chemin de votre image de bannière
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Erreur de chargement de l\'image de bannière: $exception');
                        },
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
                      ),
                      boxShadow: [ // Ombre subtile pour la bannière
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
<<<<<<< HEAD
                ),
                SizedBox(height: 10),
                // Titre "Category"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
=======
                  SizedBox(height: 20),
                  // Titre de la section "Category"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
                    child: Text(
                      'Category',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
<<<<<<< HEAD
                ),
                SizedBox(height: 8),
                // Liste horizontale des catégories
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
=======
                  SizedBox(height: 10),
                  // Liste horizontale des catégories
                  Container(
                    height: 120, // Hauteur fixe pour la liste des catégories
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Défilement horizontal
                      padding: EdgeInsets.symmetric(horizontal: 8.0), // Espacement sur les côtés
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        return _buildCategoryItem(context, item['image']!, item['label']!);
                      },
                    ),
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
                  ),
                  SizedBox(height: 80), // Espace en bas pour éviter que les boutons flottants cachent du contenu
                ],
              ),
            ),
          ),

<<<<<<< HEAD
          // Bulle du Chatbot (à DROITE)
=======
          // Bouton flottant pour le Chatbot (en bas à droite)
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
<<<<<<< HEAD
                // Navigation vers le chatbot
                print("Chatbot ouvert");
=======
                // Navigation vers l'écran du Chatbot
                // Si vous avez une route nommée '/chatbot' :
                if (ModalRoute.of(context)?.settings.name != '/chatbot') {
                  Navigator.pushNamed(context, '/chatbot');
                }
                // Sinon, utilisez MaterialPageRoute :
                // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatbotScreen()));
                print("Chatbot ouvert (placeholder)"); // Message si la navigation n'est pas implémentée
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Forme circulaire
                  color: Theme.of(context).colorScheme.secondary, // Couleur du thème
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 30), // Icône du chatbot
              ),
            ),
          ),

<<<<<<< HEAD
          // Bouton d'ajout d'article (remplace la caméra)
=======
          // Bouton flottant pour ajouter un article (en bas à gauche)
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
          Positioned(
            bottom: 10,
            left: 20,
<<<<<<< HEAD
            child: GestureDetector(
              onTap: () {
=======
            child: FloatingActionButton(
              onPressed: () {
                // Navigue vers l'écran pour ajouter un nouvel article
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemScreen()),
                );
              },
<<<<<<< HEAD
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                  size: 30,
                ),
              ),
=======
              child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white), // Icône
              backgroundColor: Theme.of(context).colorScheme.primary, // Couleur du thème
              heroTag: 'addItemButton', // Tag unique si plusieurs FAB sur la même route complexe
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
            ),
          ),
        ],
      ),

<<<<<<< HEAD
      // Barre de navigation en bas
=======
      // Barre de navigation en bas de l'écran
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Onglet actuellement sélectionné
        onTap: _onItemTapped, // Fonction appelée lors du clic sur un onglet
        type: BottomNavigationBarType.fixed, // Assure que tous les items sont visibles et ont un label
        selectedItemColor: Theme.of(context).colorScheme.primary, // Couleur de l'icône et du texte de l'onglet sélectionné
        unselectedItemColor: Colors.grey[600], // Couleur pour les onglets non sélectionnés
        // showSelectedLabels: false, // Décommentez pour masquer les labels
        // showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
<<<<<<< HEAD
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/avatar.jpg'),
=======
            icon: Icon(Icons.home_outlined), // Icône par défaut
            activeIcon: Icon(Icons.home),     // Icône quand l'onglet est actif
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar( // Icône de profil utilisant un CircleAvatar
              radius: 14,
              backgroundImage: AssetImage('assets/avatar.jpg'), // Chemin vers l'image d'avatar
              // backgroundColor: Colors.grey[300], // Couleur de fond si l'image ne charge pas
              // child: Icon(Icons.person_outline, size: 18, color: Colors.white), // Icône placeholder
>>>>>>> ff4497aca9c5b037cec83c3f65d272e640a769ba
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}