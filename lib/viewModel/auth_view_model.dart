import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel 
{
  validateSignUpForm(XFile? imageXFile, String password, String confirmPassword, String name, String email, String phone, String locationAddress, BuildContext context) async
  {
    if(imageXFile == null)
    {
      commonViewModel.showSnackBar('Please select an image.', context);
      return;
    }
    else 
    {
      if(password.length < 6)
      {
        commonViewModel.showSnackBar("Password should have a minimum length of 6", context);
        return;
      }
      else
      {
        if(password == confirmPassword)
        {
          if(name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty && phone.isNotEmpty && locationAddress.isNotEmpty)
          {
            commonViewModel.showSnackBar("Please wait...", context);
            User? currentFirebaseUser = await createUserInFirebaseAuth(email, password, context);

            String downloadUrl = await uploadImageToStorage(imageXFile);

            await saveUserDataToFirestore(currentFirebaseUser, downloadUrl, name, email, password, locationAddress, phone);

            Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));

            commonViewModel.showSnackBar("Account created successfully.", context);
          }
          else
          {
            commonViewModel.showSnackBar("Please fill all fields", context);
            return;
          }
        }
        else
        {
          commonViewModel.showSnackBar("Passwords do not match.", context);
          return;
        }
      }
    }
  }
  
  createUserInFirebaseAuth(String email, String password, BuildContext context) async
  {
    User? currentFirebaseUser;

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((valueAuth)
    {
      currentFirebaseUser = valueAuth.user;
    }).catchError((errorMsg)
    {
      commonViewModel.showSnackBar(errorMsg, context);
    });

    if(currentFirebaseUser == null)
    {
      FirebaseAuth.instance.signOut();
      return;
    }
    return currentFirebaseUser;
  }

  uploadImageToStorage(XFile? imageXFile) async
  {
    String downloadUrl = '';

    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    fStorage.Reference storageRef = fStorage.FirebaseStorage.instance.ref().child("sellerImages").child(fileName);
    fStorage.UploadTask uploadTask = storageRef.putFile((File(imageXFile!.path)));
    fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    await taskSnapshot.ref.getDownloadURL().then((urlImage)
    {
      downloadUrl = urlImage;
    });
    return downloadUrl;
  }

  saveUserDataToFirestore(currentFirebaseUser, downloadUrl, name, email, password, locationAddress, phone) async
  {
    FirebaseFirestore.instance.collection('sellers').doc(currentFirebaseUser.uid)
      .set(
        {
          "uid": currentFirebaseUser.uid,
          "email": email,
          "name": name,
          "image": downloadUrl,
          "phone": phone,
          "address": locationAddress,
          "status": "approved",
          "earnings": 0.0,
          "latitude": position!.latitude,
          "longtitude": position!.longitude,
        }
      );
    //sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
    await sharedPreferences!.setString("email", email);
    await sharedPreferences!.setString("name", name);
    await sharedPreferences!.setString("email", email);
    await sharedPreferences!.setString("imageUrl", downloadUrl);
  }

  validateSignInForm(String email, String password, BuildContext context) async
  {
    if(email.isNotEmpty && password.isNotEmpty)
    {
      commonViewModel.showSnackBar("Checking Credentials...", context);
      User? currentFirebaseUser = await loginUser(email, password, context);
      await readDataFromFirestoreAndSetDataLocally(currentFirebaseUser, context);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => HomeScreen()), (route) => false);
    }
    else
    {
      commonViewModel.showSnackBar("Fill all fields", context);
      return;
    }
  }

  // loginUser(email, password, context) async
  // {
  //   User? currentFirebaseUser;

  //   await FirebaseAuth.instance.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   ).then((valueAuth)
  //   {
  //     currentFirebaseUser = valueAuth.user;
  //   }).catchError((errorMsg)
  //   {
  //     commonViewModel.showSnackBar(errorMsg, context);
  //   });

  //   if(currentFirebaseUser == null)
  //   {
  //     FirebaseAuth.instance.signOut();
  //     return;
  //   }
  //   return currentFirebaseUser;
  // }

  loginUser(email, password, context) async
  {
  User? currentFirebaseUser;

  try {
    final valueAuth = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    currentFirebaseUser = valueAuth.user;
  } on FirebaseAuthException catch (e) {
    // List of credential-related errors
    if (e.code == 'wrong-password' ||
        e.code == 'user-not-found' ||
        e.code == 'invalid-email') {
      commonViewModel.showSnackBar("Invalid email or password. Try again", context);
    } else {
      // Other Firebase errors
      commonViewModel.showSnackBar("Authentication failed. Try again.", context);
    }
  } catch (error) {
    // Any non-Firebase errors
    commonViewModel.showSnackBar("An unexpected error occurred.", context);
  }

  if (currentFirebaseUser == null) {
    FirebaseAuth.instance.signOut();
    return;
  }

  return currentFirebaseUser;
}


  readDataFromFirestoreAndSetDataLocally(User? currentFirebaseUser, BuildContext context) async
  {
    await FirebaseFirestore.instance
      .collection("sellers")
      .doc(currentFirebaseUser!.uid)
      .get()
      .then((dataSnapshot) async
    {
      if(dataSnapshot.exists)
      {
        if(dataSnapshot.data()!["status"] == "approved")
        {
          await sharedPreferences!.setString("uid", currentFirebaseUser.uid);
          await sharedPreferences!.setString("email", dataSnapshot.data()!["email"]);
          await sharedPreferences!.setString("name", dataSnapshot.data()!["name"]);
          await sharedPreferences!.setString("imageUrl", dataSnapshot.data()!["image"]);
        }
        else
        {
          commonViewModel.showSnackBar("You have not been approved by admin.\nEmail admin on gideonlarbi015@gmail.com for more info.", context);
          FirebaseAuth.instance.signOut();
          return;
        }
      }
      else
      {
        commonViewModel.showSnackBar("Restaurant records does not exist", context);
        FirebaseAuth.instance.signOut();
        return;
      }
    });
  }


  retrieveSellerEarnings() async
  {
    await FirebaseFirestore.instance
        .collection("sellers")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snap)
    {
      sellerTotalEarnings = double.parse(snap.data()!["earnings"].toString());
    });
  }
}
