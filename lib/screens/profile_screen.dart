import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/location_provider.dart';
import 'package:multi_vending_grocery_app/screens/map_screen.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/credit_card_list.dart';
import 'package:multi_vending_grocery_app/screens/profile_update_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'my_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    userDetails.getUserDetails();
    var location = Provider.of<LocationProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Grocery Store",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: userDetails.documentSnapshot == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              color: Colors.redAccent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          child: Text(
                                            userDetails.documentSnapshot != null
                                                ? "${userDetails.documentSnapshot?['firstName'].toString().substring(0, 1)}"
                                                : "1",
                                            style: const TextStyle(
                                                fontSize: 50,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          height: 70,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                userDetails.documentSnapshot !=
                                                        null
                                                    ? "${userDetails.documentSnapshot?['firstName']} ${userDetails.documentSnapshot?['lastName']}"
                                                    : "Update Your Name",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                              if (userDetails.documentSnapshot?[
                                                      'email'] !=
                                                  null)
                                                Text(
                                                  "${userDetails.documentSnapshot?['email']}",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                              Text(
                                                user!.phoneNumber.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (userDetails.documentSnapshot != null)
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.location_on,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          title: Text(userDetails
                                              .documentSnapshot?['location']),
                                          subtitle: Text(
                                            userDetails
                                                .documentSnapshot?['address'],
                                            maxLines: 2,
                                          ),
                                          trailing: OutlinedButton(
                                            child: Text("Change"),
                                            onPressed: () {
                                              EasyLoading.show(
                                                  status: "Please Wait...");
                                              location
                                                  .getMyCurrentPosition()
                                                  .then((value) {
                                                if (value != null) {
                                                  EasyLoading.dismiss();
                                                  pushNewScreenWithRouteSettings(
                                                    context,
                                                    settings:
                                                        const RouteSettings(
                                                            name: MapScreen.id),
                                                    screen: const MapScreen(),
                                                    pageTransitionAnimation:
                                                        PageTransitionAnimation
                                                            .cupertino,
                                                  );
                                                } else {
                                                  EasyLoading.dismiss();
                                                  print(
                                                      "Permission Not Allowed");
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                                right: 10.0,
                                top: 10.0,
                                child: IconButton(
                                  color: Colors.white,
                                  onPressed: () {
                                    pushNewScreenWithRouteSettings(
                                      context,
                                      settings: const RouteSettings(
                                          name: UpdateProfile.id),
                                      withNavBar: false,
                                      screen: const UpdateProfile(),
                                      pageTransitionAnimation:
                                          PageTransitionAnimation.cupertino,
                                    );
                                  },
                                  icon: const Icon(Icons.edit_outlined),
                                ))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: const RouteSettings(
                                    name: MyOrdersScreen.id),
                                screen: const MyOrdersScreen(),
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.history),
                            title: Text("My Orders"),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: const RouteSettings(
                                    name: CreditCardList.id),
                                screen: const CreditCardList(),
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.credit_card),
                            title: const Text("Manage Cards"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.comment_outlined),
                            title: Text("My Ratings And Reviews"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.notifications_none),
                            title: Text("Notifications"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: ListTile(
                            horizontalTitleGap: 2,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.power_settings_new),
                            title: Text("Logout"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ));
  }
}
