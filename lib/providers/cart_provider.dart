import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_vending_grocery_app/services/cart_services.dart';

class CartProvider extends ChangeNotifier {
  CartServices _cartServices = CartServices();
  double subTotal = 0.0;
  int cartQty = 0;
  QuerySnapshot? snapshot;
  double savings = 0.0;
  double distance = 0.0;
  bool cod = false;

  Future<double?> getCartTotal() async {
    double cartTotal = 0;
    var savings = 0.0;
    QuerySnapshot snapshot = await _cartServices.cart
        .doc(_cartServices.user?.uid)
        .collection('products')
        .get();
    if (snapshot == null) {
      return null;
    }
    snapshot.docs.forEach((element) {
      cartTotal = cartTotal + element['total'];
      savings = savings + ((element['comparedPrice'] - element['price']) > 0
          ? element['comparedPrice'] - element['price']
          : 0);
    });

    subTotal = cartTotal;
    cartQty = snapshot.size;
    this.snapshot = snapshot;
    this.savings = savings;
    notifyListeners();

    return cartTotal;
  }

  getDistance(distance){
    this.distance = distance;
    notifyListeners();
  }

  getPaymentMethod(index){
    if(index==0){
      this.cod = false;
      notifyListeners();
    }
    else{
      this.cod = true;
      notifyListeners();
    }
  }
}
