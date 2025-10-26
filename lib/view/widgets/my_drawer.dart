import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellers_app/global/global_instances.dart';
import 'package:sellers_app/global/global_vars.dart';
import 'package:sellers_app/view/mainScreens/earnings_screen.dart';
import 'package:sellers_app/view/mainScreens/history_screen.dart';
import 'package:sellers_app/view/mainScreens/home_screen.dart';
import 'package:sellers_app/view/mainScreens/new_orders_screen.dart';
import 'package:sellers_app/view/splashScreen/splash_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          //header
          Container(
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                //image
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(81)),
                  elevation: 8,
                  child: SizedBox(
                    height: 158,
                    width: 158,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        sharedPreferences!.getString("imageUrl").toString(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10,),

                Text(
                  sharedPreferences!.getString("name").toString(),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12,),
          
          //body
          Container(
            child: Column(
              children: [

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text("Home"),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.monetization_on_outlined),
                  title: const Text("My Earnings"),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => EarningsScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text("New Orders"),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => NewOrdersScreen()));
                  },
                ),
                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("History"),
                  onTap: ()
                  {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen()));
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.share_location),
                  title: const Text("Update Address"),
                  onTap: ()
                  {
                    commonViewModel.updateLocationInDatabase();
                    commonViewModel.showSnackBar("Address updated.", context);
                  },
                ),

                const Divider(
                  height: 10,
                  color: Colors.grey,
                  thickness: 2,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: ()
                  {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));
                  },
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}