import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/global/global_vars.dart';

class EarningsService {
  // This method should be called when an order is completed
  static Future<void> recordOrderCompletion({
    required String orderId,
    required double totalAmount,
    required String sellerUID,
  }) async {
    try {
      // Calculate tax (assuming 10% tax rate - adjust as needed)
      double taxRate = 0.10;
      double amountWithoutTax = totalAmount / (1 + taxRate);
      double taxAmount = totalAmount - amountWithoutTax;

      // Create earning record
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sellerUID)
          .collection("earnings")
          .add({
        'orderId': orderId,
        'amountWithTax': totalAmount,
        'amountWithoutTax': amountWithoutTax,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Update seller's total earnings
      await _updateSellerTotalEarnings(sellerUID, totalAmount, amountWithoutTax);
    } catch (e) {
      print("Error recording order completion: $e");
      rethrow;
    }
  }

  // Update seller's total earnings
  static Future<void> _updateSellerTotalEarnings(
    String sellerUID,
    double amountWithTax,
    double amountWithoutTax,
  ) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference sellerRef = FirebaseFirestore.instance
            .collection("sellers")
            .doc(sellerUID);

        DocumentSnapshot sellerDoc = await transaction.get(sellerRef);
        
        if (sellerDoc.exists) {
          Map<String, dynamic> data = sellerDoc.data() as Map<String, dynamic>;
          
          double currentTotalWithTax = (data['totalEarningsWithTax'] ?? 0.0).toDouble();
          double currentTotalWithoutTax = (data['totalEarningsWithoutTax'] ?? 0.0).toDouble();
          
          transaction.update(sellerRef, {
            'totalEarningsWithTax': currentTotalWithTax + amountWithTax,
            'totalEarningsWithoutTax': currentTotalWithoutTax + amountWithoutTax,
            'earnings': currentTotalWithoutTax + amountWithoutTax, // Keep backward compatibility
          });
        }
      });
    } catch (e) {
      print("Error updating seller total earnings: $e");
      rethrow;
    }
  }
}
