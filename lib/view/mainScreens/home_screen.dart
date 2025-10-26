import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/model/menu.dart';
import 'package:sellers_app/view/mainScreens/menus/menus_upload_screen.dart';
import 'package:sellers_app/view/widgets/menu_ui_design.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';
import 'package:sellers_app/view/widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authViewModel.retrieveSellerEarnings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:MyDrawer(),
      appBar: MyAppBar(
          titleMsg: sharedPreferences!.getString("name").toString() + "'s Menu",
          showBackButton: false,
      ),
      floatingActionButton: SizedBox(
        width: 120,
        child: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (c) => MenusUploadScreen()));
          },
          child: const Text(
            "Add New Menu",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: menuViewModel.retrieveMenus(),
        builder: (context, snapshot)
        {
          return !snapshot.hasData
            ? const Center(child: Text("No Data Available"),)
            : ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index)
              {
                Menu menuModel = Menu.fromJson(
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>
                );

                return Card(
                  elevation: 6,
                  color: Colors.black87,
                  child: MenuUIDesign(
                    menuModel: menuModel,
                  ),
                );
              },
          );
        },
      ),
    );
  }
}
