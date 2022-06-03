import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text("Profile Section"),
        ),
        ElevatedButton(onPressed: () {
          FirebaseAuth.instance.signOut();
          pushNewScreenWithRouteSettings(
            context,
            settings: const RouteSettings(name: WelcomeScreen.id),
            screen: const WelcomeScreen(),
            withNavBar: false, // have to make this false if navigating outside
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        }, child: const Text("Sign-Out"))
      ],
    ));
  }
}
