import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/services/order_sync_service.dart'; // Import the local sync service

class OrdersViewModel
{
  getNewOrders()
  {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("status", whereIn: ["normal", "accepted", "processing", "ready"])
        .where("sellerUID", isEqualTo: sharedPreferences!.getString("uid"))
        .snapshots();
  }

  // Updated method to update order status with synchronization
  Future<void> updateOrderStatus(String orderID, String newStatus) async {
    try {
      await OrderSyncService.updateOrderStatus(orderID, newStatus);
    } catch (e) {
      print("Error updating order status: $e");
      rethrow;
    }
  }

  // Method to assign rider to order
  Future<void> assignRiderToOrder(String orderID, String riderUID) async {
    try {
      await OrderSyncService.updateOrderData(orderID, {"riderUID": riderUID});
    } catch (e) {
      print("Error assigning rider to order: $e");
      rethrow;
    }
  }

  // Method to update order with additional seller-specific data
  Future<void> updateOrderWithSellerData(String orderID, Map<String, dynamic> sellerData) async {
    try {
      await OrderSyncService.updateOrderData(orderID, sellerData);
    } catch (e) {
      print("Error updating order with seller data: $e");
      rethrow;
    }
  }

  separateItemIDsForOrder(orderIDs)
  {
    List<String> separateItemIDsList = [];
    List<String> defaultItemList = List<String>.from(orderIDs);

    print('=== SEPARATING ITEM IDs ===');
    print('Input orderIDs: $orderIDs');
    print('Default item list: $defaultItemList');

    for(int i = 0; i < defaultItemList.length; i++)
    {
      String item = defaultItemList[i].toString();
      print('Processing item: $item');
      
      // Split by colon and take the first part (itemID)
      List<String> parts = item.split(':');
      if (parts.length >= 2) {
        String itemID = parts[0];
        print('Extracted itemID: $itemID');
        separateItemIDsList.add(itemID);
      } else {
        print('Invalid format for item: $item');
      }
    }

    print('Final separateItemIDsList: $separateItemIDsList');
    print('==========================');
    return separateItemIDsList;
  }

  separateItemQuantitiesForOrder(orderIDs)
  {
    List<String> separateItemQuantityList = [];
    List<String> defaultItemList = List<String>.from(orderIDs);

    print('=== SEPARATING QUANTITIES ===');
    print('Input orderIDs: $orderIDs');

    for(int i = 0; i < defaultItemList.length; i++)
    {
      String item = defaultItemList[i].toString();
      List<String> listItemCharacters = item.split(":").toList();
      var quanNumber = int.parse(listItemCharacters[1].toString());
      separateItemQuantityList.add(quanNumber.toString());
    }

    print('Final separateItemQuantityList: $separateItemQuantityList');
    print('==============================');
    return separateItemQuantityList;
  }

  getSpecificOrder(String orderID)
  {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(orderID)
        .get();
  }

  getShipmentAddress(String addressID, String orderByUser)
  {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(orderByUser)
        .collection("userAddress")
        .doc(addressID)
        .get();
  }

  retrieveOrdersHistory()
  {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("sellerUID", isEqualTo: sharedPreferences!.getString("uid"))
        .where("status", whereIn: ["ended", "cancelled"])
        .snapshots();
  }

  separateItemSpecialInstructionsForOrder(orderIDs) {
  List<String> specialInstructionsList = [];
  List<String> defaultItemList = List<String>.from(orderIDs);

  for (String item in defaultItemList) {
    if (item != "garbageValue") {
      List<String> parts = item.split(":");
      if (parts.length >= 3) {
        String specialInstructions = parts[2];
        specialInstructionsList.add(specialInstructions);
      } else {
        specialInstructionsList.add(""); // Empty if no special instructions
      }
    }
  }

  return specialInstructionsList;
}

}