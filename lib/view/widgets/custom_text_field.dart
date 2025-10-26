import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget
{
  TextEditingController? textEditingController;
  IconData? iconData;
  String? hintString;
  bool? isObscure = true;
  bool? enabled = true;

  CustomTextField(
      {super.key,
        this.textEditingController,
        this.iconData,
        this.hintString,
        this.isObscure,
        this.enabled,
      });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
{
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        //color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: widget.textEditingController,
        enabled: widget.enabled,
        obscureText: widget.isObscure!,
        decoration: InputDecoration(
          //border: InputBorder.none,
          border: OutlineInputBorder(
            //borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),
          prefixIcon: Icon(
            widget.iconData,
            color: Colors.blueAccent,
          ),
          hintText: widget.hintString,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
