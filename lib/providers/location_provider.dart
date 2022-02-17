import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:multi_vending_grocery_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;
  bool permissionAllowed = true;
  var selectedAddress;
  bool isLoading = false;

  Future<void> getMyCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permissionAllowed = false;
      showAlert("Location Permission is Denied. Allow to use app");
    } else if (permission == LocationPermission.deniedForever) {
      permissionAllowed = false;
      showAlert("Location Permission is Denied Forever. Enable in Settings");
    } else {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (position != null) {
        permissionAllowed = true;
        notifyListeners();
        latitude = position.latitude;
        longitude = position.longitude;

        final coordinates = Coordinates(latitude, longitude);
        final addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        print("Is My Address Rudransh Singh is ${addresses}");
        selectedAddress = addresses.first;
      } else {
        print("Permissions Not Allowed");
      }
    }
  }

  void onCameraMove(CameraPosition cameraPosition) async {
    latitude = cameraPosition.target.latitude;
    longitude = cameraPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = Coordinates(latitude, longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    selectedAddress = addresses.first;
    notifyListeners();
    print("${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', latitude);
    prefs.setDouble('longitude', longitude);
    prefs.setString('address', selectedAddress.addressLine);
    prefs.setString('location', selectedAddress.featureName);
  }
}
