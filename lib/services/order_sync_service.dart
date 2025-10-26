import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/services/earnings_service.dart';  // Add this import

class OrderSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sync order changes from main collection to user's personal collection
  static Future<void> syncOrderToUserCollection(String orderID, Map<String, dynamic> orderData) async {
    try {
      final userOrderRef = _firestore
          .collection("users")
          .doc(orderData["orderBy"])
          .collection("orders")
          .doc(orderID);

      // Create lightweight reference with updated data
      final userOrderReference = {
        "orderID": orderID,
        "orderTime": orderData["orderTime"],
        "status": orderData["status"],
        "sellerUID": orderData["sellerUID"],
        "totalAmount": orderData["totalAmount"],
        "orderBy": orderData["orderBy"],
        "orderByName": orderData["orderByName"] ?? "Unknown User",
        "lastUpdated": FieldValue.serverTimestamp(),
      };

      await userOrderRef.set(userOrderReference);
      print("Order synced to user collection: $orderID");
    } catch (e) {
      print("Error syncing order to user collection: $e");
      rethrow;
    }
  }

  /// Update order status in both collections
  static Future<void> updateOrderStatus(String orderID, String newStatus) async {
    try {
      // Get the current order data
      DocumentSnapshot orderDoc = await _firestore
          .collection("orders")
          .doc(orderID)
          .get();

      if (!orderDoc.exists) {
        throw Exception("Order not found");
      }

      Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
      String orderByUser = orderData["orderBy"];
      String sellerUID = orderData["sellerUID"];
      double totalAmount = (orderData["totalAmount"] ?? 0.0).toDouble();

      // Update main orders collection
      await _firestore
          .collection("orders")
          .doc(orderID)
          .update({
            "status": newStatus,
            "lastUpdated": FieldValue.serverTimestamp(),
          });

      // Sync to user's collection
      await syncOrderToUserCollection(orderID, orderData);

      // Record earnings when order is completed
      if (newStatus == "ended") {
        await EarningsService.recordOrderCompletion(
          orderId: orderID,
          totalAmount: totalAmount,
          sellerUID: sellerUID,
        );
      }
    } catch (e) {
      print("Error updating order status: $e");
      rethrow;
    }
  }

  /// Get complete order data from main collection
  static Future<Map<String, dynamic>?> getCompleteOrderData(String orderID) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("orders")
          .doc(orderID)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting complete order data: $e");
      return null;
    }
  }

  /// Update order data in main collection
  static Future<void> updateOrderData(String orderID, Map<String, dynamic> updateData) async {
    try {
      await _firestore
          .collection("orders")
          .doc(orderID)
          .update({
            ...updateData,
            "lastUpdated": FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("Error updating order data: $e");
      rethrow;
    }
  }
}
