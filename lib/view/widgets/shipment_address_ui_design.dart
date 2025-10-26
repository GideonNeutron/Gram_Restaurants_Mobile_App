import 'package:flutter/material.dart';

import '../../model/address.dart';
import '../mainScreens/home_screen.dart';

class ShipmentAddressUIDesign extends StatelessWidget
{
  String? orderStatus;
  Address? model;

  ShipmentAddressUIDesign({super.key, this.orderStatus, this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Shipping Details: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 6,),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [

              TableRow(
                children: [
                  const Text(
                    "Name",
                  ),
                  Text(model!.name!),
                ],
              ),

              TableRow(
                children: [
                  const Text(
                    "Phone Number",
                  ),
                  Text(model!.phoneNumber!),
                ]
              ),
            ],
          ),
        ),

        const SizedBox(height: 20,),
        
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            model!.fullAddress!,
            textAlign: TextAlign.justify,
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Container(
                color: Colors.blue,
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: Center(
                  child: Text(
                    orderStatus == "ended" ? "Go back" : "Order Packing - Done",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
