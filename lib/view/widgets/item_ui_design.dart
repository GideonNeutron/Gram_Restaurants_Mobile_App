import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/model/item.dart';
import 'package:sellers_app/view/mainScreens/items/item_details_screen.dart';

class ItemUIDesign extends StatefulWidget
{
  Item? itemModel;
  String? menuID;
  ItemUIDesign({super.key, this.itemModel, this.menuID});

  @override
  State<ItemUIDesign> createState() => _ItemUIDesignState();
}

class _ItemUIDesignState extends State<ItemUIDesign> {
  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (c) => ItemDetailsScreen(itemModel: widget.itemModel, menuID: widget.menuID)));
      },
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 270,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [

              Image.network(
                widget.itemModel!.itemImage.toString(),
                width: MediaQuery.of(context).size.width,
                height: 220,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 2,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      widget.itemModel!.itemTitle.toString(),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontFamily: "Train",
                      ),
                      textAlign: TextAlign.center,
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
                            title: const Text('Delete Item'),
                            content: Text('Are you sure you want to delete "${widget.itemModel!.itemTitle}"?'),
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
                        await itemViewModel.deleteItem(widget.itemModel!.itemID!, widget.menuID!, context);
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
