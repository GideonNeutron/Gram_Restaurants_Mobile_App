import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Position? position;
List<Placemark>? placeMark;
String fullAddress = '';
LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 0,
);
SharedPreferences? sharedPreferences;
XFile? imageFile;
ImagePicker pickerImage = ImagePicker();
List<String> categoryList = [];
double sellerTotalEarnings = 0.0;
double sellerTotalEarningsWithTax = 0.0;  // Add this
double sellerTotalEarningsWithoutTax = 0.0;  // Add this