import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/model/menu.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';
import 'package:sellers_app/viewModel/menu_view_model.dart';

class ItemsUploadScreen extends StatefulWidget
{
  Menu? menuModel;
  ItemsUploadScreen({super.key, this.menuModel});

  @override
  State<ItemsUploadScreen> createState() => _ItemsUploadScreenState();
}

class _ItemsUploadScreenState extends State<ItemsUploadScreen>
{
  TextEditingController infoTextEditingController = TextEditingController();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController priceTextEditingController = TextEditingController();
  
  bool? isViewOnly;
  bool showPriceField = false;

  defaultScreen()
  {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: "Add New Items",
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.shop_two,
              color: Colors.black87,
              size: 200,
            ),

            ElevatedButton(
              onPressed: () async
              {
                String response = await commonViewModel.showDialogWithImageOptions(context);

                if(response == "selected")
                {
                  setState(() {
                    imageFile;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text(
                "Add Items",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  uploadItemFormScreen()
  {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: "Upload New Items",
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: ()
        {
          setState(() {
            imageFile = null;
            infoTextEditingController.clear();
            titleTextEditingController.clear();
            descriptionTextEditingController.clear();
            priceTextEditingController.clear();
            isViewOnly = null;
            showPriceField = false;
          });
        },
        child: const Icon(
          Icons.close,
          color: Colors.black,
        ),
      ),
      body: ListView(
        children: [

          SizedBox(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(
                        File(
                            imageFile!.path
                        ),
                      ),
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

          const SizedBox(height: 10,),
          ListTile(
            leading: const Icon(
              Icons.perm_device_info,
              color: Colors.black87,
            ),
            title: TextField(
              style: const TextStyle(color: Colors.black),
              maxLines: 1,
              controller: infoTextEditingController,
              decoration: const InputDecoration(
                hintText: "item info",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          //title
          ListTile(
            leading: const Icon(
              Icons.title,
              color: Colors.black87,
            ),
            title: TextField(
              style: const TextStyle(color: Colors.black),
              maxLines: 1,
              controller: titleTextEditingController,
              decoration: const InputDecoration(
                hintText: "item title",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          //description
          ListTile(
            leading: const Icon(
              Icons.description,
              color: Colors.black87,
            ),
            title: TextField(
              style: const TextStyle(color: Colors.black),
              maxLines: 1,
              controller: descriptionTextEditingController,
              decoration: const InputDecoration(
                hintText: "item description",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          // Item Type Selection
          if (isViewOnly == null) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Item Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isViewOnly = true;
                          showPriceField = false;
                          priceTextEditingController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
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
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("Can Order"),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
          ],

          // Show selected item type
          if (isViewOnly != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
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
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isViewOnly = null;
                        showPriceField = false;
                        priceTextEditingController.clear();
                      });
                    },
                    child: const Text("Change"),
                  ),
                ],
              ),
            ),

          //price - only show if item can be ordered
          if (showPriceField) ...[
            ListTile(
              leading: const Icon(
                Icons.price_change,
                color: Colors.black87,
              ),
              title: TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.black),
                maxLines: 1,
                controller: priceTextEditingController,
                decoration: const InputDecoration(
                  hintText: "item price (e.g., 12.99)",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton(
              onPressed: () async
              {
                // Validate that item type is selected
                if (isViewOnly == null) {
                  commonViewModel.showSnackBar("Please select item type (View Only or Can Order)", context);
                  return;
                }

                // Validate price for orderable items
                if (!isViewOnly! && priceTextEditingController.text.trim().isEmpty) {
                  commonViewModel.showSnackBar("Please enter price for orderable items", context);
                  return;
                }

                // Validate price format for orderable items
                if (!isViewOnly! && priceTextEditingController.text.trim().isNotEmpty) {
                  double? price = double.tryParse(priceTextEditingController.text.trim());
                  if (price == null || price <= 0) {
                    commonViewModel.showSnackBar("Please enter a valid price", context);
                    return;
                  }
                }

                await itemViewModel.validateItemUploadForm(
                    infoTextEditingController.text.trim(),
                    titleTextEditingController.text.trim(),
                    descriptionTextEditingController.text.trim(),
                    isViewOnly! ? "0.00" : priceTextEditingController.text.trim(),
                    widget.menuModel!,
                    context,
                    isViewOnly!,
                );

                setState(() {
                  imageFile = null;
                  isViewOnly = null;
                  showPriceField = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
              ),
              child: const Text("Upload", style: TextStyle(color: Colors.white),),
            ),
          ),

          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return imageFile == null ? defaultScreen() : uploadItemFormScreen();
  }
}
