import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/model/menu.dart';
import 'package:sellers_app/view/mainScreens/items/items_upload_screen.dart';
import 'package:sellers_app/view/widgets/my_appbar.dart';
import 'package:sellers_app/view/widgets/my_drawer.dart';
import '../../../model/item.dart';
import '../../widgets/item_ui_design.dart';

class ItemsScreen extends StatefulWidget
{
  final Menu? menuModel;
  const ItemsScreen({super.key, this.menuModel});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //drawer:MyDrawer(),
      appBar: MyAppBar(
        titleMsg: widget.menuModel!.menuTitle.toString(),
        showBackButton: true,
      ),
      floatingActionButton: SizedBox(
        width: 120,
        child: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsUploadScreen(menuModel: widget.menuModel,)));
          },
          child: const Text(
            "Add New Item",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemViewModel.retrieveItems(widget.menuModel!.menuID),
        builder: (context, snapshot)
        {
          return !snapshot.hasData
              ? const Center(child: Text("No Data Available"),)
              : ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index)
            {
              //return Container();
              Item itemModel = Item.fromJson(
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>
              );

              return Card(
                elevation: 6,
                color: Colors.black87,
                child: ItemUIDesign(
                  itemModel: itemModel,
                  menuID: widget.menuModel!.menuID, // Pass menuID to ItemUIDesign
                ),
              );
            },
          );
        },
      ),
    );
  }
}
