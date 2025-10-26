import 'package:cloud_firestore/cloud_firestore.dart';

class Menu
{
  String? menuID;
  String? sellerUID;
  String? sellerName;
  String? menuTitle;
  String? menuInfo;
  String? menuImage;
  Timestamp? publishedDateTime;
  String? status;

  Menu ({
    this.menuID,
    this.sellerUID,
    this.sellerName,
    this.menuTitle,
    this.menuInfo,
    this.menuImage,
    this.publishedDateTime,
    this.status,
  });

  Menu.fromJson(Map<String, dynamic> json)
  {
    menuID = json["menuID"];
    sellerUID = json["sellerUID"];
    sellerName = json["sellerName"];
    menuTitle= json["menuTitle"];
    menuInfo = json["menuInfo"];
    menuImage = json["menuImage"];
    publishedDateTime = json["publishedDateTime"];
    status = json["status"];
  }
}


