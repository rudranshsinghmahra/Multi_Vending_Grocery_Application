import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:multi_vending_grocery_app/services/store_services.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cart_list.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cod_toggle.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_bar/toggle_bar.dart';

import '../constants.dart';
import '../providers/location_provider.dart';
import 'map_screen.dart';

class CartScreen extends StatefulWidget {
  static const String id = "cart-screen";
  const CartScreen({Key? key, this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  StoreServices _store = StoreServices();
  UserServices _userServices = UserServices();
  User? user = FirebaseAuth.instance.currentUser;

  DocumentSnapshot? dSnapshot;
  var textStyle = TextStyle(color: Colors.grey);
  int discount = 100;
  int deliveryFee = 50;
  bool _loading = false;
  bool _checkingUser = false;

  String? _location = "";
  String? _address = "";

  @override
  void initState() {
    getPreferences();
    _store.getShopDetails(widget.documentSnapshot?['sellerUid']).then((value) {
      setState(() {
        dSnapshot = value;
      });
    });
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
    var _cartProvider = Provider.of<CartProvider>(context);
    var payable = _cartProvider.subTotal + deliveryFee - discount;
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      bottomSheet: Container(
        height: 160,
        color: Colors.blueGrey[900],
        child: Column(
          children: [
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Deliver to this Address : ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _loading = false;
                            });
                            locationData.getMyCurrentPosition().then((value) {
                              if (value != null) {
                                setState(() {
                                  _loading = false;
                                });
                                pushNewScreenWithRouteSettings(
                                  context,
                                  settings:
                                      const RouteSettings(name: MapScreen.id),
                                  screen: const MapScreen(),
                                  withNavBar:
                                      false, // have to make this false if navigating outside
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.cupertino,
                                );
                              } else {
                                showAlert("Location Permission not Allowed");
                              }
                            });
                          },
                          child: _loading
                              ? CircularProgressIndicator()
                              : Text(
                                  "Change",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 15),
                                ),
                        )
                      ],
                    ),
                    Flexible(
                      child: Text(
                        "$_location, $_address",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "\Rs ${_cartProvider.subTotal.toStringAsFixed(0)}",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Including Taxes",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _checkingUser = true;
                        });
                        _userServices.getUserDataById(user!.uid).then((value) {
                          if (value['id'] == null) {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings:
                                  const RouteSettings(name: ProfileScreen.id),
                              screen: const ProfileScreen(),
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          } else {
                            //Confirm Payment Method
                            setState(() {
                              _checkingUser = false;
                            });
                            if (_cartProvider.cod == true) {
                              print("Cash on Delivery");
                            } else {
                              print("Will Pay Online");
                            }
                          }
                        });
                      },
                      child: _checkingUser
                          ? CircularProgressIndicator()
                          : Text("CHECKOUT"),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext, bool innerBozIsSxrolled) {
          return [
            SliverAppBar(
              iconTheme: IconThemeData.fallback(),
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot?['shopName'],
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Row(
                    children: [
                      Text(
                        "${_cartProvider.cartQty} ${_cartProvider.cartQty > 1 ? "Items" : "Item"}",
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        "To Pay : \Rs ${_cartProvider.subTotal.toStringAsFixed(0)}",
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      )
                    ],
                  )
                ],
              ),
            ),
          ];
        },
        body: _cartProvider.cartQty > 0
            ? SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 56),
                child: Container(
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          if (dSnapshot != null)
                            Column(children: [
                              ListTile(
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      dSnapshot?['imageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Text(dSnapshot?['shopName']),
                                subtitle: Text(
                                  dSnapshot?['address'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                              CodToggleSwitch(),
                              Divider(
                                color: Colors.grey[300],
                              )
                            ]),
                          CartList(
                            documentSnapshot: widget.documentSnapshot,
                          ),
                          Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, right: 10, left: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 36,
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Enter Voucher Code",
                                            filled: true,
                                            fillColor: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: const Text("Apply"),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 4.0, left: 4.0, top: 4.0, bottom: 130),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Billing Details",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Basket Value",
                                            style: textStyle,
                                          )),
                                          Text(
                                            _cartProvider.subTotal
                                                .toStringAsFixed(0),
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Discount",
                                            style: textStyle,
                                          )),
                                          Text(
                                            "- \Rs $discount",
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Delivery",
                                            style: textStyle,
                                          )),
                                          Text(
                                            "\Rs $deliveryFee",
                                            style: textStyle,
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                            "Total Amount Payable",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                          Text(
                                            "\Rs ${payable.toStringAsFixed(0)}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Total Saving",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .deepPurpleAccent),
                                                ),
                                              ),
                                              Text(
                                                "\Rs ${_cartProvider.savings.toStringAsFixed(0)}",
                                                style: TextStyle(
                                                    color: Colors
                                                        .deepPurpleAccent),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  "Cart is Empty , Please add some products",
                  textAlign: TextAlign.center,
                ),
              ),
      ),
    );
  }
}
