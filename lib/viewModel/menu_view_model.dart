import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

class MenuViewModel
{
  validateMenuUploadForm(titleText, context) async
  {
    if(imageFile != null)
    {
      if(titleText.isNotEmpty)
      {
        commonViewModel.showSnackBar("Uploading data...", context);
        String uniqueFileID = DateTime.now().millisecondsSinceEpoch.toString();
        String downloadUrl = await uploadImageToStorage(uniqueFileID);
        await saveMenuInfoToDatabase(titleText, downloadUrl, uniqueFileID, context);

        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
      }
      else
      {
        commonViewModel.showSnackBar("Please enter menu title.",  context);
      }
    }
    else
    {
      commonViewModel.showSnackBar("Please select menu image.", context);
    }
  }

  uploadImageToStorage(uniqueFileID) async
  {

    fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("menuImages");
    fStorage.UploadTask uploadTask = reference.child(uniqueFileID + ".jpg").putFile(File(imageFile!.path));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  saveMenuInfoToDatabase(titleText, downloadUrl, uniqueFileID, context) async
  {
    //String uniqueFileID = DateTime.now().millisecondsSinceEpoch.toString();

    final reference = FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus");

    await reference.doc(uniqueFileID).set(
      {
        "menuID": uniqueFileID,
        "sellerUID": sharedPreferences!.getString("uid"),
        "sellerName": sharedPreferences!.getString("name"),
        "menuTitle": titleText,
        "menuImage": downloadUrl,
        "publishedDateTime": DateTime.now(),
        "status": "available",
      }
    );
    commonViewModel.showSnackBar("Uploaded Successfully", context);
  }

  retrieveMenus()
  {
    return FirebaseFirestore.instance
      .collection("sellers")
      .doc(sharedPreferences!.getString("uid"))
      .collection("menus")
      .orderBy("publishedDateTime", descending: true)
      .snapshots();
  }

  // Delete menu and all its items
  deleteMenu(menuID, context) async
  {
    try {
      // First, delete all items in this menu
      await deleteAllItemsInMenu(menuID);
      
      // Then delete the menu itself
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(sharedPreferences!.getString("uid"))
          .collection("menus")
          .doc(menuID)
          .delete();
      
      commonViewModel.showSnackBar("Menu deleted successfully", context);
    } catch (e) {
      commonViewModel.showSnackBar("Error deleting menu: $e", context);
    }
  }

  // Delete all items in a menu
  deleteAllItemsInMenu(menuID) async
  {
    // Get all items in the menu
    QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .collection("menus")
        .doc(menuID)
        .collection("items")
        .get();

    // Delete each item from both seller's collection and main items collection
    for (QueryDocumentSnapshot itemDoc in itemsSnapshot.docs) {
      String itemID = itemDoc.id;
      
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
    }
  }
}