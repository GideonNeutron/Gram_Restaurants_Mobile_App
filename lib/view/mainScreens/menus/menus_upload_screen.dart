import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';


class MenusUploadScreen extends StatefulWidget {
  const MenusUploadScreen({super.key});

  @override
  State<MenusUploadScreen> createState() => _MenusUploadScreenState();
}

class _MenusUploadScreenState extends State<MenusUploadScreen>
{

  TextEditingController titleTextEditingController = TextEditingController();

  defaultScreen()
  {
    return Scaffold(
      appBar: MyAppBar(
        titleMsg: "Add New Menu",
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
                "Add Menu",
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

  uploadMenuFormScreen()
  {
    return Scaffold(
      appBar: MyAppBar(
          titleMsg: "Upload New Menu",
          showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: ()
        {
          setState(() {
            imageFile = null;
            titleTextEditingController.clear();
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
              Icons.title,
              color: Colors.black87,
            ),
            title: TextField(
              style: const TextStyle(color: Colors.black),
              maxLines: 1,
              controller: titleTextEditingController,
              decoration: const InputDecoration(
                hintText: "menu title",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),

          const Divider(
            color: Colors.grey,
            thickness: 1,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: ElevatedButton(
              onPressed: () async
              {
                await menuViewModel.validateMenuUploadForm(
                  titleTextEditingController.text,
                  context,
                );

                setState(() {
                  imageFile = null;
                });

                /*
                  Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                  This is commented out because if the user doesn't selected any things but clicks on
                  the upload button, it still executes and sends the user to the HomeScreen
                */
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
              ),
              child: const Text("Upload", style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Removed menuViewModel.getCategories() since we no longer need categories
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? defaultScreen() : uploadMenuFormScreen();
  }
}
