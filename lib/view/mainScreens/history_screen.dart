import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../global/global_instances.dart';
import '../../global/global_vars.dart';
import '../widgets/my_appbar.dart';
import '../widgets/order_card_ui_design.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<DocumentSnapshot> _allOrders = [];
  List<DocumentSnapshot> _filteredOrders = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Method to perform async item name search
  Future<void> _searchByItemNames() async {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredOrders = _allOrders;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    List<DocumentSnapshot> filtered = [];

    for (var orderDoc in _allOrders) {
      Map<String, dynamic> orderData = orderDoc.data()! as Map<String, dynamic>;
      
      // Check if customer name matches (case insensitive)
      String customerName = orderData["orderByName"]?.toString().toLowerCase() ?? "";
      if (customerName.contains(_searchQuery.toLowerCase())) {
        filtered.add(orderDoc);
        continue;
      }

      // Check if any item name matches (case insensitive)
      List<String> productIDs = List<String>.from(orderData["productIDs"] ?? []);
      List<String> itemIDs = [];
      
      for (String productID in productIDs) {
        List<String> parts = productID.split(':');
        if (parts.length >= 2) {
          itemIDs.add(parts[0]);
        }
      }

      if (itemIDs.isNotEmpty) {
        try {
          String sellerUID = sharedPreferences!.getString("uid")!;
          QuerySnapshot itemSnapshot = await FirebaseFirestore.instance
              .collection("items")
              .where("itemID", whereIn: itemIDs)
              .where("sellerUID", isEqualTo: sellerUID)
              .get();

          bool itemMatches = false;
          for (var itemDoc in itemSnapshot.docs) {
            Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
            String itemName = itemData["itemTitle"]?.toString().toLowerCase() ?? "";
            if (itemName.contains(_searchQuery.toLowerCase())) {
              itemMatches = true;
              break;
            }
          }

          if (itemMatches) {
            filtered.add(orderDoc);
          }
        } catch (e) {
          print('Error searching items: $e');
        }
      }
    }

    setState(() {
      _filteredOrders = filtered;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: 'Order History',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or item name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _filteredOrders = _allOrders;
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchByItemNames();
              },
            ),
          ),
          
          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersViewModel.retrieveOrdersHistory(),
              builder: (c, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading order history',
                          style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                        ),
                      ],
                    ),
                  );
                }
                
                // Update orders list
                if (snapshot.hasData) {
                  _allOrders = snapshot.data!.docs;
                  if (_searchQuery.isEmpty) {
                    _filteredOrders = _allOrders;
                  }
                }
                
                if (_filteredOrders.isEmpty && !_isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.history,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matching orders found' : 'No Order History',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Try searching with different keywords'
                              : 'You don\'t have any completed orders yet',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Show searching state
                if (_isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching orders...'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (c, index) {
                    Map<String, dynamic> orderData = _filteredOrders[index].data()! as Map<String, dynamic>;
                    List<String> productIDs = List<String>.from(orderData["productIDs"]);
                    String orderStatus = orderData["status"]?.toString() ?? "";
                    
                    // Skip if no products in order
                    if (productIDs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("items")
                          .where("itemID", whereIn: ordersViewModel.separateItemIDsForOrder(productIDs))
                          .where("sellerUID", isEqualTo: sharedPreferences!.getString("uid"))
                          .get(),
                      builder: (c, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Card(
                            margin: EdgeInsets.all(10),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          );
                        }
                        
                        if (snap.hasError || !snap.hasData || snap.data!.docs.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: OrderCardUIDesign(
                            itemCount: snap.data!.docs.length,
                            data: snap.data!.docs,
                            orderID: _filteredOrders[index].id,
                            separateQuantitiesList: ordersViewModel.separateItemQuantitiesForOrder(productIDs),
                            orderStatus: orderStatus,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
