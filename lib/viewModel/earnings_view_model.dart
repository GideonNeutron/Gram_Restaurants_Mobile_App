import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/model/earning.dart';

class EarningsViewModel {
  // Get seller's total earnings from main document
  Stream<DocumentSnapshot> getSellerEarnings() {
    return FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .snapshots();
  }

  // Get earnings for a specific time period
  Future<List<Earning>> getEarningsForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .collection("earnings")
          .where("completedAt", isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where("completedAt", isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy("completedAt", descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Earning.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching earnings: $e");
      return [];
    }
  }

  // Get earnings for current year (for monthly chart)
  Future<List<Earning>> getEarningsForCurrentYear() async {
    DateTime now = DateTime.now();
    DateTime startOfYear = DateTime(now.year, 1, 1);
    DateTime endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return getEarningsForPeriod(startDate: startOfYear, endDate: endOfYear);
  }

  // Get earnings for current month (for daily chart)
  Future<List<Earning>> getEarningsForCurrentMonth() async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return getEarningsForPeriod(startDate: startOfMonth, endDate: endOfMonth);
  }

  // Get earnings for current week (for daily chart)
  Future<List<Earning>> getEarningsForCurrentWeek() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return getEarningsForPeriod(startDate: startOfWeek, endDate: endOfWeek);
  }

  // Get earnings for today
  Future<List<Earning>> getEarningsForToday() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getEarningsForPeriod(startDate: startOfDay, endDate: endOfDay);
  }

  // Get earnings for last 5 years (for yearly chart)
  Future<List<Earning>> getEarningsForLast5Years() async {
    DateTime now = DateTime.now();
    DateTime startOfPeriod = DateTime(now.year - 4, 1, 1);
    DateTime endOfPeriod = DateTime(now.year, 12, 31, 23, 59, 59);
    
    return getEarningsForPeriod(startDate: startOfPeriod, endDate: endOfPeriod);
  }

  // Create earning record when order is completed
  Future<void> createEarningRecord({
    required String orderId,
    required double amountWithTax,
    required double amountWithoutTax,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .collection("earnings")
          .add({
        'orderId': orderId,
        'amountWithTax': amountWithTax,
        'amountWithoutTax': amountWithoutTax,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error creating earning record: $e");
      rethrow;
    }
  }

  // Update seller's total earnings (this should be called by Cloud Function)
  Future<void> updateTotalEarnings({
    required double totalWithTax,
    required double totalWithoutTax,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .update({
        'totalEarningsWithTax': totalWithTax,
        'totalEarningsWithoutTax': totalWithoutTax,
      });
    } catch (e) {
      print("Error updating total earnings: $e");
      rethrow;
    }
  }
}
