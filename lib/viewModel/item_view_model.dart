import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:sellers_app/model/menu.dart';

import '../global/global_instances.dart';
import '../global/global_vars.dart';
import '../view/mainScreens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class ItemViewModel
{
  validateItemUploadForm(infoText, titleText, descriptionText, priceItem, Menu menuModel, context, isViewOnly) async
  {
    if(imageFile != null)
    {
      if(infoText.isNotEmpty && titleText.isNotEmpty && descriptionText.isNotEmpty)
      {
        // For view-only items, price is not required
        if (!isViewOnly && priceItem.isEmpty) {
          commonViewModel.showSnackBar("Please enter price for orderable items.", context);
          return;
        }

        commonViewModel.showSnackBar("Uploading data...", context);
        String uniqueFileID = DateTime.now().millisecondsSinceEpoch.toString();
        String downloadUrl = await uploadImageToStorage(uniqueFileID);
        await saveItemInfoToDatabase(infoText, titleText, descriptionText, priceItem, downloadUrl, menuModel, uniqueFileID, context, isViewOnly);

        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen())); // Added line to execute only after an item has been added
      }
      else
      {
        commonViewModel.showSnackBar("Please fill all required fields.",  context);
      }
    }
    else
    {
      commonViewModel.showSnackBar("Please select item image.", context);
    }
  }

  uploadImageToStorage(uniqueFileID) async
  {
    fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("itemImages");
    fStorage.UploadTask uploadTask = reference.child(uniqueFileID + ".jpg").putFile(File(imageFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveItemInfoToDatabase(infoText, titleText, descriptionText, priceItem, downloadUrl, Menu menuModel, uniqueFileID, context, isViewOnly) async
  {
    final referenceSeller = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(menuModel.menuID)
        .collection("items");
    
    final referenceMain = FirebaseFirestore.instance.collection("items");

    // Ensure price is always stored as double with 2 decimal places
    double priceAsDouble = isViewOnly ? 0.00 : double.parse(priceItem);
    priceAsDouble = double.parse(priceAsDouble.toStringAsFixed(2));

    await referenceSeller.doc(uniqueFileID).set(
      {
        "menuID": menuModel.menuID,
        "menuName": menuModel.menuTitle,
        "itemID": uniqueFileID,
        "sellerUID": sharedPreferences!.getString("uid"),
        "sellerName": sharedPreferences!.getString("name"),
        "itemInfo": infoText,
        "itemTitle": titleText,
        "itemImage": downloadUrl, // Now downloadUrl is properly passed as parameter
        "description": descriptionText,
        "price": priceAsDouble, // Ensure it's double with 2 decimal places
        "publishedDateTime": DateTime.now(),
        "status": "available",
        "isViewOnly": isViewOnly,
      }).then((value) async
      {
        await referenceMain.doc(uniqueFileID).set(
          {
            "menuID": menuModel.menuID,
            "menuName": menuModel.menuTitle,
            "itemID": uniqueFileID,
            "sellerUID": sharedPreferences!.getString("uid"),
            "sellerName": sharedPreferences!.getString("name"),
            "itemInfo": infoText,
            "itemTitle": titleText,
            "itemImage": downloadUrl, // Now downloadUrl is properly passed as parameter
            "description": descriptionText,
            "price": priceAsDouble, // Ensure it's double with 2 decimal places
            "publishedDateTime": DateTime.now(),
            "status": "available",
            "isRecommended": false,
            "isPopular": false,
            "isViewOnly": isViewOnly,
          });
      });

    commonViewModel.showSnackBar("Uploaded Successfully", context);
  }

  retrieveItems(menuID)
  {
    return FirebaseFirestore.instance
      .collection("sellers")
      .doc(sharedPreferences!.getString("uid"))
      .collection("menus")
      .doc(menuID)
      .collection("items")
      .orderBy("publishedDateTime", descending: true)
      .snapshots();
  }

  // Delete a specific item
  deleteItem(itemID, menuID, context) async
  {
    try {
      // Delete from seller's items collection
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .collection("menus")
          .doc(menuID)
          .collection("items")
          .doc(itemID)
          .delete();
      
      // Delete from main items collection
      await FirebaseFirestore.instance
          .collection("items")
          .doc(itemID)
          .delete();
      
      commonViewModel.showSnackBar("Item deleted successfully", context);
    } catch (e) {
      commonViewModel.showSnackBar("Error deleting item: $e", context);
    }
  }

  // Update item information
  updateItemInfo(itemID, menuID, infoText, titleText, descriptionText, priceItem, isViewOnly, context) async
  {
    try {
      // Ensure price is always stored as double with 2 decimal places
      double priceAsDouble = isViewOnly ? 0.00 : double.parse(priceItem);
      priceAsDouble = double.parse(priceAsDouble.toStringAsFixed(2));

      // Update in seller's items collection
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .collection("menus")
          .doc(menuID)
          .collection("items")
          .doc(itemID)
          .update({
        "itemInfo": infoText,
        "itemTitle": titleText,
        "description": descriptionText,
        "price": priceAsDouble,
        "isViewOnly": isViewOnly,
      });
      
      // Update in main items collection
      await FirebaseFirestore.instance
          .collection("items")
          .doc(itemID)
          .update({
        "itemInfo": infoText,
        "itemTitle": titleText,
        "description": descriptionText,
        "price": priceAsDouble,
        "isViewOnly": isViewOnly,
      });
      
      commonViewModel.showSnackBar("Item updated successfully", context);
    } catch (e) {
      commonViewModel.showSnackBar("Error updating item: $e", context);
    }
  }
}