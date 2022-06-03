import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/constants.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/home_screen.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);
  static const id = "landing-screen";

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider locationProvider = LocationProvider();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Delivery Address Not Set",
                // _address == null ? "Delivery Address Not Set" :  "$_address",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 25),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Please update your Delivery Location to find nearest store for you",
                // _address == null
                //     ? "Please update your Delivery Location to find nearest store for you"
                //     : "${_address}",
                style: TextStyle(color: Colors.grey, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            // const CircularProgressIndicator(),
            SizedBox(
              width: 500,
              child: Image.asset(
                'assets/city.png',
                fit: BoxFit.fill,
                color: Colors.grey,
              ),
            ),
            // Visibility(
            //   visible: _location == null ? true:false,
            //   child: ElevatedButton(onPressed: (){
            //     locationProvider.getMyCurrentPosition();
            //     if(locationProvider.permissionAllowed==true){
            //       Navigator.pushReplacementNamed(context, MapScreen.id);
            //     }else{
            //       print("Permission Not Allowed");
            //     }
            //   }, child: Text(_location != null ? " Update Location " : "Set Your Location",style: TextStyle(fontSize: 20),)),
            // )
            isLoading ? const Center(child: CircularProgressIndicator(),) : ElevatedButton(
              onPressed: () async{
                setState(() {
                  isLoading = true;
                });
                await locationProvider.getMyCurrentPosition();
                if (locationProvider.permissionAllowed == true) {
                  Navigator.pushReplacementNamed(context, MapScreen.id);
                } else {
                  Future.delayed(const Duration(seconds: 4),(){
                    if(locationProvider.permissionAllowed == false){
                      print("Permission Not Allowed");
                      setState(() {
                        isLoading = false;
                      });
                      showAlert("Allow Location Permission to find nearest stores");
                    }
                  });
                }
              },
              child: const Text(
                  "Set Your Location",
                // _location != null ? " Update Location " : "Set Your Location",
                // style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
