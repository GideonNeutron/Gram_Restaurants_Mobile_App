import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import '../../model/address.dart';
import '../../model/item.dart';
import 'package:sellers_app/services/order_sync_service.dart';

class OrderDetailScreen extends StatefulWidget {
  String? orderID;
  OrderDetailScreen({super.key, this.orderID});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  String orderStatus = "";
  String orderByUser = "";
  String orderByName = ""; // Add this variable to store customer name
  String sellerId = "";
  String confirmationCode = "";
  List<Item> orderItems = [];
  List<String> quantities = [];
  List<String> specialInstructions = [];
  Map<String, dynamic>? orderData;
  TextEditingController confirmationCodeController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getOrderInfo();
  }

  @override
  void dispose() {
    confirmationCodeController.dispose();
    super.dispose();
  }

  getOrderInfo() async {
    if (widget.orderID == null || widget.orderID!.isEmpty) {
      print('Error: Invalid orderID');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("orders")
          .doc(widget.orderID!)
          .get()
          .then((snap) {
        if (snap.exists && snap.data() != null) {
          setState(() {
            orderData = snap.data()! as Map<String, dynamic>;
            orderStatus = orderData!["status"].toString();
            orderByUser = orderData!["orderBy"].toString();
            orderByName = orderData!["orderByName"]?.toString() ?? "Unknown Customer"; // Get customer name
            sellerId = orderData!["sellerUID"].toString();
            confirmationCode = orderData!["confirmationCode"]?.toString() ?? "";
          });
          loadOrderItems();
        }
      });
    } catch (e) {
      print('Error getting order info: $e');
    }
  }

  loadOrderItems() async {
    if (orderData == null) return;

    List<String> productIDs = List<String>.from(orderData!["productIDs"]);
    List<String> itemIDs = [];
    List<String> itemQuantities = [];
    List<String> itemSpecials = [];

    // Extract item IDs and quantities
    for (String productID in productIDs) {
      List<String> parts = productID.split(':');
      if (parts.length >= 2) {
        itemIDs.add(parts[0]);
        itemQuantities.add(parts[1]);
        itemSpecials.add(parts.length >= 3 ? parts[2] : "");
      }
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("items")
          .where("itemID", whereIn: itemIDs)
          .where("sellerUID", isEqualTo: sharedPreferences!.getString("uid"))
          .get();

      List<Item> items = [];
      for (var doc in snapshot.docs) {
        items.add(Item.fromJson(doc.data() as Map<String, dynamic>));
      }

      setState(() {
        orderItems = items;
        quantities = itemQuantities;
        specialInstructions = itemSpecials;
      });
    } catch (e) {
      print('Error loading order items: $e');
    }
  }

  updateOrderStatus(String newStatus) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Use the OrderSyncService to update order status
      await OrderSyncService.updateOrderStatus(widget.orderID!, newStatus);

      setState(() {
        orderStatus = newStatus;
        isLoading = false;
      });

      commonViewModel.showSnackBar("Order status updated to $newStatus", context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      commonViewModel.showSnackBar("Error updating order status: $e", context);
    }
  }

  verifyConfirmationCode() async {
    String enteredCode = confirmationCodeController.text.trim();
    
    if (enteredCode.isEmpty) {
      commonViewModel.showSnackBar("Please enter confirmation code", context);
      return;
    }

    if (enteredCode == confirmationCode) {
      await updateOrderStatus("ended");
      confirmationCodeController.clear();
    } else {
      commonViewModel.showSnackBar("Invalid confirmation code", context);
    }
  }

  String formatOrderTime(String orderTime) {
    try {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(orderTime));
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return "Invalid date";
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.blue;
      case 'accepted':
        return Colors.cyan;
      case 'processing':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'ended':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Icons.receipt;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'ended':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orderID == null || widget.orderID!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Invalid Order ID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: orderData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(21),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Name - Add this new section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Customer: $orderByName',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Order ID and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${widget.orderID!.substring(widget.orderID!.length - 6)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatOrderTime(orderData!["orderTime"]),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: getStatusColor(orderStatus).withAlpha(21),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: getStatusColor(orderStatus)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    getStatusIcon(orderStatus),
                                    size: 16,
                                    color: getStatusColor(orderStatus),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    orderStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: getStatusColor(orderStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Total Amount
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$${orderData!["totalAmount"]?.toStringAsFixed(2) ?? "0.00"}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Order Items
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(21),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(orderItems.length, (index) {
                          if (index >= quantities.length) return const SizedBox.shrink();
                          
                          Item item = orderItems[index];
                          String quantity = quantities[index];
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                // Item Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.itemImage ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Item Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.itemTitle ?? 'Unknown Item',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '× $quantity',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (index < specialInstructions.length && specialInstructions[index].trim().isNotEmpty)
                                            ? 'Special instructions: ${specialInstructions[index]}'
                                            : 'No special instructions',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.price?.toStringAsFixed(2) ?? "0.00"}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Status Management
                  if (orderStatus != "ended" && orderStatus != "cancelled")
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(21),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update Order Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Status Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => updateOrderStatus("accepted"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: orderStatus == "accepted" ? Colors.cyan : Colors.cyan.shade100,
                                    foregroundColor: orderStatus == "accepted" ? Colors.white : Colors.cyan,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => updateOrderStatus("processing"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: orderStatus == "processing" ? Colors.orange : Colors.orange.shade100,
                                    foregroundColor: orderStatus == "processing" ? Colors.white : Colors.orange,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.restaurant, size: 18),
                                  label: const Text('Processing'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => updateOrderStatus("ready"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: orderStatus == "ready" ? Colors.green : Colors.green.shade100,
                                    foregroundColor: orderStatus == "ready" ? Colors.white : Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: const Text('Ready'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : () => updateOrderStatus("cancelled"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade100,
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.cancel, size: 18),
                                  label: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Confirmation Code Section
                  if (orderStatus == "ready")
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(21),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter the 5-digit confirmation code to mark order as completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: confirmationCodeController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter 5-digit code',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(Icons.security),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: isLoading ? null : verifyConfirmationCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text('Verify'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
