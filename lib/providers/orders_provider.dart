import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  String? status;
  String? amount;
  bool success = false;
  String? shopName;
  String? email;

  filterOrder(status) {
    this.status = status;
    notifyListeners();
  }

  totalAmountPayable(amount, shopName,email) {
    this.amount = amount.toStringAsFixed(0);
    this.shopName = shopName;
    this.email = email;
    notifyListeners();
  }

  paymentStatus(success) {
    this.success = success;
    notifyListeners();
  }
}
