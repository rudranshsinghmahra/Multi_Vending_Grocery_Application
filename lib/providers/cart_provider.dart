import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';

class CartProvider extends ChangeNotifier {

  CartServices _cartServices = CartServices();
  double subTotal = 0.0;
  int cartQty = 0;
  QuerySnapshot? snapshot;

  Future<double?> getCartTotal() async {
    double cartTotal = 0;
    QuerySnapshot snapshot = await _cartServices.cart
        .doc(_cartServices.user?.uid)
        .collection('products')
        .get();
    if(snapshot==null){
      return null;
    }
    snapshot.docs.forEach((element) {
      cartTotal = cartTotal + element['total'];
    });

    subTotal = cartTotal;
    cartQty = snapshot.size;
    this.snapshot = snapshot;
    notifyListeners();

    return cartTotal;
  }
}
