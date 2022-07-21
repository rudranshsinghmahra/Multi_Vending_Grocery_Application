import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/screens/cart_screen.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
  const CartNotification({Key? key}) : super(key: key);

  @override
  State<CartNotification> createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  CartServices cartServices = CartServices();
  DocumentSnapshot? documentSnapshot;

  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context);
    _cartProvider.getCartTotal();
    _cartProvider.getShopName();

    return Visibility(
      visible: _cartProvider.distance <= 10
          ? _cartProvider.cartQty > 0
              ? true
              : false
          : false,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${_cartProvider.cartQty} ${_cartProvider.cartQty > 1 ? "Items" : "Item"}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        const Text(
                          "  |  ",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          _cartProvider.subTotal.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    if (_cartProvider.documentSnapshot != null)
                      Text(
                        "From ${_cartProvider.documentSnapshot?['shopName']}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: const RouteSettings(name: CartScreen.id),
                    screen: CartScreen(
                      documentSnapshot: _cartProvider.documentSnapshot,
                    ),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Row(
                  children: const [
                    Text(
                      "View Cart",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
