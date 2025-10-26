import 'package:flutter/material.dart';

import '../mainScreens/home_screen.dart';

class StatusBanner extends StatelessWidget
{
  bool? status;
  String? orderStatus;

  StatusBanner({super.key, this.status, this.orderStatus});

  @override
  Widget build(BuildContext context)
  {
    String? message;
    IconData? iconData;

    status! ? iconData = Icons.done : iconData = Icons.cancel;
    status! ? message = "Successful" : message = "Unsuccessful";

    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),

          const SizedBox(width: 20,),

          Text(
            orderStatus == "ended" ? "Parcel Delivered $message" : "Order Placed $message",
          ),

          const SizedBox(width: 5,),

          CircleAvatar(
            radius: 8,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.green,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
