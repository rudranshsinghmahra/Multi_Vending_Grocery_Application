import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/providers/cart_provider.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';
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
    cartServices.getShopName().then((value) {
      setState(() {
        documentSnapshot = value;
      });
    });

    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      color: Colors.green,
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
                  Text(
                    "${_cartProvider.cartQty} | Items",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  if(documentSnapshot!.exists)
                  Text(
                    "From ${documentSnapshot?['shopName']}",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {},
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
