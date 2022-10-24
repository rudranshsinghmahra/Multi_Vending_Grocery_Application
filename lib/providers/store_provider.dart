import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:multi_vending_grocery_app/services/store_services.dart';

class StoreProvider extends ChangeNotifier {
  StoreServices storeServices = StoreServices();
  final UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;
  var userLatitude = 0.0;
  var userLongitude = 0.0;
  // String? selectedStore;
  // String? selectedStoreId;
  DocumentSnapshot? storeDetails;
  String? distance;
  String? selectedProductCategory;
  String? selectedSubCategory;

  getSelectedStore(storeDetails, distance) {
    this.storeDetails = storeDetails;
    this.distance = distance;
    notifyListeners();
  }

  selectedCategory(category) {
    selectedProductCategory = category;
    notifyListeners();
  }

  selectedCategorySub(subCategory) {
    selectedSubCategory = subCategory;
    notifyListeners();
  }

  String getDistance(location) {
    var distance = Geolocator.distanceBetween(
        userLatitude, userLongitude, location.latitude, location.longitude);
    var distanceInKm = distance / 1000;
    return distanceInKm.toStringAsFixed(2);
  }

  Future<void> getUserLocation(context) async {
    _userServices.getUserDataById(user!.uid).then((value) {
      if (user != null) {
        userLatitude = value['latitude'];
        userLongitude = value['longitude'];
      } else {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
