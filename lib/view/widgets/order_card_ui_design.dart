import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/item.dart';
import '../mainScreens/order_details_screen.dart';

class OrderCardUIDesign extends StatelessWidget
{
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? separateQuantitiesList;
  final String? orderStatus; // Add order status parameter

  OrderCardUIDesign({
    super.key, 
    this.itemCount, 
    this.data, 
    this.orderID, 
    this.separateQuantitiesList,
    this.orderStatus, // Add order status parameter
  });

  @override
  Widget build(BuildContext context) {
    // Determine if this is a cancelled order
    bool isCancelled = orderStatus?.toLowerCase() == 'cancelled';
    
    return InkWell(
      onTap: ()
      {
        // Check if orderID is valid before navigating
        if (orderID != null && orderID!.isNotEmpty) {
          Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDetailScreen(orderID: orderID,)));
        } else {
          // Show error message if orderID is invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Invalid order ID'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        height: itemCount! * 125,
        decoration: BoxDecoration(
          // Apply red background for cancelled orders
          color: isCancelled ? Colors.red.shade50 : Colors.purple.withAlpha(3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCancelled ? Colors.red.shade200 : Colors.grey.shade300,
            width: isCancelled ? 2 : 1,
          ),
        ),
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index)
          {
            try {
              // Add null checks for data and separateQuantitiesList
              if (data == null || data!.isEmpty || 
                  separateQuantitiesList == null || 
                  separateQuantitiesList!.isEmpty ||
                  index >= data!.length ||
                  index >= separateQuantitiesList!.length) {
                return Container(
                  height: 120,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: isCancelled ? Colors.red.shade100 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCancelled ? Colors.red.shade300 : Colors.orange.shade200),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning, color: isCancelled ? Colors.red.shade400 : Colors.orange.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Invalid data at index $index',
                          style: TextStyle(
                            color: isCancelled ? Colors.red.shade600 : Colors.orange.shade600, 
                            fontSize: 12
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              Item model = Item.fromJson(data![index].data()! as Map<String, dynamic>);
              return placedOrderDesignWidget(model, context, separateQuantitiesList![index], isCancelled);
            } catch (e) {
              print('Error parsing item at index $index: $e');
              return Container(
                height: 120,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading item',
                        style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                      ),
                      Text(
                        'Index: $index',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Item model, BuildContext context, String quantityNumber, bool isCancelled)
{
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    height: 120,
    child: Row(
      children: [
        // Item Image with overlay for cancelled orders
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                model.itemImage ?? '',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                  );
                },
              ),
            ),
            // Add red overlay for cancelled orders
            if (isCancelled)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(73),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),

        // Item Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item Title
              Text(
                model.itemTitle ?? 'Unknown Item',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCancelled ? Colors.red.shade700 : Colors.black,
                  //decoration: isCancelled ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Quantity and Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red.shade100 : Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '× $quantityNumber',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCancelled ? Colors.red.shade700 : Colors.blue.shade700,
                      ),
                    ),
                  ),
                  
                  // Price
                  Text(
                    '\$${model.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCancelled ? Colors.red.shade700 : Colors.blue.shade700,
                      //decoration: isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
