import 'dart:io';
import 'package:flutter/material.dart';
import '../models/marketplace_item.dart';
import '../services/marketplace_service.dart';
import '../widgets/marketplace_item_card.dart';
import 'add_item_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<MarketplaceItem> _allItems = [];
  List<MarketplaceItem> _filteredItems = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All',
    'Donate',
    'Sell',
    'Plastic',
    'Glass',
    'Metal',
    'Carton',
    'Paper',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await MarketplaceService.getAllItems();
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }


  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredItems = _allItems;
      } else if (filter == 'Donate' || filter == 'Sell') {
        _filteredItems = _allItems.where((item) => item.action == filter).toList();
      } else {
        _filteredItems = _allItems.where((item) => item.wasteType == filter).toList();
      }
    });
  }

  List<MarketplaceItem> _getMyItems() {
    return _filteredItems.where((item) => item.userId == 'current_user').toList();
  }

  List<MarketplaceItem> _getAllItems() {
    return _filteredItems;
  }

  Future<void> _refreshItems() async {
    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Tous les articles'),
            Tab(text: 'Mes articles'),
          ],
        ),
      ),
      body: Column(
        children: [
// Filtres
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _applyFilter(filter);
                      }
                    },
                    selectedColor: Colors.green.withOpacity(0.3),
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    checkmarkColor: Colors.green,
                  ),
                );
              },
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tous les articles
                _buildItemsList(_getAllItems()),
                // Mes articles
                _buildItemsList(_getMyItems()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen()),
          );
          if (result == true) {
            _refreshItems();
          }
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );

  }

  Widget _buildItemsList(List<MarketplaceItem> items) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshItems,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun article trouvé',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tirez vers le bas pour actualiser',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return MarketplaceItemCard(
            item: items[index],
            onTap: () {
              _showItemDetails(items[index]);
            },
          );
        },
      ),
    );


  }

  void _showItemDetails(MarketplaceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// Indicateur de drag
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),

// Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(item.imagePath),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 16),

                // Titre et action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: item.action == 'Donate' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.action == 'Donate' ? 'À DONNER' : 'À VENDRE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Prix (si vente)
                if (item.price != null) ...[
                  Text(
                    '${item.price!.toStringAsFixed(0)} DH',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                ],

                // Informations
                _buildInfoRow(Icons.category, 'Type', item.wasteType),
                _buildInfoRow(Icons.scale, 'Quantité', item.quantity),
                _buildInfoRow(Icons.location_on, 'Localisation', item.location),
                _buildInfoRow(Icons.calendar_today, 'Publié le',
                    '${item.datePosted.day}/${item.datePosted.month}/${item.datePosted.year}'),

                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 14),
                  ),
                ],

                SizedBox(height: 24),

                // Bouton de contact
                if (item.userId != 'current_user')
                  ElevatedButton(
                    onPressed: () {
                      // Action de contact
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonctionnalité de contact à implémenter')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Contacter le vendeur',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );


  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}