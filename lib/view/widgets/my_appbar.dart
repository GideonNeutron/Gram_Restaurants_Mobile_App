import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget
{
  String titleMsg;
  bool showBackButton;
  PreferredSizeWidget? bottom;

  MyAppBar({
  super.key,
  required this.titleMsg,
  required this.showBackButton,
  this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      backgroundColor: Colors.white,
      leading: showBackButton == true
        ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
            imageFile = null;
          },
          )
        : showBackButton == false
        ? IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: ()
            {
              Scaffold.of(context).openDrawer();
            },
          )
        : Container(),
      centerTitle: true,
      title: Text(
        titleMsg,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: Colors.black,
        ),
      ),

    );
  }

  @override
  Size get preferredSize => bottom == null
      ? Size(57, AppBar().preferredSize.height)
      : Size(57, 80 + AppBar().preferredSize.height);
}
