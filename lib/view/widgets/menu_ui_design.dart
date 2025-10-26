import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/model/menu.dart';
import 'package:sellers_app/view/mainScreens/items/items_screen.dart';

class MenuUIDesign extends StatefulWidget
{
  Menu? menuModel;
  MenuUIDesign({super.key, this.menuModel,});

  @override
  State<MenuUIDesign> createState() => _MenuUIDesignState();
}

class _MenuUIDesignState extends State<MenuUIDesign> {
  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemsScreen(menuModel: widget.menuModel,)));
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 270,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [

              Image.network(
                widget.menuModel!.menuImage.toString(),
                width: MediaQuery.of(context).size.width,
                height: 220,
                fit: BoxFit.cover,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    widget.menuModel!.menuTitle?.isNotEmpty == true 
                        ? widget.menuModel!.menuTitle.toString()
                        : "Unknown Menu Name",
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Train",
                    ),
                  ),

                  IconButton(
                    onPressed: () async
                    {
                      // Show confirmation dialog
                      bool? confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Menu'),
                            content: Text('Are you sure you want to delete "${widget.menuModel!.menuTitle ?? "Unknown Menu Name"}"? This will also delete all items in this menu.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await menuViewModel.deleteMenu(widget.menuModel!.menuID!, context);
                      }
                    },
                    icon: const Icon(Icons.delete_sharp, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
