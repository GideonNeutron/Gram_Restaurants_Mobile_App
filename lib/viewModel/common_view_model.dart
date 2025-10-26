import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_vars.dart';

class CommonViewModel 
{
  getCurrentLocation() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    position = cPosition;
    placeMark = await placemarkFromCoordinates(cPosition.latitude, cPosition.longitude);
    Placemark placeMarkVar = placeMark![0];
    fullAddress = '${placeMarkVar.subThoroughfare} ${placeMarkVar.thoroughfare}, ${placeMarkVar.subLocality} ${placeMarkVar.locality}, ${placeMarkVar.subAdministrativeArea}, ${placeMarkVar.administrativeArea} ${placeMarkVar.postalCode}, ${placeMarkVar.country}';
    return fullAddress;
  }

  updateLocationInDatabase() async
  {
    String address = await getCurrentLocation();

    await FirebaseFirestore.instance
      .collection("sellers")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .update(
        {
          "address": address,
          "latitude": position!.latitude,
          "longitude": position!.longitude,
        }
      );
  }

  showSnackBar(String message, BuildContext context)
  {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showDialogWithImageOptions(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (context)
        {
          return SimpleDialog(
            title: const Text(
              "Choose Option",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [

              const Divider(
                //height: 10,
                color: Colors.grey,
                thickness: 2,
              ),

              SimpleDialogOption(
                onPressed: () async
                {
                  await captureImageWithCamera();

                  Navigator.pop(context, "selected");
                },
                child: const Text(
                  "Capture With Camera",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SimpleDialogOption(
                onPressed: () async
                {
                  await pickImageFromGallery();

                  Navigator.pop(context, "selected");
                },
                child: const Text(
                  "Select From Gallery",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SimpleDialogOption(
                onPressed: ()
                {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
    );
  }

  pickImageFromGallery() async
  {
    imageFile = await pickerImage.pickImage(source: ImageSource.gallery);
  }

  captureImageWithCamera() async
  {
    imageFile = await pickerImage.pickImage(source: ImageSource.camera);
  }
}