import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/viewModel/common_view_model.dart';

import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
{

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //const SizedBox(height: 11),

          InkWell(
            onTap: () async
            {
              await commonViewModel.pickImageFromGallery();

              setState(() {
                imageFile;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.20,
                backgroundColor: Colors.amber,
                backgroundImage: imageFile == null ? null : FileImage(File(imageFile!.path)),
                child: imageFile == null
                  ? Icon(
                    Icons.add_photo_alternate,
                    size: MediaQuery.of(context).size.width * 0.20,
                    color: Colors.black,
                )
                : null,
              ),
            ),
          ),

          const SizedBox(height: 11,),

          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextField(
                  textEditingController: nameTextEditingController,
                  iconData: Icons.person,
                  hintString: 'Name',
                  isObscure: false,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController: emailTextEditingController,
                  iconData: Icons.email,
                  hintString: 'Email',
                  isObscure: false,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController: phoneTextEditingController,
                  iconData: Icons.phone,
                  hintString: 'Phone number',
                  isObscure: false,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController: locationTextEditingController,
                  iconData: Icons.location_on,
                  hintString: 'Restaurant Address',
                  isObscure: false,
                  enabled: true,
                ),

                Container(
                  width: 398,
                  height: 39,
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                      onPressed: () async
                      {
                        String address = await commonViewModel.getCurrentLocation();

                        setState(() {
                          locationTextEditingController.text = address;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      label: const Text(
                          'Get My Current Location',
                        style:TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                      icon: Icon(Icons.my_location, color: Colors.white),
                  ),
                ),

                CustomTextField(
                  textEditingController: passwordTextEditingController,
                  iconData: Icons.lock,
                  hintString: 'Password',
                  isObscure: true,
                  enabled: true,
                ),
                CustomTextField(
                  textEditingController: confirmPasswordTextEditingController,
                  iconData: Icons.lock,
                  hintString: 'Confirm Password',
                  isObscure: true,
                  enabled: true,
                ),

                ElevatedButton(
                  onPressed: () async
                  {
                    await authViewModel.validateSignUpForm(
                      imageFile,
                      passwordTextEditingController.text.trim(),
                      confirmPasswordTextEditingController.text.trim(),
                      nameTextEditingController.text.trim(),
                      emailTextEditingController.text.trim(),
                      phoneTextEditingController.text.trim(),
                      fullAddress,
                      context,
                    );

                    setState(() {
                      imageFile = null;
                    });

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
