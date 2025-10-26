import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';
import 'package:sellers_app/view/widgets/order_card_ui_design.dart';

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
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

  // Helper method to get items for an order
  Future<List<DocumentSnapshot>> getItemsForOrder(List<String> productIDs) async {
    List<String> itemIDs = [];
    
    // Extract item IDs
    for (String productID in productIDs) {
      List<String> parts = productID.split(':');
      if (parts.length >= 2) {
        itemIDs.add(parts[0]); // itemID
      }
    }
    
    if (itemIDs.isEmpty) {
      return [];
    }
    
    try {
      String sellerUID = sharedPreferences!.getString("uid")!;
      
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("items")
          .where("itemID", whereIn: itemIDs)
          .where("sellerUID", isEqualTo: sellerUID)
          .get();
      
      return snapshot.docs;
    } catch (e) {
      print('Error querying items: $e');
      return [];
    }
  }

  // Method to filter orders based on search query
  void _filterOrders() {
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
      bool itemMatches = false;
      
      for (String productID in productIDs) {
        List<String> parts = productID.split(':');
        if (parts.length >= 2) {
          String itemID = parts[0];
          
          // Query items collection to get item name
          FirebaseFirestore.instance
              .collection("items")
              .doc(itemID)
              .get()
              .then((itemDoc) {
            if (itemDoc.exists) {
              Map<String, dynamic> itemData = itemDoc.data()!;
              String itemName = itemData["itemTitle"]?.toString().toLowerCase() ?? "";
              if (itemName.contains(_searchQuery.toLowerCase())) {
                setState(() {
                  if (!filtered.contains(orderDoc)) {
                    filtered.add(orderDoc);
                  }
                });
              }
            }
          });
        }
      }
    }

    setState(() {
      _filteredOrders = filtered;
    });
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
        titleMsg: 'New Orders',
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
              stream: ordersViewModel.getNewOrders(),
              builder: (c, snapshot) {
                // Show loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading orders...'),
                      ],
                    ),
                  );
                }
                
                // Show error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: TextStyle(fontSize: 18, color: Colors.red.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {}); // Refresh the stream
                          },
                          child: const Text('Retry'),
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
                
                // Show empty state
                if (_filteredOrders.isEmpty && !_isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? 'No matching orders found' : 'No New Orders',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty 
                              ? 'Try searching with different keywords'
                              : 'You don\'t have any new orders at the moment',
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

                // Show orders
                return ListView.builder(
                  itemCount: _filteredOrders.length,
                  itemBuilder: (c, index) {
                    Map<String, dynamic> orderData = _filteredOrders[index].data()! as Map<String, dynamic>;
                    List<String> productIDs = List<String>.from(orderData["productIDs"]);
                    
                    // Skip if no products in order
                    if (productIDs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return FutureBuilder<List<DocumentSnapshot>>(
                      future: getItemsForOrder(productIDs),
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
                        
                        if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Extract quantities for the items
                        List<String> quantities = [];
                        for (String productID in productIDs) {
                          List<String> parts = productID.split(':');
                          if (parts.length >= 2) {
                            quantities.add(parts[1]);
                          }
                        }

                        return Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(10),
                          child: OrderCardUIDesign(
                            itemCount: snap.data!.length,
                            data: snap.data!,
                            orderID: _filteredOrders[index].id,
                            separateQuantitiesList: quantities,
                          ),
                        );
                      }
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
