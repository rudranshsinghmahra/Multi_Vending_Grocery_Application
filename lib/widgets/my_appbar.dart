import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/constants.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/screens/welcome_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String? _location = "";
  String? _address = "";

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      _location = location;
      _address = address;
      print(_address);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    return SliverAppBar(
      expandedHeight: 150,
      automaticallyImplyLeading: true,
      elevation: 0.0,
      floating: true,
      snap: true,
      title: TextButton(
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        onPressed: () {
          locationData.getMyCurrentPosition().then((value) {
            if (value != null) {
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: MapScreen.id),
                screen: const MapScreen(),
                withNavBar:
                    false, // have to make this false if navigating outside
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            } else {
              showAlert("Location Permission not Allowed");
            }
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _location ?? "Set Delivery Address",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Text(
                _address == null ? "Please set Delivery Location" : "$_address",
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: IconButton(
            icon: const Icon(
              Icons.logout,
              size: 25,
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: WelcomeScreen.id),
                screen: const WelcomeScreen(),
                withNavBar:
                    false, // have to make this false if navigating outside
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 5),
          child: IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 25,
            ),
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                context,
                settings: const RouteSettings(name: ProfileScreen.id),
                screen: const ProfileScreen(),
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
          ),
        )
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  color: Colors.grey,
                  onPressed: () {},
                ),
                hintText: "Search",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
