import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/model/item.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';

class ItemDetailsScreen extends StatefulWidget
{
  Item? itemModel;
  String? menuID;
  ItemDetailsScreen({super.key, this.itemModel, this.menuID});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen>
{
  TextEditingController infoTextEditingController = TextEditingController();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController priceTextEditingController = TextEditingController();
  
  bool? isViewOnly;
  bool showPriceField = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    infoTextEditingController.text = widget.itemModel!.itemInfo ?? '';
    titleTextEditingController.text = widget.itemModel!.itemTitle ?? '';
    descriptionTextEditingController.text = widget.itemModel!.description ?? '';
    priceTextEditingController.text = widget.itemModel!.price?.toStringAsFixed(2) ?? '0.00';
    isViewOnly = widget.itemModel!.isViewOnly ?? false;
    showPriceField = !isViewOnly!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: "Item Details",
        showBackButton: true,
      ),
      body: ListView(
        children: [

          // Item Image
          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.itemModel!.itemImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Edit/Save Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditing ? Colors.red : Colors.blue,
                  ),
                  child: Text(
                    isEditing ? "Cancel" : "Edit",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      // Validate inputs
                      if (infoTextEditingController.text.trim().isEmpty ||
                          titleTextEditingController.text.trim().isEmpty ||
                          descriptionTextEditingController.text.trim().isEmpty) {
                        commonViewModel.showSnackBar("Please fill all required fields", context);
                        return;
                      }

                      if (!isViewOnly! && priceTextEditingController.text.trim().isEmpty) {
                        commonViewModel.showSnackBar("Please enter price for orderable items", context);
                        return;
                      }

                      if (!isViewOnly! && priceTextEditingController.text.trim().isNotEmpty) {
                        double? price = double.tryParse(priceTextEditingController.text.trim());
                        if (price == null || price <= 0) {
                          commonViewModel.showSnackBar("Please enter a valid price", context);
                          return;
                        }
                      }

                      await itemViewModel.updateItemInfo(
                        widget.itemModel!.itemID!,
                        widget.menuID!,
                        infoTextEditingController.text.trim(),
                        titleTextEditingController.text.trim(),
                        descriptionTextEditingController.text.trim(),
                        isViewOnly! ? "0.00" : priceTextEditingController.text.trim(),
                        isViewOnly!,
                        context,
                      );

                      setState(() {
                        isEditing = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10,),
          
          // Item Info
          ListTile(
            leading: const Icon(
              Icons.perm_device_info,
              color: Colors.black87,
            ),
            title: isEditing
                ? TextField(
                    style: const TextStyle(color: Colors.black),
                    maxLines: 1,
                    controller: infoTextEditingController,
                    decoration: const InputDecoration(
                      hintText: "item info",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.itemModel!.itemInfo ?? 'No info available',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Item Title
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.black87,
            ),
            title: isEditing
                ? TextField(
                    style: const TextStyle(color: Colors.black),
                    maxLines: 1,
                    controller: titleTextEditingController,
                    decoration: const InputDecoration(
                      hintText: "item title",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.itemModel!.itemTitle ?? 'No title available',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Item Description
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.black87,
            ),
            title: isEditing
                ? TextField(
                    style: const TextStyle(color: Colors.black),
                    maxLines: 3,
                    controller: descriptionTextEditingController,
                    decoration: const InputDecoration(
                      hintText: "item description",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  )
                : Text(
                    widget.itemModel!.description ?? 'No description available',
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Item Type
          ListTile(
            leading: const Icon(
              Icons.category,
              color: Colors.black87,
            ),
            title: isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isViewOnly = true;
                              showPriceField = false;
                              priceTextEditingController.text = "0.00";
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isViewOnly! ? Colors.blue : Colors.grey.shade300,
                            foregroundColor: isViewOnly! ? Colors.white : Colors.black,
                          ),
                          child: const Text("View Only"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isViewOnly = false;
                              showPriceField = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isViewOnly! ? Colors.blue : Colors.grey.shade300,
                            foregroundColor: !isViewOnly! ? Colors.white : Colors.black,
                          ),
                          child: const Text("Can Order"),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        isViewOnly! ? Icons.visibility : Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isViewOnly! ? "View Only Item" : "Orderable Item",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Price - only show if item can be ordered
          if (showPriceField || (!isViewOnly! && !isEditing))
            ListTile(
              leading: const Icon(
                Icons.price_change,
                color: Colors.black87,
              ),
              title: isEditing && showPriceField
                  ? TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.black),
                      maxLines: 1,
                      controller: priceTextEditingController,
                      decoration: const InputDecoration(
                        hintText: "item price (e.g., 12.99)",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      isViewOnly! ? "N/A" : "\$${widget.itemModel!.price?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
            ),

          if (showPriceField || (!isViewOnly! && !isEditing))
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),

          // Item Status
          ListTile(
            leading: const Icon(
              Icons.info,
              color: Colors.black87,
            ),
            title: Text(
              "Status: ${widget.itemModel!.status ?? 'Unknown'}",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Published Date
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              color: Colors.black87,
            ),
            title: Text(
              "Published: ${widget.itemModel!.publishedDateTime != null ? widget.itemModel!.publishedDateTime!.toDate().toString().split(' ')[0] : 'Unknown'}",
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),

          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
