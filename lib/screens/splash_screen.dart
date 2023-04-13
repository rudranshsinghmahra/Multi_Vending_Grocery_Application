import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/screens/landing_screen.dart';
import 'package:multi_vending_grocery_app/screens/main_screen.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id = 'splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    Timer(const Duration(seconds: 3), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        } else {
          //if user has data in Firestore check delivery address set or not.
          getUserData();
        }
      });
    });
    super.initState();
  }

  getUserData() async {
    UserServices services = UserServices();
    services.getUserDataById(user!.uid).then((value) {
      //check location data exists or not
      if (value['location'] != null) {
        updatePreferences(value);
      } else {
        //if address details does not exists
        Navigator.pushReplacementNamed(context, LandingScreen.id);
      }
    });
  }

  Future<void> updatePreferences(result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', result['latitude']);
    prefs.setDouble('longitude', result['longitude']);
    prefs.setString('address', result['address']);
    prefs.setString('location', result['location']);
    //After updating preferences , Navigate to Home Screen
    Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: SizedBox(
              height: 150,
              width: 150,
              child: Center(
                child: Hero(
                  tag: 'logo',
                  child: Image.asset('assets/logo.png'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
