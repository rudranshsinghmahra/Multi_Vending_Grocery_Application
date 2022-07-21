import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_vending_grocery_app/providers/auth_provider.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/providers/coupons_provider.dart';
import 'package:multi_vending_grocery_app/providers/orders_provider.dart';
import 'package:multi_vending_grocery_app/screens/payments/stripe/payment_home.dart';
import 'package:multi_vending_grocery_app/screens/profile_screen.dart';
import 'package:multi_vending_grocery_app/services/order_services.dart';
import 'package:multi_vending_grocery_app/services/services_user.dart';
import 'package:multi_vending_grocery_app/services/store_services.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cart_list.dart';
import 'package:multi_vending_grocery_app/widgets/cart/coupon_widget.dart';
import 'package:multi_vending_grocery_app/widgets/cart/cod_toggle.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../providers/location_provider.dart';
import '../services/cart_services.dart';
import 'map_screen.dart';

class CartScreen extends StatefulWidget {
  static const String id = "cart-screen";
  const CartScreen({Key? key, this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final StoreServices _store = StoreServices();
  final UserServices _userServices = UserServices();
  final OrderService _orderService = OrderService();
  User? user = FirebaseAuth.instance.currentUser;
  final CartServices _cartServices = CartServices();

  DocumentSnapshot? dSnapshot;
  var textStyle = const TextStyle(color: Colors.grey);
  double discount = 0.0;
  var deliveryFee = 50.0;
  bool _loading = false;
  bool _checkingUser = false;

  String? location = "";
  String? address = "";

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
      this.location = location;
      this.address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);
    var _couponProvider = Provider.of<CouponProvider>(context);
    var payable = _cartProvider.subTotal + deliveryFee - discount;
    final locationData = Provider.of<LocationProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    userDetails.getUserDetails().then((value) {
      double subTotal = _cartProvider.subTotal;
      double discountRate = _couponProvider.discountRate / 100;
      setState(() {
        discount = subTotal * discountRate;
      });
    });
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      bottomSheet: userDetails.documentSnapshot == null
          ? Container()
          : Container(
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
                              const Expanded(
                                child: Text(
                                  "Deliver to this Address : ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _loading = false;
                                  });
                                  locationData
                                      .getMyCurrentPosition()
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        _loading = false;
                                      });
                                      pushNewScreenWithRouteSettings(
                                        context,
                                        settings: const RouteSettings(
                                            name: MapScreen.id),
                                        screen: const MapScreen(),
                                        withNavBar:
                                            false, // have to make this false if navigating outside
                                        pageTransitionAnimation:
                                            PageTransitionAnimation.cupertino,
                                      );
                                    } else {
                                      showAlert(
                                          "Location Permission not Allowed");
                                    }
                                  });
                                },
                                child: _loading
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        "Change",
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 15),
                                      ),
                              )
                            ],
                          ),
                          Flexible(
                            child: Text(
                              userDetails.documentSnapshot?['firstName'] != null
                                  ? "${userDetails.documentSnapshot?['firstName']} ${userDetails.documentSnapshot?['lastName']} : $location, $address"
                                  : "$location, $address",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 15),
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
                                "Rs ${payable.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "Including Taxes",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              EasyLoading.show(status: "Please Wait...");
                              _userServices
                                  .getUserDataById(user!.uid)
                                  .then((value) {
                                if (value['firstName'] == null) {
                                  EasyLoading.dismiss();
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: const RouteSettings(
                                        name: ProfileScreen.id),
                                    screen: const ProfileScreen(),
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                } else {
                                  EasyLoading.dismiss();
                                  // EasyLoading.show(status: "Please Wait....");
                                  //TODO: PAYMENT GATEWAY INTEGRATION
                                  if (_cartProvider.cod == false) {
                                    //Pay Online
                                    orderProvider.totalAmountPayable(
                                        payable,
                                        widget.documentSnapshot?['shopName'],
                                        userDetails.documentSnapshot?['email']);
                                    Navigator.pushNamed(context, PaymentHome.id)
                                        .whenComplete(() {
                                      print(orderProvider.success);
                                      if (orderProvider.success == true) {
                                        _saveOrder(_cartProvider, payable,
                                            _couponProvider, orderProvider);
                                      }
                                    });
                                  } else {
                                    // Cash On Delivery
                                    _saveOrder(_cartProvider, payable,
                                        _couponProvider, orderProvider);
                                  }
                                }
                              });
                            },
                            child: _checkingUser
                                ? const CircularProgressIndicator()
                                : const Text("CHECKOUT"),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.redAccent)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBozIsSxrolled) {
          return [
            SliverAppBar(
              iconTheme: const IconThemeData.fallback(),
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
                        "To Pay : Rs ${payable.toStringAsFixed(0)}",
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
        body: dSnapshot == null
            ? const Center(child: CircularProgressIndicator())
            : _cartProvider.cartQty > 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 56),
                    child: Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Column(children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  leading: SizedBox(
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
                                const CodToggleSwitch(),
                                Divider(
                                  color: Colors.grey[300],
                                )
                              ]),
                              CartList(
                                documentSnapshot: widget.documentSnapshot,
                              ),
                              CouponWidget(
                                couponVendor: dSnapshot?['uid'],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4.0,
                                    left: 4.0,
                                    top: 4.0,
                                    bottom: 130),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Billing Details",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
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
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          if (discount > 0)
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  "Discount",
                                                  style: textStyle,
                                                )),
                                                Text(
                                                  "- \Rs ${discount.toStringAsFixed(0)}",
                                                  style: textStyle,
                                                ),
                                              ],
                                            ),
                                          const SizedBox(
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
                                                "Rs $deliveryFee",
                                                style: textStyle,
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              const Expanded(
                                                  child: Text(
                                                "Total Amount Payable",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                              Text(
                                                "\Rs ${payable.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      "Total Saving",
                                                      style: TextStyle(
                                                          color: Colors
                                                              .deepPurpleAccent),
                                                    ),
                                                  ),
                                                  Text(
                                                    "Rs ${_cartProvider.savings.toStringAsFixed(0)}",
                                                    style: const TextStyle(
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
                : const Center(
                    child: Text(
                      "Cart is Empty , Please add some products",
                      textAlign: TextAlign.center,
                    ),
                  ),
      ),
    );
  }

  _saveOrder(CartProvider cartProvider, payable, CouponProvider coupon,
      OrderProvider orderProvider) {
    _orderService.saveOrder({
      'products': cartProvider.cartList,
      'userId': user?.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'discount': discount.toStringAsFixed(0),
      'cod': cartProvider.cod,
      'discountCode': coupon.documentSnapshot == null
          ? null
          : coupon.documentSnapshot?['title'],
      'seller': {
        'shopName': widget.documentSnapshot?['shopName'],
        'sellerId': widget.documentSnapshot?['sellerUid'],
      },
      'timestamp': DateTime.now().toString(),
      'orderStatus': 'Ordered',
      'deliveryBoy': {
        'name': '',
        'phone': '',
        'location': const GeoPoint(0, 0),
        'email': '',
        'image': '',
      }
    }).then((value) {
      orderProvider.success = false;
      _cartServices.deleteCart().then((value) {
        _cartServices.checkData().then((value) {
          EasyLoading.showSuccess(
              "Order successfully placed will be accepted or reject soon");
          Navigator.pop(context);
        });
      });
    });
  }
}
