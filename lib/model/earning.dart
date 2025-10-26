import 'package:cloud_firestore/cloud_firestore.dart';

class Earning {
  String? orderId;
  double? amountWithTax;
  double? amountWithoutTax;
  Timestamp? completedAt;

  Earning({
    this.orderId,
    this.amountWithTax,
    this.amountWithoutTax,
    this.completedAt,
  });

  Earning.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    amountWithTax = json['amountWithTax']?.toDouble();
    amountWithoutTax = json['amountWithoutTax']?.toDouble();
    completedAt = json['completedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amountWithTax': amountWithTax,
      'amountWithoutTax': amountWithoutTax,
      'completedAt': completedAt,
    };
  }
}
