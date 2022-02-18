import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  User? user = FirebaseAuth.instance.currentUser;
  String? _location;
  String? _address;
  bool isLoading = true;

  @override
  void initState() {
    UserServices userServices = UserServices();
    userServices.getUserDataById(user!.uid).then((value) async {
      if (value != null) {
        if (value['latitude'] != null) {
          getPreferences(value);
        } else {
          locationProvider.getMyCurrentPosition();
          if (locationProvider.selectedAddress !=null) {
            Navigator.pushNamed(context, MapScreen.id);
          } else {
            print('Permission Not Allowed');
          }
        }
      }
    });
    super.initState();
  }

  getPreferences(dbResult) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? location = sharedPreferences.getString('location');
    if (location == null) {
      sharedPreferences.setString('address', dbResult['location']);
      sharedPreferences.setString('location', dbResult['address']);
      if(mounted){
        setState(() {
          _location = dbResult['location'];
          _address = dbResult['address'];
          isLoading = false;
        });
      }
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    }
    Navigator.pushReplacementNamed(context, HomeScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_location == null ? '' :  "$_location"),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _address == null ? "Delivery Address Not Set" :  "$_address",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 25
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _address == null
                    ? "Please update your Delivery Location to find nearest store for you"
                    : "${_address}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const CircularProgressIndicator(),
            SizedBox(width: 500,child: Image.asset('assets/city.png',fit: BoxFit.fill,color: Colors.grey,),),
            Visibility(
              visible: _location == null ? true:false,
              child: ElevatedButton(onPressed: (){
                locationProvider.getMyCurrentPosition();
                if(locationProvider.permissionAllowed==true){
                  Navigator.pushReplacementNamed(context, MapScreen.id);
                }else{
                  print("Permission Not Allowed");
                }
              }, child: Text(_location != null ? " Update Location " : "Set Your Location",style: TextStyle(fontSize: 20),)),
            )
          ],
        ),
      ),
    );
  }
}
