import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CouponProvider with ChangeNotifier {
  bool? expired;
  DocumentSnapshot? documentSnapshot;
  int discountRate = 0;
  Future<DocumentSnapshot> getCouponDetails(title, sellerId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('coupons').doc(title).get();
    if (documentSnapshot.exists) {
      if (documentSnapshot['sellerId'] == sellerId) {
        checkExpiry(documentSnapshot);
      }
    }
    return documentSnapshot;
  }

  checkExpiry(DocumentSnapshot documentSnapshot) {
    DateTime dateTime = documentSnapshot['expiry'].toDate();
    var dateDifference = dateTime.difference(DateTime.now()).inDays;
    if (dateDifference < 0) {
      expired = true;
      notifyListeners();
    } else {
      this.documentSnapshot = documentSnapshot;
      expired = false;
      discountRate = documentSnapshot['discountRate'];
      notifyListeners();
    }
  }
}
