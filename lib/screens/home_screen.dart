import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:w3s/screens/ad_details_form_screen.dart';
import 'package:w3s/screens/take_photo_screen.dart';
import 'dart:io';
import 'category_detail_screen.dart';
import 'add_item_screen.dart';
import 'marketplace_screen.dart';
import 'quiz_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredCategories = [];

  final List<Map<String, String>> _allCategories = [
    {'image': 'lib/images/plastique.png', 'label': 'Plastic'},
    {'image': 'lib/images/verre.png', 'label': 'Glass'},
    {'image': 'lib/images/metal.jpeg', 'label': 'Metal'},
    {'image': 'lib/images/carton.jpg', 'label': 'Carton'},
    {'image': 'lib/images/paper.png', 'label': 'Paper'},
    {'image': 'lib/images/others.png', 'label': 'Others'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories.where((item) {
        return item['label']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MarketplaceScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
      return;
    }

    if (index == _selectedIndex && index == 0) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        print("Image capturée : ${pickedFile.path}");
        _showCapturedImageDialog(File(pickedFile.path));
      } else {
        print("Aucune image n'a été capturée.");
      }
    } catch (e) {
      print("Erreur lors de l'accès à la caméra : $e");
      _showErrorDialog("Erreur d'accès à la caméra", "Veuillez vérifier les permissions de l'application.");
    }
  }

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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildCategoryItem(BuildContext context, String imagePath, String label) {
    return GestureDetector(
      onTap: () {
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
          width: 85,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      ),
                    ),
                  ),
                  Container(
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      image: DecorationImage(
                        image: AssetImage('lib/images/poubelles.png'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Erreur de chargement de l\'image de bannière: $exception');
                        },
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Category',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCategories[index];
                        return _buildCategoryItem(context, item['image']!, item['label']!);
                      },
                    ),
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              onPressed: () {

                Navigator.pushNamed(context, '/chat');
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              heroTag: 'chatButton',
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white
              ),
              tooltip: 'Chat with Assistant',
            ),
          ),


          Positioned(
            bottom: 15,
            left: 15,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdDetailsFormScreen()),
                );
              },
              child: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
              backgroundColor: Theme.of(context).colorScheme.primary,
              heroTag: 'addItemButton',
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}